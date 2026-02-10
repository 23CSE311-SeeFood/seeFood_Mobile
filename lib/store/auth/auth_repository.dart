import 'package:hive/hive.dart';

class AuthRepository {
  static const String _boxName = 'auth';
  static const String _tokenKey = 'token';

  Box<String>? _box;

  Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  Future<void> saveToken(String token) async {
    await _ensureReady();
    await _box!.put(_tokenKey, token);
  }

  String? getToken() {
    if (_box == null) return null;
    return _box!.get(_tokenKey);
  }

  Future<void> clearToken() async {
    await _ensureReady();
    await _box!.delete(_tokenKey);
  }

  Future<void> _ensureReady() async {
    if (_box != null) return;
    await init();
  }
}
