import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';

class OrderVerifyApi {
  OrderVerifyApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> verifyPayment({
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/orders/verify');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Payment verification failed (${response.statusCode})');
    }
  }

  void close() => _client.close();
}
