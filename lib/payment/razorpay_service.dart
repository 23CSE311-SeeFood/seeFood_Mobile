import 'package:razorpay_flutter/razorpay_flutter.dart';

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
    final options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // TODO: replace with your Razorpay key.
      'amount': amountInPaise,
      'name': name,
      'description': description,
      'prefill': {
        'contact': contact,
        'email': email,
      },
      if (orderId != null) 'order_id': orderId,
      if (notes != null) 'notes': notes,
      'retry': {'enabled': true, 'max_count': 1},
    };

    _razorpay.open(options);
  }

  void dispose() {
    _razorpay.clear();
  }
}
