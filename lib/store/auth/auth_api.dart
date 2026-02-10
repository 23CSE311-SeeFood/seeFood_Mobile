import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:seefood/data/app_env.dart';

class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<String> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('${AppEnv.apiBaseUrl}/auth/register');
    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Registration failed (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
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
