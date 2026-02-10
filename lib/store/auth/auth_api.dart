import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> register({
    required String name,
    required String email,
    required String number,
    required String password,
    String? branch,
    String? rollNumber,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/auth/register');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'number': number,
        'password': password,
        if (branch != null) 'branch': branch,
        if (rollNumber != null) 'rollNumber': rollNumber,
      }),
    );

    final isOk = response.statusCode == 200 || response.statusCode == 201;
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }

    if (!isOk) {
      final message = decoded?['error'] ?? decoded?['message'];
      throw Exception(
        message != null
            ? 'Registration failed (${response.statusCode}): $message'
            : 'Registration failed (${response.statusCode})',
      );
    }

    if (decoded == null) {
      throw Exception('Invalid response from server');
    }
    final token = decoded['token'] ??
        decoded['accessToken'] ??
        decoded['jwt'] ??
        decoded['data']?['token'];

    if (token is! String || token.isEmpty) {
      throw Exception('Token missing in response');
    }
    return token;
  }

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/auth/login');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final isOk = response.statusCode == 200;
    Map<String, dynamic>? decoded;
    try {
      decoded = jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      decoded = null;
    }

    if (!isOk) {
      final message = decoded?['error'] ?? decoded?['message'];
      throw Exception(
        message != null
            ? 'Login failed (${response.statusCode}): $message'
            : 'Login failed (${response.statusCode})',
      );
    }

    if (decoded == null) {
      throw Exception('Invalid response from server');
    }

    final token = decoded['token'] ??
        decoded['accessToken'] ??
        decoded['jwt'] ??
        decoded['data']?['token'];

    if (token is! String || token.isEmpty) {
      throw Exception('Token missing in response');
    }
    return token;
  }

  void close() => _client.close();
}
