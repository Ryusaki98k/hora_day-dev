import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/customer.dart';
import 'client_repository.dart';

/// Implementation ของ ClientRepository ด้วย Supabase (PostgreSQL + Realtime)
/// พร้อม in-memory cache จาก Realtime Stream เพื่อให้ synchronous getters ทำงานได้
class SupabaseClientRepository implements ClientRepository {
  final SupabaseClient _supabase;
  StreamSubscription<List<Customer>>? _realtimeSubscription;
  List<Customer> _cachedCustomers = [];

  SupabaseClientRepository(this._supabase) {
    _initStream();
  }

  void _initStream() {
    _realtimeSubscription = watchCustomers().listen((list) {
      _cachedCustomers = list;
    }, onError: (e) {
      // Stream error handling
    });
  }

  @override
  List<Customer> get customers => _cachedCustomers
      .where((c) => c.deletedAt == null)
      .toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  List<Customer> get deletedCustomers => _cachedCustomers
      .where((c) => c.deletedAt != null)
      .toList()
    ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Customer? getCustomerById(String id) {
    try {
      return _cachedCustomers.firstWhere((c) => c.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  List<Customer> get todayBirthdayCustomers {
    final now = DateTime.now();
    return _cachedCustomers.where((c) {
      if (c.deletedAt != null) return false;
      return c.birthDate.month == now.month && c.birthDate.day == now.day;
    }).toList();
  }

  @override
  List<Customer> get upcomingBirthdayCustomers =>
      upcomingBirthdayCustomersWithin(30);

  @override
  List<Customer> upcomingBirthdayCustomersWithin(int withinDays) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = _cachedCustomers.where((c) {
      if (c.deletedAt != null) return false;
      final days = c.daysUntilBirthdayOn(today);
      return days >= 0 && days <= withinDays;
    }).toList();
    result.sort((a, b) =>
        a.daysUntilBirthdayOn(today).compareTo(b.daysUntilBirthdayOn(today)));
    return result;
  }

  @override
  List<Customer> get thisMonthBirthdayCustomers {
    final now = DateTime.now();
    return _cachedCustomers.where((c) {
      if (c.deletedAt != null) return false;
      return c.birthDate.month == now.month;
    }).toList();
  }

  @override
  List<Customer> get customersWithNotes => _cachedCustomers
      .where((c) => c.deletedAt == null && c.notes.trim().isNotEmpty)
      .toList();

  @override
  List<Customer> search(
    String query, {
    bool onlyUpcomingBirthdays = false,
    int withinDays = 30,
  }) {
    final q = query.trim().toLowerCase();
    final today = onlyUpcomingBirthdays
        ? DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day)
        : null;

    return _cachedCustomers.where((c) {
      if (c.deletedAt != null) return false;
      final matchesQuery = q.isEmpty ||
          c.fullName.toLowerCase().contains(q) ||
          c.nickname.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          c.lineId.toLowerCase().contains(q) ||
          c.province.toLowerCase().contains(q);
      if (onlyUpcomingBirthdays && today != null) {
        return matchesQuery && c.isUpcomingBirthdayOn(today);
      }
      return matchesQuery;
    }).toList();
  }

  @override
  Stream<List<Customer>> watchCustomers() {
    return _supabase
        .from('customers')
        .stream(primaryKey: ['id'])
        .map((rows) {
          final list = rows
              .map((row) => Customer.fromMap(Map<String, dynamic>.from(row)))
              .toList();
          _cachedCustomers = list;
          return list;
        });
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    final payload = customer.toSupabaseMap(isInsert: true);
    await _supabase.from('customers').insert(payload).select();
    // เพิ่มเข้า cache ไว้ก่อนระหว่างรอ stream push
    final idx = _cachedCustomers.indexWhere((c) => c.id == customer.id);
    if (idx == -1) {
      _cachedCustomers.insert(0, customer);
    }
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final payload = customer.toSupabaseMap(isInsert: false);
    await _supabase.from('customers').update(payload).eq('id', customer.id);
    final idx = _cachedCustomers.indexWhere((c) => c.id == customer.id);
    if (idx != -1) {
      _cachedCustomers[idx] = customer;
    }
  }

  @override
  Future<void> softDeleteCustomer(String id) async {
    final now = DateTime.now();
    await _supabase.from('customers').update({
      'deleted_at': now.toUtc().toIso8601String(),
    }).eq('id', id);
    final idx = _cachedCustomers.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _cachedCustomers[idx] = _cachedCustomers[idx].copyWith(deletedAt: now);
    }
  }

  @override
  Future<void> restoreCustomer(String id) async {
    await _supabase.from('customers').update({'deleted_at': null}).eq('id', id);
    final idx = _cachedCustomers.indexWhere((c) => c.id == id);
    if (idx != -1) {
      _cachedCustomers[idx] = _cachedCustomers[idx].copyWith(deletedAt: null);
    }
  }

  @override
  Future<void> hardDeleteCustomer(String id) async {
    await _supabase.from('customers').delete().eq('id', id);
    _cachedCustomers.removeWhere((c) => c.id == id);
  }

  void dispose() {
    _realtimeSubscription?.cancel();
  }
}
