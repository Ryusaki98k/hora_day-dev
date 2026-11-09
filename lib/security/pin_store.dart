import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ที่เก็บ PIN แบบ hash + salt (ไม่เก็บ PIN ตรงๆ)
///
/// Mobile: flutter_secure_storage (เข้ารหัสในระบบ)
/// Web: shared_preferences (ข้อจำกัดของเว็บ — PIN ล็อกแค่ UI ไม่ได้เข้ารหัสข้อมูล)
class PinStore {
  static const _keyPinHash = 'pin_hash';
  static const _keyPinSalt = 'pin_salt';
  static const _keyPinEnabled = 'pin_enabled';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final bool _isWeb;

  PinStore({required this._isWeb});

  /// ตั้ง PIN ใหม่ (สร้าง hash + salt)
  Future<void> setPin(String pin) async {
    try {
      final salt = _generateSalt();
      final hash = _hashPin(pin, salt);
      await _storage.write(key: _keyPinHash, value: hash);
      await _storage.write(key: _keyPinSalt, value: salt);
      await _storage.write(key: _keyPinEnabled, value: 'true');
    } catch (_) {
      rethrow;
    }
  }

  /// ตรวจสอบ PIN
  Future<bool> verifyPin(String pin) async {
    try {
      final hash = await _storage.read(key: _keyPinHash);
      final salt = await _storage.read(key: _keyPinSalt);
      if (hash == null || salt == null) return false;
      return _hashPin(pin, salt) == hash;
    } catch (_) {
      return false;
    }
  }

  /// PIN ถูกตั้งแล้วหรือไม่
  Future<bool> hasPin() async {
    try {
      final enabled = await _storage.read(key: _keyPinEnabled);
      return enabled == 'true';
    } catch (_) {
      return false;
    }
  }

  /// ปิดใช้งาน PIN
  Future<void> clearPin() async {
    await _storage.delete(key: _keyPinHash);
    await _storage.delete(key: _keyPinSalt);
    await _storage.write(key: _keyPinEnabled, value: 'false');
  }

  /// Generate salt แบบสุ่มปลอดภัย (16 bytes → base64)
  String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64Url.encode(bytes);
  }

  /// Hash PIN ด้วย SHA-256 + salt
  String _hashPin(String pin, String salt) {
    final input = utf8.encode('$pin:$salt');
    final digest = sha256.convert(input);
    return base64Url.encode(digest.bytes);
  }

  bool get isWeb => _isWeb;
}
