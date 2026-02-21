import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:seefood/store/auth/auth_profile.dart';

class AuthRepository {
  static const String _boxName = 'auth';
  static const String _tokenKey = 'token';
  static const String _profileKey = 'profile';

  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> saveToken(String token) async {
    await _ensureReady();
    await _box!.put(_tokenKey, token);
  }

  Future<void> saveTokenAndProfileFromJwt(String token) async {
    await saveToken(token);
    final profile = profileFromToken(token);
    if (profile != null) {
      await saveProfile(profile);
    }
  }

  String? getToken() {
    if (_box == null) return null;
    return _box!.get(_tokenKey);
  }

  Future<void> saveProfile(AuthProfile profile) async {
    await _ensureReady();
    await _box!.put(_profileKey, profile.toJsonString());
  }

  AuthProfile? getProfile() {
    if (_box == null) return null;
    return AuthProfile.fromJsonString(_box!.get(_profileKey));
  }

  AuthProfile? getProfileOrFromToken() {
    final profile = getProfile();
    if (profile != null) return profile;

    final token = getToken();
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;

    try {
      final payload = _decodeJwtPayload(parts[1]);
      if (payload == null) return null;

      if (payload['student'] is Map<String, dynamic>) {
        return _profileFromPayload(payload['student'] as Map<String, dynamic>);
      }

      return _profileFromPayload(payload);
    } catch (_) {
      return null;
    }
  }

  int? getStudentId() {
    final profile = getProfileOrFromToken();
    if (profile?.id != null) return profile!.id;

    final token = getToken();
    if (token == null || token.isEmpty) return null;

    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = _decodeJwtPayload(parts[1]);
    if (payload == null) return null;

    final id = payload['studentId'] ?? payload['id'] ?? payload['userId'] ?? payload['sub'];
    if (id is int) return id;
    return int.tryParse('$id');
  }

  Future<void> clearToken() async {
    await _ensureReady();
    await _box!.delete(_tokenKey);
  }

  Future<void> clearProfile() async {
    await _ensureReady();
    await _box!.delete(_profileKey);
  }

  Future<void> clearAll() async {
    await _ensureReady();
    await _box!.clear();
  }

  Future<void> _ensureReady() async {
    if (_box != null) return;
    await init();
  }

  Map<String, dynamic>? _decodeJwtPayload(String input) {
    final normalized = base64Url.normalize(input);
    final decoded = utf8.decode(base64Url.decode(normalized));
    final payload = jsonDecode(decoded);
    if (payload is Map<String, dynamic>) return payload;
    return null;
  }

  AuthProfile? profileFromToken(String token) {
    final parts = token.split('.');
    if (parts.length != 3) return null;
    final payload = _decodeJwtPayload(parts[1]);
    if (payload == null) return null;
    if (payload['student'] is Map<String, dynamic>) {
      return _profileFromPayload(payload['student'] as Map<String, dynamic>);
    }
    return _profileFromPayload(payload);
  }

  AuthProfile _profileFromPayload(Map<String, dynamic> payload) {
    int? id;
    final rawId = payload['id'] ?? payload['studentId'] ?? payload['userId'];
    if (rawId is int) {
      id = rawId;
    } else if (rawId != null) {
      id = int.tryParse('$rawId');
    }

    final sub = payload['sub']?.toString();
    if (id == null && sub != null) {
      id = int.tryParse(sub);
    }

    return AuthProfile(
      id: id,
      sub: sub,
      provider: payload['provider']?.toString(),
      name: (payload['name'] ?? '').toString(),
      email: (payload['email'] ?? '').toString(),
      number: payload['number']?.toString(),
      branch: payload['branch']?.toString(),
      rollNumber: payload['rollNumber']?.toString(),
    );
  }
}
