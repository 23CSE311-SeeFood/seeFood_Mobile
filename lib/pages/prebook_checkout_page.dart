import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seefood/components/checkoutPage/payment_summary_card.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/pages/login_page.dart';
import 'package:seefood/pages/prebook_confirmation_page.dart';
import 'package:seefood/payment/razorpay_service.dart';
import 'package:seefood/prebook/prebook_api.dart';
import 'package:seefood/prebook/prebook_models.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:seefood/store/auth/auth_repository.dart';
import 'package:seefood/store/cart/cart_controller.dart';
import 'package:seefood/themes/app_colors.dart';

class PrebookCheckoutPage extends StatefulWidget {
  const PrebookCheckoutPage({
    super.key,
    required this.canteen,
    required this.slotStart,
  });

  final Canteen canteen;
  final DateTime slotStart;

  @override
  State<PrebookCheckoutPage> createState() => _PrebookCheckoutPageState();
}

class _PrebookCheckoutPageState extends State<PrebookCheckoutPage> {
  late final RazorpayService _razorpayService;
  late final PrebookApi _prebookApi;
  bool _isPaying = false;
  PrebookCreateResponse? _pending;

  @override
  void initState() {
    super.initState();
    _prebookApi = PrebookApi();
    _razorpayService = RazorpayService(
      onSuccess: (response) {
        if (!mounted) return;
        _verifyPrebook(response);
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
    _prebookApi.close();
    _razorpayService.dispose();
    super.dispose();
  }

  Future<void> _startPrebook() async {
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
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
      return;
    }

    if (_isPaying) return;
    setState(() => _isPaying = true);

    try {
      final create = await _prebookApi.createPrebook(
        studentId: studentId,
        slotStart: widget.slotStart,
      );
      _pending = create;

      final itemsSummary = cart.items
          .map((item) => '${item.name} x${item.quantity}')
          .join(', ');

      _razorpayService.openCheckout(
        amountInPaise: create.razorpay.amount,
        name: 'SeeFood',
        description: 'Prebook (${cart.totalQuantity} items)',
        contact: '9999999999',
        email: 'test@example.com',
        orderId: create.razorpay.orderId,
        keyOverride: create.razorpay.key,
        notes: {
          'items': itemsSummary,
          'slot': widget.slotStart.toIso8601String(),
        },
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Prebook init failed: $e')),
      );
    } finally {
      if (!mounted) return;
      setState(() => _isPaying = false);
    }
  }

  Future<void> _verifyPrebook(PaymentSuccessResponse response) async {
    final pending = _pending;
    if (pending == null) return;

    try {
      final verify = await _prebookApi.verifyPrebook(
        prebookId: pending.prebookId,
        orderId: response.orderId ?? '',
        paymentId: response.paymentId ?? '',
        signature: response.signature ?? '',
      );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => PrebookConfirmationPage(
            canteen: widget.canteen,
            slotStart: widget.slotStart,
            confirmation: verify,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartController>();
    final subtotal = cart.totalPrice;
    final gst = subtotal * 0.05;
    final total = subtotal + gst;
    final slotTime = TimeOfDay.fromDateTime(widget.slotStart.toLocal())
        .format(context);

    return Scaffold(
      backgroundColor: AppColors.grayground,
      appBar: AppBar(
        backgroundColor: AppColors.foreground,
        foregroundColor: Colors.black,
        elevation: 0,
        title: const Text('Prebook Checkout'),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Selected slot',
                    style: TextStyle(fontSize: 12, color: Colors.black54),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${widget.canteen.name} • $slotTime',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
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
            onPressed: _isPaying ? null : _startPrebook,
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
                    'Pay & Book',
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
