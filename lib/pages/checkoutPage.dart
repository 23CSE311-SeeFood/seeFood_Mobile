import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/payment/razorpay_order_api.dart';
import 'package:seefood/payment/razorpay_service.dart';
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.foreground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Create Room',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Split the bill before order',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: create room action
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Create'),
                  ),
                ],
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
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.foreground,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _SummaryRow(
                    label: 'Subtotal',
                    value: '₹${subtotal.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _SummaryRow(
                    label: 'GST (5%)',
                    value: '₹${gst.toStringAsFixed(2)}',
                  ),
                  const Divider(height: 20),
                  _SummaryRow(
                    label: 'Total',
                    value: '₹${total.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: _isPaying ? null : _startPayment,
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
                : const Text(
                    'Pay',
                    style: TextStyle(
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  final String label;
  final String value;
  final bool isBold;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: 14,
      fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
      color: Colors.black87,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }
}
