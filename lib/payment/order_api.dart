import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';

class OrderApi {
  OrderApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<OrderCreateResponse> createFromCart({
    required int studentId,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/orders/create');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Order create failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final razorpay = decoded['razorpay'] as Map<String, dynamic>?;
    if (razorpay == null) {
      throw Exception('Missing razorpay payload');
    }

    final orderId = razorpay['orderId'] as String?;
    final amount = razorpay['amount'] as int?;
    final currency = razorpay['currency'] as String?;

    if (orderId == null || amount == null || currency == null) {
      throw Exception('Invalid razorpay payload');
    }

    return OrderCreateResponse(
      orderId: orderId,
      amountInPaise: amount,
      currency: currency,
    );
  }

  void close() => _client.close();
}

class OrderCreateResponse {
  OrderCreateResponse({
    required this.orderId,
    required this.amountInPaise,
    required this.currency,
  });

  final String orderId;
  final int amountInPaise;
  final String currency;
}
