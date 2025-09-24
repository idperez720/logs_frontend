import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class JwtStorage {
  static const _k = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<void> save(String token) =>
      _k.write(key: _tokenKey, value: token);
  static Future<String?> read() => _k.read(key: _tokenKey);
  static Future<void> clear() => _k.delete(key: _tokenKey);
}
