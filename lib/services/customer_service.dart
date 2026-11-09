import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/customer.dart';
import '../repositories/client_repository.dart';
import '../repositories/local_client_repository.dart';
import '../repositories/supabase_client_repository.dart';
import '../repositories/local_settings_repository.dart';
import '../repositories/settings_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service จัดการข้อมูลลูกค้า — delegate ทั้งหมดผ่าน ClientRepository
/// UI คุยกับ CustomerService ซึ่งภายในคุยกับ repository interface เท่านั้น
class CustomerService extends ChangeNotifier {
  final ClientRepository _repository;
  final SettingsRepository? _settings;
  bool _disposed = false;
  StreamSubscription<List<Customer>>? _watchSubscription;

  List<Customer> get customers => _repository.customers;

  List<Customer> get deletedCustomers => _repository.deletedCustomers;

  /// threshold วันสำหรับ "ใกล้วันเกิด" อ่านจาก settings (default 30)
  int get nearBirthdayThreshold {
    return _settings?.getInt('near_birthday_threshold', 30) ?? 30;
  }

  Future<void> setNearBirthdayThreshold(int days) async {
    await _settings?.setInt('near_birthday_threshold', days);
    notifyListeners();
  }

  CustomerService({
    ClientRepository? repository,
    SettingsRepository? settings,
  })  : _repository = repository ?? _defaultRepository(),
        _settings = settings ?? LocalSettingsRepository() {
    _startWatching();
  }

  static ClientRepository _defaultRepository() {
    try {
      final supabase = Supabase.instance.client;
      return SupabaseClientRepository(supabase);
    } catch (_) {
      return LocalClientRepository();
    }
  }

  void _startWatching() {
    _watchSubscription = _repository.watchCustomers().listen((_) {
      if (!_disposed) notifyListeners();
    });
  }

  /// ดึงรายชื่อลูกค้าที่เกิดในวันนี้
  List<Customer> get todayBirthdayCustomers =>
      _repository.todayBirthdayCustomers;

  /// ดึงรายชื่อลูกค้าที่ใกล้ถึงวันเกิด (ตาม threshold จาก settings)
  List<Customer> get upcomingBirthdayCustomers {
    return _repository.upcomingBirthdayCustomersWithin(nearBirthdayThreshold);
  }

  /// ดึงรายชื่อลูกค้าที่เกิดในเดือนปัจจุบัน
  List<Customer> get thisMonthBirthdayCustomers =>
      _repository.thisMonthBirthdayCustomers;

  /// ดึงรายชื่อลูกค้าที่มีบันทึกดวงชะตา
  List<Customer> get customersWithNotes => _repository.customersWithNotes;

  /// ค้นหาและกรองลูกค้า
  List<Customer> search(String query, {bool onlyUpcomingBirthdays = false}) {
    return _repository.search(
      query,
      onlyUpcomingBirthdays: onlyUpcomingBirthdays,
      withinDays: nearBirthdayThreshold,
    );
  }

  /// ค้นหาลูกค้าตาม id
  Customer? getCustomerById(String id) => _repository.getCustomerById(id);

  Future<void> addCustomer(Customer customer) async {
    await _repository.addCustomer(customer);
  }

  Future<void> updateCustomer(Customer customer) async {
    await _repository.updateCustomer(customer);
  }

  /// Soft delete — ตั้ง deletedAt (ไม่ลบจริง) แล้วแจ้งเตือน undo ได้
  Future<void> softDeleteCustomer(String id) async {
    await _repository.softDeleteCustomer(id);
  }

  /// กู้คืนจากถังขยะ
  Future<void> restoreCustomer(String id) async {
    await _repository.restoreCustomer(id);
  }

  /// ลบถาวร (ใช้กับถังขยะเท่านั้น)
  Future<void> hardDeleteCustomer(String id) async {
    await _repository.hardDeleteCustomer(id);
  }

  /// API เดิมไว้ใช้กับ views ที่ยังเรียก deleteCustomer (จะถูกเปลี่ยนเป็น soft delete ในเฟสถัดไป)
  Future<void> deleteCustomer(String id) async {
    await softDeleteCustomer(id);
  }

  bool get isUsingSupabase => _repository is SupabaseClientRepository;

  @override
  void notifyListeners() {
    if (_disposed) return;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _watchSubscription?.cancel();
    final repo = _repository;
    if (repo is LocalClientRepository) {
      repo.dispose();
    } else if (repo is SupabaseClientRepository) {
      repo.dispose();
    }
    super.dispose();
  }
}
