import 'package:local_auth/local_auth.dart';

/// ตรวจสอบ biometric (นิ้วมือ/ใบหน้า) เฉพาะ mobile — web ไม่รองรับ
class BiometricHelper {
  static final LocalAuthentication _auth = LocalAuthentication();

  /// ตรวจสอบว่าเครื่องรองรับ biometric หรือไม่ (mobile เท่านั้น)
  static Future<bool> isAvailable() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// ยืนยันตัวตนด้วย biometric
  static Future<bool> authenticate({String reason = 'ยืนยันตัวตนเพื่อปลดล็อกแอป'}) async {
    try {
      return await _auth.authenticate(localizedReason: reason);
    } catch (_) {
      return false;
    }
  }

  /// ชนิด biometric ที่ใช้งานได้
  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }
}
