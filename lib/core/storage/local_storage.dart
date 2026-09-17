import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A single facade over both local storage mechanisms: secure storage for
/// anything sensitive (kept for convenience/"remember me" — Firebase Auth
/// itself already persists the real session, this app never stores
/// passwords), and SharedPreferences for plain device/UI prefs.
class LocalStorage {
  LocalStorage._internal();
  static final LocalStorage instance = LocalStorage._internal();

  final FlutterSecureStorage _secure = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    final p = _prefs;
    if (p == null) {
      throw StateError('LocalStorage.init() must be awaited before use (see main.dart).');
    }
    return p;
  }

  // Secure
  Future<void> writeSecure(String key, String value) => _secure.write(key: key, value: value);
  Future<String?> readSecure(String key) => _secure.read(key: key);
  Future<void> deleteSecure(String key) => _secure.delete(key: key);
  Future<void> clearSecure() => _secure.deleteAll();

  // Plain prefs
  Future<void> setString(String key, String value) => _p.setString(key, value);
  String? getString(String key) => _p.getString(key);

  Future<void> setBool(String key, bool value) => _p.setBool(key, value);
  bool getBool(String key, {bool defaultValue = false}) => _p.getBool(key) ?? defaultValue;

  Future<void> remove(String key) => _p.remove(key);
}
