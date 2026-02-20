import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/components/checkoutPage/create_room_card.dart';
import 'package:seefood/components/checkoutPage/payment_summary_card.dart';
import 'package:seefood/payment/order_api.dart';
import 'package:seefood/payment/order_verify_api.dart';
import 'package:seefood/payment/razorpay_service.dart';
import 'package:seefood/pages/login_page.dart';
import 'package:seefood/pages/main_page.dart';
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
  bool _isPaying = false;

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
    _razorpayService = RazorpayService(
      onSuccess: (response) {
        if (!mounted) return;
        () async {
          try {
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
            _goToOrders();
          }
        }();
      },
      onError: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${response.message}')),
        );
        _goToOrders();
      },
      onExternalWallet: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('External wallet: ${response.walletName}')),
        );
        _goToOrders();
      },
    );
  }

  @override
  void dispose() {
    _orderApi.close();
    _verifyApi.close();
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

    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Checkout'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CreateRoomCard(
              onCreate: () {
                // TODO: create room action
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
            onPressed: _isPaying
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
                    isLoggedIn ? 'Pay' : 'Login to order',
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
