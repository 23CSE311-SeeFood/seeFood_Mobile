import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/components/checkoutPage/createRoomCard.dart';
import 'package:seefood/components/checkoutPage/paymentSummaryCard.dart';
import 'package:seefood/payment/razorpay_order_api.dart';
import 'package:seefood/payment/razorpay_service.dart';
import 'package:seefood/pages/loginPage.dart';
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
  late final RazorpayOrderApi _orderApi;
  bool _isPaying = false;

  @override
  void initState() {
    super.initState();
    _orderApi = RazorpayOrderApi();
    _razorpayService = RazorpayService(
      onSuccess: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment successful')),
        );
        // TODO: clear cart after successful payment if desired.
      },
      onError: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Payment failed: ${response.message}')),
        );
      },
      onExternalWallet: (response) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('External wallet: ${response.walletName}')),
        );
      },
    );
  }

  @override
  void dispose() {
    _orderApi.close();
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _startPayment() async {
    final cart = context.read<CartController>();
    if (cart.totalQuantity == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Your plate is empty')),
      );
      return;
    }

    if (_isPaying) return;
    setState(() => _isPaying = true);

    try {
      final amountInPaise = (cart.totalPrice * 100).round();
      final itemsSummary = cart.items
          .map((item) => '${item.name} x${item.quantity}')
          .join(', ');

      final orderId = await _orderApi.createOrder(
        amountInPaise: amountInPaise,
        receipt: 'plate_${DateTime.now().millisecondsSinceEpoch}',
        notes: {
          'items': itemsSummary,
        },
      );

      _razorpayService.openCheckout(
        amountInPaise: amountInPaise,
        name: 'SeeFood',
        description: 'Plate (${cart.totalQuantity} items)',
        contact: '9999999999',
        email: 'test@example.com',
        orderId: orderId,
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
      if (!mounted) return;
      setState(() => _isPaying = false);
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
