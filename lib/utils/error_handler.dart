import 'dart:async';

import 'package:flutter/foundation.dart';

import '../repositories/settings_repository.dart';
import '../repositories/local_settings_repository.dart';

/// จัดการข้อผิดพลาดทั่วทั้งแอป — บันทึก log ลง settings repository
/// ติดตั้งผ่าน FlutterError.onError ใน main.dart
class ErrorHandler {
  static const String _errorLogKey = 'error_log_entries';
  static const int _maxLogEntries = 50;

  final SettingsRepository _settings;

  ErrorHandler({SettingsRepository? settings})
      : _settings = settings ?? LocalSettingsRepository();

  /// ติดตั้ง handler สำหรับ FlutterError และ PlatformException
  static void install({SettingsRepository? settings}) {
    final handler = ErrorHandler(settings: settings);

    FlutterError.onError = (FlutterErrorDetails details) async {
      if (kDebugMode) {
        FlutterError.dumpErrorToConsole(details);
      }
      await handler.record(details.exception.toString(), details.stack);
    };

    // จัดการ error ที่เกิดนอกเฟรมเวิร์ก Flutter (isolate error)
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      handler.record(error.toString(), stack);
      return true;
    };
  }

  /// บันทึกข้อผิดพลาดลง settings (เก็บสูงสุด _maxLogEntries รายการ)
  Future<void> record(String error, [StackTrace? stackTrace]) async {
    try {
      final existing = _settings.getStringList(_errorLogKey, <String>[]);
      final timestamp = DateTime.now().toIso8601String();
      final entry = '$timestamp | $error${stackTrace != null ? '\n$stackTrace' : ''}';

      final updated = <String>[];
      updated.add(entry);
      updated.addAll(existing.take(_maxLogEntries - 1));

      await _settings.setStringList(_errorLogKey, updated);
    } catch (_) {
      // ถ้าเซฟ log ล้มเหลว ให้ข้ามไป ไม่ทำให้แอปหยุดทำงาน
    }
  }

  /// อ่าน error log ทั้งหมด (ลำดับใหม่ก่อน)
  List<String> getErrorLog() {
    return _settings.getStringList(_errorLogKey, <String>[]);
  }

  /// ลบ error log ทั้งหมด
  Future<void> clearErrorLog() async {
    await _settings.remove(_errorLogKey);
  }
}

/// Extension สำหรับอ่าน string list จาก settings repository
extension SettingsStringList on SettingsRepository {
  List<String> getStringList(String key, List<String> defaultValue) {
    try {
      final raw = getString(key, '');
      if (raw.isEmpty) return defaultValue;
      return raw.split('|||').where((s) => s.isNotEmpty).toList();
    } catch (_) {
      return defaultValue;
    }
  }

  Future<void> setStringList(String key, List<String> values) async {
    await setString(key, values.join('|||'));
  }
}
