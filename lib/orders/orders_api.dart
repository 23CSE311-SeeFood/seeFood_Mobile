import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';
import 'package:seefood/orders/order_models.dart';

class OrdersApi {
  OrdersApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl;

  final http.Client _client;
  final String? _baseUrl;

  Future<List<OrderModel>> fetchOrders({
    required int studentId,
    String? token,
  }) async {
    final base = _baseUrl ?? AppEnv.apiBaseUrl;
    final uri = Uri.parse('$base/orders/student/$studentId');
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

  Future<OrderModel> fetchOrderDetail({
    required int orderId,
    String? token,
  }) async {
    final base = _baseUrl ?? AppEnv.apiBaseUrl;
    final uri = Uri.parse('$base/orders/$orderId');
    final response = await _client.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch order (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid order response');
    }

    return OrderModel.fromJson(decoded);
  }

  void close() => _client.close();
}
