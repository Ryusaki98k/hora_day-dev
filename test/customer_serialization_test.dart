import 'package:flutter_test/flutter_test.dart';
import 'package:hora_day/models/customer.dart';

void main() {
  group('Customer.toSupabaseMap', () {
    test('บันทึก province และ last_consultation_date ครบ (regression: เคยหายจาก payload)', () {
      final customer = Customer(
        id: '1',
        fullName: 'ทดสอบ หนึ่ง',
        nickname: 'เทส',
        birthDate: DateTime(1990, 5, 20),
        birthTime: '08:30 น.',
        lineId: 'test_line',
        phone: '0812345678',
        province: 'กรุงเทพมหานคร',
        address: '123 ถนนสุขุมวิท',
        notes: 'บันทึกคำพยากรณ์',
        lastConsultationDate: DateTime(2026, 1, 15, 10, 30),
      );

      final map = customer.toSupabaseMap(isInsert: true);

      expect(map['province'], 'กรุงเทพมหานคร',
          reason: 'province ต้องถูกเขียนลง payload — คอลัมน์มีอยู่จริงใน schema');
      expect(map.containsKey('last_consultation_date'), isTrue,
          reason: 'last_consultation_date ต้องถูกเขียนลง payload ทั้ง insert และ update');
      expect(DateTime.parse(map['last_consultation_date'] as String).year, 2026);

      // วน round-trip ผ่าน fromMap ต้องได้ข้อมูลกลับมาครบ
      final roundTrip = Customer.fromMap({
        ...map,
        'id': 1,
        'created_at': '2026-01-01T00:00:00+00:00',
      });
      expect(roundTrip.province, 'กรุงเทพมหานคร');
      expect(roundTrip.lastConsultationDate, isNotNull);
      expect(roundTrip.lastConsultationDate!.year, 2026);
      expect(roundTrip.birthTime, '08:30 น.');
    });

    test('last_consultation_date เป็น null ได้ และprovince ว่างส่งเป็นค่าว่าง', () {
      final customer = Customer(
        id: '2',
        fullName: 'ทดสอบ สอง',
        nickname: '',
        birthDate: DateTime(2000, 1, 1),
        lineId: '',
        phone: '',
        province: '',
        address: '',
      );

      final map = customer.toSupabaseMap(isInsert: true);
      expect(map['province'], '');
      expect(map['last_consultation_date'], isNull,
          reason: 'ค่าว่างต้องส่ง null ชัดเจนเพื่อให้ upsert ล้างค่าเดิมได้');
    });

    test('time ว่างแปลงเป็น 00:00:00 ตาม type time ของ PostgreSQL', () {
      final customer = Customer(
        id: '3',
        fullName: 'ทดสอบ สาม',
        nickname: '',
        birthDate: DateTime(1995, 7, 7),
        lineId: '',
        phone: '',
        province: '',
        address: '',
        birthTime: null,
      );
      expect(customer.toSupabaseMap()['birth_time'], '00:00:00');
    });
  });
}
