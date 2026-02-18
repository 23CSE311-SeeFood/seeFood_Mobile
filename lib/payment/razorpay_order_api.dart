import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';

class RazorpayOrderApi {
  RazorpayOrderApi({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> createOrder({
    required int amountInPaise,
    String currency = 'INR',
    String? receipt,
    Map<String, String>? notes,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/payments/create-order');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'amount': amountInPaise,
        'currency': currency,
        // ignore: use_null_aware_elements
        if (receipt != null) 'receipt': receipt,
        // ignore: use_null_aware_elements
        if (notes != null) 'notes': notes,
      }),
    );

    if (response.statusCode != 201) {
      throw Exception('Order create failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    final orderId = decoded['id'] as String?;
    if (orderId == null || orderId.isEmpty) {
      throw Exception('Order ID missing in response');
    }
    return orderId;
  }

  void close() => _client.close();
}
