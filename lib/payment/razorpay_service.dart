import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:seefood/data/app_env.dart';

class RazorpayService {
  RazorpayService({
    required this.onSuccess,
    required this.onError,
    required this.onExternalWallet,
  }) {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
  }

  late final Razorpay _razorpay;
  final void Function(PaymentSuccessResponse) onSuccess;
  final void Function(PaymentFailureResponse) onError;
  final void Function(ExternalWalletResponse) onExternalWallet;

  void openCheckout({
    required int amountInPaise,
    required String name,
    required String description,
    required String contact,
    required String email,
    String? orderId,
    Map<String, String>? notes,
  }) {
    final key = AppEnv.razorpayKey;
    if (key.isEmpty) {
      throw Exception('Missing RAZORPAY_KEY in .env');
    }

    final options = {
      'key': key,
      'amount': amountInPaise,
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      // ignore: use_null_aware_elements
      if (orderId != null) 'order_id': orderId,
      // ignore: use_null_aware_elements
      if (notes != null) 'notes': notes,
      'retry': {'enabled': true, 'max_count': 1},
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
