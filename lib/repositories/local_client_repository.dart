import 'dart:async';

import '../models/customer.dart';
import 'client_repository.dart';

/// Implementation ของ ClientRepository ด้วยข้อมูลตัวอย่างในหน่วยความจำ
/// (ใช้เป็น fallback เมื่อ Supabase 不可用 และใช้สำหรับ unit test)
class LocalClientRepository implements ClientRepository {
  final List<Customer> _customers = [];
  final StreamController<List<Customer>> _controller =
      StreamController<List<Customer>>.broadcast();

  LocalClientRepository({List<Customer>? initialCustomers}) {
    if (initialCustomers != null && initialCustomers.isNotEmpty) {
      _customers.addAll(initialCustomers);
    } else {
      _loadSampleData();
    }
    _controller.add(List.unmodifiable(_customers));
  }

  void _loadSampleData() {
    final now = DateTime.now();
    _customers.addAll([
      Customer(
        id: '01',
        fullName: 'พิมพ์พิชชา วงศ์สวรรค์',
        nickname: 'น้องพิมพ์',
        birthDate: DateTime(1996, now.month, now.day),
        birthTime: '06:15 น.',
        lineId: 'pim_pitcha',
        phone: '089-123-4567',
        province: 'กรุงเทพมหานคร',
        address: '123/45 ถนนสุขุมวิท เขตวัฒนา',
        notes: 'ดูเรื่องการงานเปลี่ยนงานปลายปี และตรวจดวงความรัก',
        lastConsultationDate: now.subtract(const Duration(days: 14)),
      ),
      Customer(
        id: '02',
        fullName: 'กิตติศักดิ์ เจริญโภคทรัพย์',
        nickname: 'คุณบอส',
        birthDate: DateTime(1991, now.add(const Duration(days: 1)).month,
            now.add(const Duration(days: 1)).day),
        birthTime: '13:42 น.',
        lineId: 'boss_kitti',
        phone: '081-987-6543',
        province: 'เชียงใหม่',
        address: '88 หมู่ 2 ต.สุเทพ อ.เมือง',
        notes: 'ดูเรื่องการลงทุนธุรกิจส่วนตัว ดูฮวงจุ้ยร้านอาหาร',
        lastConsultationDate: now.subtract(const Duration(days: 30)),
      ),
      Customer(
        id: '03',
        fullName: 'ณัชชา สิริโสภา',
        nickname: 'นัท',
        birthDate: DateTime(1999, now.add(const Duration(days: 2)).month,
            now.add(const Duration(days: 2)).day),
        birthTime: '21:05 น.',
        lineId: 'nat_natcha',
        phone: '086-555-8899',
        province: 'นนทบุรี',
        address: '45/12 บางกรวย',
        notes: 'ดูเรื่องการเรียนต่อต่างประเทศ ทุนการศึกษา',
        lastConsultationDate: now.subtract(const Duration(days: 5)),
      ),
      Customer(
        id: '04',
        fullName: 'ธนวัฒน์ ศิริอักษร',
        nickname: 'เอก',
        birthDate: DateTime(1988, (now.month % 12) + 1, 15),
        birthTime: '10:00 น.',
        lineId: 'eak_thana',
        phone: '082-345-6789',
        province: 'ขอนแก่น',
        address: '99/5 ถนนมิตรภาพ',
        notes: 'ลูกดวงประจำ ตรวจดวงชะตาประจำปี',
        lastConsultationDate: now.subtract(const Duration(days: 60)),
      ),
    ]);
  }

  @override
  List<Customer> get customers => _customers
      .where((c) => c.deletedAt == null)
      .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  List<Customer> get deletedCustomers => _customers
      .where((c) => c.deletedAt != null)
      .toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

  @override
  Customer? getCustomerById(String id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  List<Customer> get todayBirthdayCustomers {
    final now = DateTime.now();
    return _customers.where((c) {
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
    final result = _customers.where((c) {
      if (c.deletedAt != null) return false;
      final days = c.daysUntilBirthdayOn(today);
      return days >= 0 && days <= withinDays;
    }).toList();
    result.sort((a, b) => a.daysUntilBirthdayOn(today).compareTo(b.daysUntilBirthdayOn(today)));
    return result;
  }

  @override
  List<Customer> get thisMonthBirthdayCustomers {
    final now = DateTime.now();
    return _customers.where((c) {
      if (c.deletedAt != null) return false;
      return c.birthDate.month == now.month;
    }).toList();
  }

  @override
  List<Customer> get customersWithNotes =>
      _customers.where((c) => c.deletedAt == null && c.notes.trim().isNotEmpty).toList();

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

    return _customers.where((c) {
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
  Stream<List<Customer>> watchCustomers() async* {
    yield List.unmodifiable(_customers.where((c) => c.deletedAt == null).toList());
    yield* _controller.stream.map((_) => List.unmodifiable(_customers.where((c) => c.deletedAt == null).toList()));
  }

  @override
  Future<void> addCustomer(Customer customer) async {
    _customers.insert(0, customer);
    _controller.add(List.unmodifiable(_customers));
  }

  @override
  Future<void> updateCustomer(Customer customer) async {
    final idx = _customers.indexWhere((c) => c.id == customer.id);
    if (idx != -1) {
      _customers[idx] = customer;
      _controller.add(List.unmodifiable(_customers));
    }
  }

  @override
  Future<void> softDeleteCustomer(String id) async {
    final idx = _customers.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final c = _customers[idx];
      _customers[idx] = c.copyWith(deletedAt: DateTime.now());
      _controller.add(List.unmodifiable(_customers));
    }
  }

  @override
  Future<void> restoreCustomer(String id) async {
    final idx = _customers.indexWhere((c) => c.id == id);
    if (idx != -1) {
      final c = _customers[idx];
      _customers[idx] = c.copyWith(deletedAt: null);
      _controller.add(List.unmodifiable(_customers));
    }
  }

  @override
  Future<void> hardDeleteCustomer(String id) async {
    _customers.removeWhere((c) => c.id == id);
    _controller.add(List.unmodifiable(_customers));
  }

  void dispose() {
    _controller.close();
  }
}
