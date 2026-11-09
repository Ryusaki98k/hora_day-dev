import 'dart:async';

import 'package:shared_preferences/shared_preferences.dart';

import 'settings_repository.dart';

/// การตั้งค่าแบบ key/value เก็บใน shared_preferences
class LocalSettingsRepository implements SettingsRepository {
  SharedPreferences? _prefs;

  LocalSettingsRepository() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  @override
  T? get<T>(String key) {
    if (_prefs == null) return null;
    return _prefs!.get(key) as T?;
  }

  @override
  Future<void> set<T>(String key, T value) async {
    if (_prefs == null) return;
    switch (value) {
      case final int v:
        await _prefs!.setInt(key, v);
      case final String v:
        await _prefs!.setString(key, v);
      case final bool v:
        await _prefs!.setBool(key, v);
      case final double v:
        await _prefs!.setDouble(key, v);
      case final List<String> v:
        await _prefs!.setStringList(key, v);
      default:
        await _prefs!.setString(key, value.toString());
    }
  }

  @override
  Future<void> remove(String key) async {
    if (_prefs == null) return;
    await _prefs!.remove(key);
  }

  @override
  Map<String, dynamic>? getJson(String key) =>
      SettingsJson.decode(get<String>(key));

  @override
  Future<void> setJson(String key, Map<String, dynamic> value) =>
      set<String>(key, SettingsJson.encode(value));
}
