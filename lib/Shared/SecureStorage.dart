import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final _secureStorage = FlutterSecureStorage();

class TokenStorage {
  static const _refreshKey = 'refresh_token';
  static const _accessKey = 'access_token';

  static Future<void> writeRefreshToken(String token) =>
      _secureStorage.write(key: _refreshKey, value: token);

  static Future<String?> readRefreshToken() =>
      _secureStorage.read(key: _refreshKey);

  static Future<void> deleteRefreshToken() =>
      _secureStorage.delete(key: _refreshKey);

  static Future<void> writeAccessToken(String token) =>
      _secureStorage.write(key: _accessKey, value: token);

  static Future<String?> readAccessToken() =>
      _secureStorage.read(key: _accessKey);

  static Future<void> deleteAccessToken() =>
      _secureStorage.delete(key: _accessKey);

  // non-Secure Data
  static Future<void> writeFullName(String fullName) =>
      _secureStorage.write(key: 'fullName', value: fullName);

  static Future<String?> readFullName() =>
      _secureStorage.read(key: 'fullName');

  static Future<void> deleteFullName() =>
      _secureStorage.delete(key: 'fullName');
}
