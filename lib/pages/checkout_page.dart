import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/components/checkoutPage/create_room_card.dart';
import 'package:seefood/components/checkoutPage/join_room_card.dart';
import 'package:seefood/components/checkoutPage/payment_summary_card.dart';
import 'package:seefood/payment/order_api.dart';
import 'package:seefood/payment/order_verify_api.dart';
import 'package:seefood/payment/razorpay_service.dart';
import 'package:seefood/pages/login_page.dart';
import 'package:seefood/pages/main_page.dart';
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
  late final RazorpayService _razorpayService;
  late final OrderApi _orderApi;
  late final OrderVerifyApi _verifyApi;
  late final RoomApi _roomApi;
  RoomModel? _room;
  _RoomPayContext? _pendingRoomPay;
  bool _isPaying = false;
  bool _showCreateRoom = false;

  void _goToOrders() {
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const MainPage(initialIndex: 2),
      ),
      (_) => false,
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
        () async {
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
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Room payment verified')),
              );
              return;
            }

            await _verifyApi.verifyPayment(
              orderId: response.orderId ?? '',
              paymentId: response.paymentId ?? '',
              signature: response.signature ?? '',
            );
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Payment verified')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Verify failed: $e')),
            );
          } finally {
            if (_pendingRoomPay == null) {
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
    _razorpayService.dispose();
    super.dispose();
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
        centerTitle: true,
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
              onTap: () {
                setState(() {
                  _showCreateRoom = !_showCreateRoom;
                  _room = null;
                });
              },
              child: Container(
                margin: const EdgeInsets.only(right: 20),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  _showCreateRoom ? 'Join Room' : 'Create Room',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),
        ],
        bottom: (_showCreateRoom && (_room?.code ?? '').isNotEmpty)
            ? PreferredSize(
                preferredSize: const Size.fromHeight(48),
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, right: 20, bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grayground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Room Code:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _room?.code ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_showCreateRoom)
              CreateRoomCard(
                studentId: studentId,
                onRoomChanged: (room) {
                  setState(() => _room = room);
                },
              )
            else
              JoinRoomCard(
                studentId: studentId,
                onRoomChanged: (room) {
                  setState(() => _room = room);
                },
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
          height: 52,
          child: ElevatedButton(
            onPressed: _isPaying || (isRoomActive && isMemberPaid)
                ? null
                : () {
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
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2B5F06),
              foregroundColor: Colors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: _isPaying
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(
                    isLoggedIn
                        ? (isRoomActive
                            ? (isMemberPaid ? 'Paid' : 'Pay share')
                            : 'Pay')
                        : 'Login to order',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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
  });

  final String code;
  final int studentId;
  final String orderId;
}
