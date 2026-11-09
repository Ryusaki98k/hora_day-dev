import 'package:flutter_test/flutter_test.dart';

import 'package:hora_day/utils/date_utilities.dart';

void main() {
  group('toBuddhistYear', () {
    test('แปลงปี ค.ศ. เป็นปี พ.ศ. ได้ถูกต้อง', () {
      expect(toBuddhistYear(2026), 2569);
      expect(toBuddhistYear(1995), 2538);
      expect(toBuddhistYear(2000), 2543);
    });

    test('fromBuddhistYear แปลงกลับได้ถูกต้อง', () {
      expect(fromBuddhistYear(2569), 2026);
      expect(fromBuddhistYear(2538), 1995);
    });
  });

  group('formatThaiDate', () {
    test('รูปแบบเต็มแสดงวันที่ เดือน ปีพ.ศ.', () {
      expect(formatThaiDate(DateTime(2026, 10, 27)), '27 ตุลาคม 2569');
      expect(formatThaiDate(DateTime(2026, 1, 1)), '1 มกราคม 2569');
    });

    test('รูปแบบย่อแสดงวันที่ เดือนย่อ ปีพ.ศ.', () {
      expect(formatThaiDate(DateTime(2026, 10, 27), short: true), '27 ต.ค. 2569');
      expect(formatThaiDate(DateTime(2026, 1, 1), short: true), '1 ม.ค. 2569');
    });
  });

  group('formatThaiDateTime', () {
    test('แสดงวันที่และเวลาภาษาไทย', () {
      final result = formatThaiDateTime(DateTime(2026, 10, 27, 8, 30));
      expect(result, contains('27 ตุลาคม 2569'));
      expect(result, contains('08:30'));
    });
  });

  group('daysUntilNextBirthday', () {
    test('วันเกิดยังไม่ถึงในปีนี้ ให้คืนจำนวนวันเหลือ', () {
      // วันนี้ 27 ต.ค. 2569, วันเกิด 1 ม.ค. → อีกประมาณ 66 วัน
      final days = daysUntilNextBirthday(
        DateTime(1995, 1, 1),
        DateTime(2026, 10, 27),
      );
      expect(days, greaterThan(0));
      expect(days, lessThan(100));
    });

    test('วันเกิดผ่านไปแล้วในปีนี้ ให้คืนจำนวนวันในปีหน้า', () {
      // วันนี้ 27 ต.ค. 2569, วันเกิด 15 ต.ค. → ผ่านไปแล้ว ใช้ปีหน้า
      final days = daysUntilNextBirthday(
        DateTime(1995, 10, 15),
        DateTime(2026, 10, 27),
      );
      expect(days, greaterThan(0));
      expect(days, lessThan(366));
    });

    test('วันเกิดตรงกับวันนี้ ให้คืน 0', () {
      final days = daysUntilNextBirthday(
        DateTime(1995, 10, 27),
        DateTime(2026, 10, 27),
      );
      expect(days, 0);
    });

    test('วันเกิด 29 ก.พ. ในปีที่ไม่ใช่ปีอธิกสุรทิน ใช้ 28 ก.พ. แทน', () {
      // วันนี้ 1 มี.ค. 2569 (ไม่ใช่ปีอธิกสุรทิน), วันเกิด 29 ก.พ.
      final days = daysUntilNextBirthday(
        DateTime(1996, 2, 29),
        DateTime(2026, 3, 1),
      );
      // 28 ก.พ. 2569 ผ่านไปแล้ว (1 มี.ค. หลังจาก 28 ก.พ.) → รอปีหน้า
      expect(days, greaterThan(0));
    });

    test('วันเกิด 29 ก.พ. ในปีอธิกสุรทิน ใช้ 29 ก.พ. ตามจริง', () {
      // วันนี้ 1 ม.ค. 2572 (ปีอธิกสุรทิน), วันเกิด 29 ก.พ.
      final days = daysUntilNextBirthday(
        DateTime(1996, 2, 29),
        DateTime(2028, 1, 1),
      );
      // 29 ก.พ. 2572 ยังไม่ถึง → นับวันจนถึง 29 ก.พ.
      expect(days, greaterThan(0));
      expect(days, lessThan(60));
    });
  });

  group('completedAge', () {
    test('คำนวณอายุเต็มปีได้ถูกต้อง', () {
      // เกิด 1 ม.ค. 2538, วันนี้ 27 ต.ค. 2569 → อายุ 31 ปี (ยังไม่ถึงวันเกิดปี 2570)
      expect(completedAge(DateTime(1995, 1, 1), DateTime(2026, 10, 27)), 31);
    });

    test('ยังไม่ถึงวันเกิดในปีนี้ อายุจะน้อยลง 1 ปี', () {
      // เกิด 15 ต.ค. 2538, วันนี้ 27 ต.ค. 2569 → ถึงวันเกิดแล้ว อายุ 31
      expect(completedAge(DateTime(1995, 10, 15), DateTime(2026, 10, 27)), 31);

      // เกิด 1 พ.ย. 2538, วันนี้ 27 ต.ค. 2569 → ยังไม่ถึงวันเกิด อายุ 30
      expect(completedAge(DateTime(1995, 11, 1), DateTime(2026, 10, 27)), 30);
    });

    test('อายุไม่ติดลบแม้วันที่เกิดอยู่ในอนาคต', () {
      expect(completedAge(DateTime(2030, 1, 1), DateTime(2026, 10, 27)), 0);
    });
  });

  group('ageYang', () {
    test('อายุยางนับรวมปีเกิดเป็นปีแรก', () {
      expect(ageYang(DateTime(1995, 1, 1), DateTime(2026, 10, 27)), 32);
      expect(ageYang(DateTime(2026, 1, 1), DateTime(2026, 10, 27)), 1);
    });
  });

  group('turningAge', () {
    test('อายุที่จะถึงในปีนี้คำนวณได้ถูกต้อง', () {
      // เกิด 1 ม.ค. 2538, วันนี้ 27 ต.ค. 2569 → วันเกิดปีหน้าคือ 1 ม.ค. 2570 → อายุ 32
      expect(turningAge(DateTime(1995, 1, 1), DateTime(2026, 10, 27)), 32);
    });

    test('ยังไม่ถึงวันเกิดในปีนี้ อายุที่จะถึงคือปีถัดไป', () {
      // เกิด 15 ต.ค. 2538, วันนี้ 27 ต.ค. 2569 → วันเกิดปีนี้ผ่านไปแล้ว → 15 ต.ค. 2570 → อายุ 32
      expect(turningAge(DateTime(1995, 10, 15), DateTime(2026, 10, 27)), 32);

      // เกิด 1 พ.ย. 2538, วันนี้ 27 ต.ค. 2569 → ยังไม่ถึงวันเกิดปีนี้ → 1 พ.ย. 2569 → อายุ 31
      expect(turningAge(DateTime(1995, 11, 1), DateTime(2026, 10, 27)), 31);
    });
  });

  group('weekdayOf', () {
    test('คืนชื่อวันในสัปดาห์ภาษาไทย', () {
      expect(weekdayOf(DateTime(2026, 10, 27)), 'วันอังคาร');
      expect(weekdayOf(DateTime(2026, 10, 28)), 'วันพุธ');
      expect(weekdayOf(DateTime(2026, 11, 1)), 'วันอาทิตย์');
    });
  });

  group('weekdayAbbrOf', () {
    test('คืนตัวย่อวันในสัปดาห์ภาษาไทย', () {
      expect(weekdayAbbrOf(DateTime(2026, 10, 27)), 'อ.');
      expect(weekdayAbbrOf(DateTime(2026, 10, 28)), 'พ.');
      expect(weekdayAbbrOf(DateTime(2026, 11, 1)), 'อา.');
    });
  });

  group('elementOfWeekday', () {
    test('คืนธาตุประจำวันเกิด', () {
      expect(elementOfWeekday(1), 'ดิน'); // จันทร์
      expect(elementOfWeekday(2), 'ลม'); // อังคาร
      expect(elementOfWeekday(3), 'น้ำ'); // พุธ
      expect(elementOfWeekday(4), 'ดิน'); // พฤหัสบดี
      expect(elementOfWeekday(5), 'น้ำ'); // ศุกร์
      expect(elementOfWeekday(6), 'ไฟ'); // เสาร์
      expect(elementOfWeekday(7), 'ไฟ'); // อาทิตย์
    });
  });

  group('auspiciousColorOfWeekday', () {
    test('คืนสีมงคลประจำวันเกิด', () {
      expect(auspiciousColorOfWeekday(1), contains('เหลือง'));
      expect(auspiciousColorOfWeekday(2), contains('ชมพู'));
      expect(auspiciousColorOfWeekday(3), contains('เขียว'));
    });
  });

  group('auspiciousDirectionOfWeekday', () {
    test('คืนทิศมงคลประจำวันเกิด', () {
      expect(auspiciousDirectionOfWeekday(1), 'ทิศตะวันออก');
      expect(auspiciousDirectionOfWeekday(3), 'ทิศใต้');
      expect(auspiciousDirectionOfWeekday(7), 'ทิศตะวันออกเฉียงเหนือ');
    });
  });

  group('isFeb29', () {
    test('ตรวจสอบวันที่ 29 กุมภาพันธ์', () {
      expect(isFeb29(DateTime(2028, 2, 29)), true);
      expect(isFeb29(DateTime(2026, 2, 28)), false);
      expect(isFeb29(DateTime(2026, 3, 1)), false);
    });
  });
}
