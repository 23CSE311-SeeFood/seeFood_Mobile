import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';
import 'package:seefood/store/cart/server_cart_models.dart';

class CartApi {
  CartApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ServerCart?> getCart(int studentId) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId');
    final response = await _client.get(uri);

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch cart (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ServerCart.fromJson(decoded);
  }

  Future<ServerCart> addItem({
    required int studentId,
    required int canteenId,
    required int canteenItemId,
    required int quantity,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/items');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'canteenId': canteenId,
        'canteenItemId': canteenItemId,
        'quantity': quantity,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to add item (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ServerCart.fromJson(decoded);
  }

  Future<ServerCart> updateQuantity({
    required int studentId,
    required int cartItemId,
    required int quantity,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/items/$cartItemId');
    final response = await _client.put(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'quantity': quantity}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to update quantity (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ServerCart.fromJson(decoded);
  }

  Future<ServerCart> removeItem({
    required int studentId,
    required int cartItemId,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/items/$cartItemId');
    final response = await _client.delete(uri);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to remove item (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ServerCart.fromJson(decoded);
  }

  Future<void> clearCart(int studentId) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId');
    final response = await _client.delete(uri);
    if (response.statusCode != 204) {
      throw Exception('Failed to clear cart (${response.statusCode})');
    }
  }

  Future<ServerCart> syncCart({
    required int studentId,
    required int canteenId,
    required List<Map<String, int>> items,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/sync');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'canteenId': canteenId,
        'items': items,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to sync cart (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return ServerCart.fromJson(decoded);
  }

  void close() => _client.close();
}
