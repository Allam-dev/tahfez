import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'token_handler.dart';

const String _accessToken = 'accessToken';
const String _refreshToken = 'refreshToken';

class TokenHandlerImpl implements TokenHandler {
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  @override
  Future<void> clear() async {
    await _storage.deleteAll();
  }

  @override
  Future<String?> getAccessToken() => _storage.read(key: _accessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _refreshToken);

  @override
  Future<void> setAccessToken(String accessToken) =>
      _storage.write(key: _accessToken, value: accessToken);

  @override
  Future<void> setRefreshToken(String refreshToken) =>
      _storage.write(key: _refreshToken, value: refreshToken);
}
