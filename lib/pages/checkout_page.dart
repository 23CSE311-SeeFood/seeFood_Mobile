import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/components/checkoutPage/join_room_card.dart';
import 'package:seefood/components/checkoutPage/payment_summary_card.dart';
import 'package:seefood/components/checkoutPage/room_members_card.dart';
import 'package:seefood/components/checkoutPage/slide_to_pay_button.dart';
import 'package:seefood/data/app_env.dart';
import 'package:seefood/payment/order_api.dart';
import 'package:seefood/payment/order_verify_api.dart';
import 'package:seefood/payment/razorpay_service.dart';
import 'package:seefood/pages/login_page.dart';
import 'package:seefood/pages/main_page.dart';
import 'package:seefood/pages/order_success_page.dart';
import 'package:seefood/pages/payment_verifying_page.dart';
import 'package:seefood/rooms/room_api.dart';
import 'package:seefood/rooms/room_models.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/themes/app_colors.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  static const Duration _roomAnim = Duration(milliseconds: 260);
  late final RazorpayService _razorpayService;
  late final OrderApi _orderApi;
  late final OrderVerifyApi _verifyApi;
  late final RoomApi _roomApi;
  RoomModel? _room;
  String? _roomCode;
  WebSocket? _roomSocket;
  OrderCreateResponse? _pendingOrder;
  _RoomPayContext? _pendingRoomPay;
  bool _isPaying = false;
  bool _isCreateMode = false;
  bool _isCreatingRoom = false;

  void _goToOrders() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainPage(initialIndex: 2),
      ),
      (_) => false,
    );
  }

  void _goToSuccessPage({
    required String orderId,
    required int amountInPaise,
    required int itemCount,
  }) {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => OrderSuccessPage(
          orderId: orderId,
          amountInPaise: amountInPaise,
          itemCount: itemCount,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _goToVerifyingPage() {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const PaymentVerifyingPage(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _orderApi = OrderApi();
    _verifyApi = OrderVerifyApi();
    _roomApi = RoomApi();
    _razorpayService = RazorpayService(
      onSuccess: (response) {
        if (!mounted) return;
        _goToVerifyingPage();
        () async {
          var goToOrders = true;
          try {
            if (_pendingRoomPay != null) {
              final ctx = _pendingRoomPay!;
              final orderId = response.orderId ?? ctx.orderId;
              final paymentId = response.paymentId;
              final signature = response.signature;

              if (orderId.isEmpty ||
                  paymentId == null ||
                  paymentId.isEmpty ||
                  signature == null ||
                  signature.isEmpty) {
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Missing Razorpay fields for room payment'),
                  ),
                );
                return;
              }

              await _roomApi.verifyMemberPayment(
                code: ctx.code,
                studentId: ctx.studentId,
                orderId: orderId,
                paymentId: paymentId,
                signature: signature,
              );
              _pendingRoomPay = null;
              final cart = context.read<CartController>();
              final itemCount = cart.totalQuantity;
              await cart.clear();
              goToOrders = false;
              _goToSuccessPage(
                orderId: orderId,
                amountInPaise: ctx.amountInPaise,
                itemCount: itemCount,
              );
              return;
            }

            await _verifyApi.verifyPayment(
              orderId: response.orderId ?? '',
              paymentId: response.paymentId ?? '',
              signature: response.signature ?? '',
            );
            final cart = context.read<CartController>();
            final itemCount = cart.totalQuantity;
            final order = _pendingOrder;
            _pendingOrder = null;
            await cart.clear();
            goToOrders = false;
            _goToSuccessPage(
              orderId: order?.orderId ?? (response.orderId ?? ''),
              amountInPaise:
                  order?.amountInPaise ?? (cart.totalPrice * 100).round(),
              itemCount: itemCount,
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verify failed: $e')),
            );
          } finally {
            if (goToOrders && _pendingRoomPay == null) {
              _goToOrders();
            }
          }
        }();
      },
      onError: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${response.message}')),
        );
        if (_pendingRoomPay == null) {
          _goToOrders();
        }
      },
      onExternalWallet: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('External wallet: ${response.walletName}')),
        );
        if (_pendingRoomPay == null) {
          _goToOrders();
        }
      },
    );
  }

  @override
  void dispose() {
    _orderApi.close();
    _verifyApi.close();
    _roomApi.close();
    _roomSocket?.close();
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _handleCreateRoomTap() async {
    if (_isCreateMode) {
      setState(() {
        _isCreateMode = false;
        _room = null;
        _roomCode = null;
      });
      _roomSocket?.close();
      _roomSocket = null;
      return;
    }

    final authRepository = context.read<AuthRepository>();
    final studentId = authRepository.getStudentId();
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login to create a room')),
      );
      return;
    }

    if (_isCreatingRoom) return;
    setState(() {
      _isCreatingRoom = true;
      _isCreateMode = true;
      _room = null;
      _roomCode = null;
    });

    try {
      final created = await _roomApi.createRoom(ownerId: studentId);
      _roomCode = created.code;
      await _connectRoomSocket(created.code);
      final room = await _roomApi.fetchRoom(code: created.code);
      if (mounted) {
        setState(() => _room = room);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCreateMode = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Create room failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isCreatingRoom = false);
    }
  }

  Future<void> _connectRoomSocket(String code) async {
    _roomSocket?.close();
    final wsUri = _buildWsUri(code);
    try {
      final socket = await WebSocket.connect(wsUri.toString());
      _roomSocket = socket;
      socket.listen((msg) {
        _handleRoomMessage(msg);
      }, onError: (_) {}, onDone: () {
        _roomSocket = null;
      });
    } catch (_) {
      // ignore
    }
  }

  Uri _buildWsUri(String code) {
    final base = Uri.parse(AppEnv.apiBaseUrl);
    final scheme = base.scheme == 'https' ? 'wss' : 'ws';
    final host = (Platform.isAndroid &&
            (base.host == 'localhost' || base.host == '127.0.0.1'))
        ? '10.0.2.2'
        : base.host;
    return Uri(
      scheme: scheme,
      host: host,
      port: base.hasPort ? base.port : null,
      path: '/ws',
      queryParameters: {'roomCode': code},
    );
  }

  void _handleRoomMessage(dynamic message) {
    try {
      final decoded = jsonDecode(message.toString());
      if (decoded is! Map<String, dynamic>) return;
      final type = decoded['type']?.toString();
      if (type != 'room_snapshot' && type != 'room_update') return;
      final roomJson = decoded['room'];
      if (roomJson is! Map<String, dynamic>) return;
      final room = RoomModel.fromJson(roomJson);
      if (!mounted) return;
      setState(() {
        _room = room;
        _roomCode = room.code;
        _isCreateMode = true;
      });
    } catch (_) {
      // ignore
    }
  }

  void _handleKick(RoomMember member) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Kick not implemented yet')),
    );
  }

  Future<void> _startPayment() async {
    final cart = context.read<CartController>();
    final authRepository = context.read<AuthRepository>();
    final studentId = authRepository.getStudentId();
    if (cart.totalQuantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your plate is empty')),
      );
      return;
    }
    if (studentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login required to place order')),
      );
      return;
    }

    if (_isPaying) return;
    setState(() => _isPaying = true);

    try {
      if (_room != null) {
        final room = _room!;
        final pay = await _roomApi.createMemberPayment(
          code: room.code,
          studentId: studentId,
        );
        if (pay.orderId.isEmpty) {
          throw Exception('Room payment missing orderId');
        }
        _pendingRoomPay = _RoomPayContext(
          code: room.code,
          studentId: studentId,
          orderId: pay.orderId,
          amountInPaise: pay.amount,
        );

        _razorpayService.openCheckout(
          amountInPaise: pay.amount,
          name: 'SeeFood',
          description: 'Room payment',
          contact: '9999999999',
          email: 'test@example.com',
          orderId: pay.orderId,
          keyOverride: pay.key,
        );
        return;
      }

      final order = await _orderApi.createFromCart(
        studentId: studentId,
      );
      _pendingOrder = order;

      final itemsSummary = cart.items
          .map((item) => '${item.name} x${item.quantity}')
          .join(', ');

      _razorpayService.openCheckout(
        amountInPaise: order.amountInPaise,
        name: 'SeeFood',
        description: 'Plate (${cart.totalQuantity} items)',
        contact: '9999999999',
        email: 'test@example.com',
        orderId: order.orderId,
        notes: {
          'items': itemsSummary,
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment init failed: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isPaying = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final authRepository = context.watch<AuthRepository>();
    final isLoggedIn =
        (authRepository.getToken() ?? '').trim().isNotEmpty;
    final subtotal = cart.totalPrice;
    final gst = subtotal * 0.05;
    final total = subtotal + gst;
    final studentId = authRepository.getStudentId();
    final isMemberPaid = _room?.members
            .any((m) => m.studentId == studentId && m.status == 'PAID') ??
        false;
    final isRoomActive = _room != null;

    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: AppBar(
        backgroundColor: AppColors.grayground,
        elevation: 0,
        leadingWidth: 80,
        automaticallyImplyLeading: false,
        title: const Text(
          'Checkout',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
        leading: Center(
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 50,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                size: 20,
                color: Colors.black,
              ),
            ),
          ),
        ),
        actions: [
          Center(
            child: GestureDetector(
              onTap: _handleCreateRoomTap,
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: _isCreatingRoom
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _isCreateMode ? 'Join Room' : 'Create Room',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSwitcher(
              duration: _roomAnim,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: (_isCreateMode && (_roomCode ?? '').isNotEmpty)
                  ? Container(
                      key: const ValueKey('room_code_bar'),
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.grayground,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _roomCode ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'room code',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('room_code_empty'),
                    ),
            ),
            if (_isCreateMode && (_roomCode ?? '').isNotEmpty)
              const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: _roomAnim,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: (_isCreateMode && (_roomCode ?? '').isNotEmpty)
                  ? RoomMembersCard(
                      key: const ValueKey('room_members_card'),
                      members: _room?.members ?? const [],
                      onKick: _handleKick,
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('room_members_empty'),
                    ),
            ),
            if (_isCreateMode && (_roomCode ?? '').isNotEmpty)
              const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: _roomAnim,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeOutCubic,
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SizeTransition(
                    sizeFactor: animation,
                    axisAlignment: -1,
                    child: child,
                  ),
                );
              },
              child: !_isCreateMode
                  ? JoinRoomCard(
                      key: const ValueKey('join_room_card'),
                      studentId: studentId,
                      onRoomChanged: (room) {
                        setState(() {
                          _room = room;
                          _roomCode = room?.code;
                        });
                      },
                    )
                  : const SizedBox.shrink(
                      key: ValueKey('join_room_empty'),
                    ),
            ),
            const SizedBox(height: 20),
            Text(
              'Payment Summary',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 10),
            PaymentSummaryCard(
              subtotal: subtotal,
              gst: gst,
              total: total,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 60,
          child: SlideToPayButton(
            isLoading: _isPaying,
            enabled: !(isRoomActive && isMemberPaid),
            onSlide: () {
              if (!isLoggedIn) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const LoginPage(),
                  ),
                );
                return;
              }
              _startPayment();
            },
            child: Text(
              isLoggedIn
                  ? (isRoomActive
                      ? (isMemberPaid ? 'Paid' : 'Slide to Pay Share')
                      : 'Slide to Pay')
                  : 'Slide to Login',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoomPayContext {
  _RoomPayContext({
    required this.code,
    required this.studentId,
    required this.orderId,
    required this.amountInPaise,
  });

  final String code;
  final int studentId;
  final String orderId;
  final int amountInPaise;
}
