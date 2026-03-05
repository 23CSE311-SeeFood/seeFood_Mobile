import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';
import 'package:seefood/prebook/prebook_models.dart';

class PrebookApi {
  PrebookApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<PrebookSlotResponse> fetchSlots({
    required int canteenId,
    required String date,
  }) async {
    final uri = Uri.parse(
      '${AppEnv.apiBaseUrl}/prebook/slots?canteenId=$canteenId&date=$date',
    );
    final response = await _client.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Failed to load slots (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PrebookSlotResponse.fromJson(decoded);
  }

  Future<PrebookCreateResponse> createPrebook({
    required int studentId,
    required DateTime slotStart,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/prebook/create');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'studentId': studentId,
        'slotStart': slotStart.toUtc().toIso8601String(),
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to create prebook (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PrebookCreateResponse.fromJson(decoded);
  }

  Future<PrebookVerifyResponse> verifyPrebook({
    required int prebookId,
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/prebook/verify');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prebookId': prebookId,
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Prebook verify failed (${response.statusCode})');
    }
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    return PrebookVerifyResponse.fromJson(decoded);
  }

  void close() => _client.close();
}
