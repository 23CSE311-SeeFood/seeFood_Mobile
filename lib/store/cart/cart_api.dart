import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';
import 'package:seefood/store/cart/server_cart_models.dart';

class CartApi {
  CartApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<ServerCart?> fetchCart({
    required int studentId,
    required String token,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId');
    final response = await _client.get(uri, headers: _headers(token));

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
    required String token,
    required int canteenId,
    required int canteenItemId,
    int quantity = 1,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/items');
    final response = await _client.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'canteenId': canteenId,
        'canteenItemId': canteenItemId,
        'quantity': quantity,
      }),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = decoded['error'] ?? decoded['message'];
      throw Exception(
        message != null
            ? 'Failed to add item (${response.statusCode}): $message'
            : 'Failed to add item (${response.statusCode})',
      );
    }
    return ServerCart.fromJson(decoded);
  }

  Future<ServerCart> updateItemQuantity({
    required int studentId,
    required String token,
    required int itemId,
    required int quantity,
  }) async {
    final uri =
        Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/items/$itemId');
    final response = await _client.put(
      uri,
      headers: _headers(token),
      body: jsonEncode({'quantity': quantity}),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final message = decoded['error'] ?? decoded['message'];
      throw Exception(
        message != null
            ? 'Failed to update item (${response.statusCode}): $message'
            : 'Failed to update item (${response.statusCode})',
      );
    }
    return ServerCart.fromJson(decoded);
  }

  Future<ServerCart> removeItem({
    required int studentId,
    required String token,
    required int itemId,
  }) async {
    final uri =
        Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/items/$itemId');
    final response = await _client.delete(uri, headers: _headers(token));

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200) {
      final message = decoded['error'] ?? decoded['message'];
      throw Exception(
        message != null
            ? 'Failed to remove item (${response.statusCode}): $message'
            : 'Failed to remove item (${response.statusCode})',
      );
    }
    return ServerCart.fromJson(decoded);
  }

  Future<void> clearCart({
    required int studentId,
    required String token,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId');
    final response = await _client.delete(uri, headers: _headers(token));
    if (response.statusCode != 204) {
      throw Exception('Failed to clear cart (${response.statusCode})');
    }
  }

  Future<ServerCart> syncCart({
    required int studentId,
    required String token,
    required int canteenId,
    required List<CartSyncItem> items,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/cart/$studentId/sync');
    final response = await _client.post(
      uri,
      headers: _headers(token),
      body: jsonEncode({
        'canteenId': canteenId,
        'items': items.map((item) => item.toJson()).toList(),
      }),
    );

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (response.statusCode != 200 && response.statusCode != 201) {
      final message = decoded['error'] ?? decoded['message'];
      throw Exception(
        message != null
            ? 'Failed to sync cart (${response.statusCode}): $message'
            : 'Failed to sync cart (${response.statusCode})',
      );
    }
    return ServerCart.fromJson(decoded);
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  void close() => _client.close();
}

class CartSyncItem {
  CartSyncItem({required this.canteenItemId, required this.quantity});

  final int canteenItemId;
  final int quantity;

  Map<String, dynamic> toJson() => {
        'canteenItemId': canteenItemId,
        'quantity': quantity,
      };
}
