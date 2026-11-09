import 'dart:async';

import '../models/customer.dart';

/// คลังข้อมูลลูกดวง — UI คุยผ่าน interface เท่านั้น เพื่อสลับ storage ได้ภายหลัง
abstract class ClientRepository {
  /// รายชื่อลูกดวงทั้งหมด (ไม่รวมที่ลบแล้ว / soft-deleted)
  List<Customer> get customers;

  /// ลูกดวงที่ลบแล้ว (soft-delete) สำหรับหน้าถังขยะ
  List<Customer> get deletedCustomers;

  /// ค้นหาลูกดวงตาม id
  Customer? getCustomerById(String id);

  /// ลูกดวงที่เกิดวันนี้
  List<Customer> get todayBirthdayCustomers;

  /// ลูกดวงที่ใกล้ถึงวันเกิด (ภายใน withinDays วัน ค่าเริ่มต้น 30)
  List<Customer> get upcomingBirthdayCustomers;

  /// ลูกดวงที่ใกล้ถึงวันกับ threshold ที่กำหนด
  List<Customer> upcomingBirthdayCustomersWithin(int withinDays);

  /// ลูกดวงที่เกิดในเดือนปัจจุบัน
  List<Customer> get thisMonthBirthdayCustomers;

  /// ลูกดวงที่มีบันทึก (notes ไม่ว่าง)
  List<Customer> get customersWithNotes;

  /// ค้นหาและกรอง (debounce จัดการที่ call site)
  List<Customer> search(
    String query, {
    bool onlyUpcomingBirthdays = false,
    int withinDays = 30,
  });

  /// รับ realtime stream ของรายชื่อลูกดวง
  Stream<List<Customer>> watchCustomers();

  Future<void> addCustomer(Customer customer);
  Future<void> updateCustomer(Customer customer);

  /// Soft delete — ตั้ง deletedAt ไม่ลบจริง
  Future<void> softDeleteCustomer(String id);

  /// กู้คืนจากถังขยะ
  Future<void> restoreCustomer(String id);

  /// ลบถาวร (ใช้กับถังขยะเท่านั้น)
  Future<void> hardDeleteCustomer(String id);
}
