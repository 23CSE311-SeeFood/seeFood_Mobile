import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';
import 'package:seefood/orders/order_models.dart';

class OrdersApi {
  OrdersApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<OrderModel>> fetchOrders({
    required int studentId,
    String? token,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/orders/student/$studentId');
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch orders (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('Invalid orders response');
    }

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(OrderModel.fromJson)
        .toList(growable: false);
  }

  void close() => _client.close();
}
