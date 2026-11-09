import 'dart:async';

import 'package:flutter/material.dart';

import 'pin_store.dart';

/// สถานะล็อกแอป
enum AppLockState { unlocked, locked, enteringPin, failed }

/// ควบคุมการล็อกแอป: PIN + biometric (mobile) + เวลาหน่วงหลังผิด 5 ครั้ง
class AppLockController extends ChangeNotifier {
  final PinStore _pinStore;
  final bool _isWeb;

  AppLockState _state = AppLockState.locked;
  int _failCount = 0;
  DateTime? _lockoutUntil;

  AppLockController({
    required this._pinStore,
    required this._isWeb,
  }) {
    _loadState();
  }

  AppLockState get state => _state;
  int get failCount => _failCount;
  DateTime? get lockoutUntil => _lockoutUntil;
  bool get isLocked => _state == AppLockState.locked;
  bool get isInLockout => _lockoutUntil != null && _lockoutUntil!.isAfter(DateTime.now());
  bool get isWeb => _isWeb;

  Future<void> _loadState() async {
    _failCount = 0;
    _lockoutUntil = null;
    _state = AppLockState.locked;
    notifyListeners();
  }

  /// ตรวจสอบว่าแอปควรล็อกหรือไม่ (หลังอยู่พื้นหลังเกินเวลาที่ตั้ง)
  Future<bool> shouldLock() async {
    try {
      final hasPin = await _pinStore.hasPin();
      return hasPin;
    } catch (_) {
      return false;
    }
  }

  /// เรียกเมื่อแอปไปอยู่พื้นหลัง
  Future<void> onBackground() async {
    final hasPin = await _pinStore.hasPin();
    if (!hasPin) return;
    _state = AppLockState.locked;
    notifyListeners();
  }

  /// เรียกเมื่อแอปกลับมาอยู่เบื้องหน้า
  Future<void> onForeground() async {
    final hasPin = await _pinStore.hasPin();
    if (!hasPin) {
      _state = AppLockState.unlocked;
      notifyListeners();
      return;
    }
    _state = AppLockState.locked;
    notifyListeners();
  }

  /// ยืนยัน PIN
  Future<bool> verifyPin(String pin) async {
    if (isInLockout) return false;

    final ok = await _pinStore.verifyPin(pin);
    if (ok) {
      _failCount = 0;
      _lockoutUntil = null;
      _state = AppLockState.unlocked;
      notifyListeners();
      return true;
    }

    _failCount++;
    if (_failCount >= 5) {
      final backoff = Duration(seconds: 30 * (1 << ((_failCount - 5) ~/ 1)));
      _lockoutUntil = DateTime.now().add(backoff);
      _state = AppLockState.failed;
      notifyListeners();

      Future.delayed(backoff, () {
        if (_lockoutUntil != null && _lockoutUntil!.isBefore(DateTime.now())) {
          _lockoutUntil = null;
          _failCount = 0;
          _state = AppLockState.locked;
          notifyListeners();
        }
      });
    } else {
      _state = AppLockState.failed;
      notifyListeners();
    }
    return false;
  }

  /// ตั้ง/เปลี่ยน PIN
  Future<void> setPin(String pin) => _pinStore.setPin(pin);

  /// ปิดใช้งาน PIN
  Future<void> clearPin() async {
    await _pinStore.clearPin();
    _state = AppLockState.unlocked;
    _failCount = 0;
    _lockoutUntil = null;
    notifyListeners();
  }

  /// เปิด/ปิดใช้งาน PIN
  Future<void> setPinEnabled(bool enabled) async {
    if (enabled) {
      _state = AppLockState.locked;
    } else {
      _state = AppLockState.unlocked;
      await clearPin();
    }
    notifyListeners();
  }
}
