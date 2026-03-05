import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';
import 'package:seefood/rooms/room_models.dart';

class RoomApi {
  RoomApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<RoomCreateResponse> createRoom({required int ownerId}) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/rooms/create');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'ownerId': ownerId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create room (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return RoomCreateResponse.fromJson(decoded);
  }

  Future<void> joinRoom({required String code, required int studentId}) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/rooms/join');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'code': code, 'studentId': studentId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to join room (${response.statusCode})');
    }
  }

  Future<RoomModel> fetchRoom({required String code}) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/rooms/$code');
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch room (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return RoomModel.fromJson(decoded);
  }

  Future<RoomPayCreateResponse> createMemberPayment({
    required String code,
    required int studentId,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/rooms/$code/pay/create');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'studentId': studentId}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create room payment (${response.statusCode}): ${response.body}');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return RoomPayCreateResponse.fromJson(decoded);
  }

  Future<void> verifyMemberPayment({
    required String code,
    required int studentId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/rooms/$code/pay/verify');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Room payment verify failed (${response.statusCode}): ${response.body}');
    }
  }

  void close() => _client.close();
}
