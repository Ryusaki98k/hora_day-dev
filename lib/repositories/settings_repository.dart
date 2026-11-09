import 'dart:convert';

/// คลังข้อมูลการตั้งค่า — key/value แบบ JSON
abstract class SettingsRepository {
  /// อ่านค่า (คืน null ถ้าไม่มี)
  T? get<T>(String key);

  /// เขียนค่า (เก็บเป็น JSON string)
  Future<void> set<T>(String key, T value);

  /// ลบค่า
  Future<void> remove(String key);

  /// อ่านเป็น object จาก JSON
  Map<String, dynamic>? getJson(String key);

  /// เขียน object เป็น JSON
  Future<void> setJson(String key, Map<String, dynamic> value);
}

extension SettingsRepositoryExt on SettingsRepository {
  int getInt(String key, int defaultValue) =>
      get<int>(key) ?? defaultValue;

  Future<void> setInt(String key, int value) => set<int>(key, value);

  String getString(String key, String defaultValue) =>
      get<String>(key) ?? defaultValue;

  Future<void> setString(String key, String value) => set<String>(key, value);

  bool getBool(String key, bool defaultValue) =>
      get<bool>(key) ?? defaultValue;

  Future<void> setBool(String key, bool value) => set<bool>(key, value);

  double getDouble(String key, double defaultValue) =>
      get<double>(key) ?? defaultValue;

  Future<void> setDouble(String key, double value) => set<double>(key, value);
}

/// Helper แปลงค่า from/to JSON สำหรับ SettingsRepository
class SettingsJson {
  static String encode(Map<String, dynamic> value) => jsonEncode(value);

  static Map<String, dynamic>? decode(String? json) {
    if (json == null || json.isEmpty) return null;
    final decoded = jsonDecode(json);
    if (decoded is Map<String, dynamic>) return decoded;
    return null;
  }
}
