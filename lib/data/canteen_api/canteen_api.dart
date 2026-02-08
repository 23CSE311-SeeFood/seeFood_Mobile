import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';
import 'package:seefood/data/canteen_api/canteen.dart';
import 'package:seefood/data/canteen_api/canteen_item.dart';

class CanteenApi {
  CanteenApi({http.Client? client, String? baseUrl})
      : _client = client ?? http.Client(),
        _baseUrl = baseUrl ?? AppEnv.apiBaseUrl;

  final http.Client _client;
  final String _baseUrl;

  Future<List<Canteen>> fetchCanteens() async {
    final uri = Uri.parse('$_baseUrl/canteens');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw CanteenApiException(
        'Failed to load canteens (status ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw CanteenApiException('Unexpected response format.');
    }

    return decoded
        .map((item) => Canteen.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<CanteenItem>> fetchItems({required int canteenId}) async {
    final uri = Uri.parse('$_baseUrl/canteens/$canteenId/items');
    final response = await _client.get(uri);

    if (response.statusCode != 200) {
      throw CanteenApiException(
        'Failed to load items (status ${response.statusCode}).',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw CanteenApiException('Unexpected response format.');
    }

    return decoded
        .map((item) => CanteenItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  void close() => _client.close();
}

class CanteenApiException implements Exception {
  CanteenApiException(this.message);

  final String message;

  @override
  String toString() => message;
}
