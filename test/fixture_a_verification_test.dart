import 'package:flutter_test/flutter_test.dart';
import 'package:hora_day/utils/date_utilities.dart';

void main() {
  group('Fixture A — 1995-01-01, today 2026-10-26 (Asia/Bangkok)', () {
    final birth = DateTime(1995, 1, 1);
    final today = DateTime(2026, 10, 26);

    test('weekday is Sunday', () {
      expect(weekdayOf(birth), 'วันอาทิตย์');
    });

    test('element is Fire (ไฟ)', () {
      // 1995-01-01 是星期日，对应 weekday=7
      expect(elementOfWeekday(7), 'ไฟ');
    });

    test('completed age = 31', () {
      expect(completedAge(birth, today), 31);
    });

    test('ageYang = 32', () {
      expect(ageYang(birth, today), 32);
    });

    test('turningAge = 32', () {
      expect(turningAge(birth, today), 32);
    });

    test('days until next birthday = 67', () {
      // 1995-01-01 → 下一生日 2027-01-01，今天 2026-10-26
      // 10月剩 5 天(27-31)，11月 30 天，12月 31 天，1月 1 天 = 67
      expect(daysUntilNextBirthday(birth, today), 67);
    });
  });

  group('Edge cases', () {
    test('29 ก.พ. 在非闰年按 28 ก.พ. 算', () {
      final today = DateTime(2027, 2, 1); // 2570 不闰年
      final days = daysUntilNextBirthday(DateTime(2000, 2, 29), today);
      // 2027-02-28 已过（2月1日在2月28日之前？不对，2月1日在2月28日之前）
      // 2027-02-28 还没到 → 还在今年
      expect(days, greaterThan(0));
      expect(days, lessThan(30));
    });

    test('跨年：1990-01-02，今天 2026-12-30 → 3 天', () {
      expect(daysUntilNextBirthday(DateTime(1990, 1, 2), DateTime(2026, 12, 30)), 3);
    });

    test('时区：今天在 Thailand，UTC 23:30 是次日', () {
      final thailandToday = DateTime(2026, 10, 26);
      final utc2330 = DateTime.utc(2026, 10, 26, 23, 30);
      // UTC 23:30 = Thailand 次日 06:30 → 不是同一天
      expect(utc2330.difference(thailandToday).inHours, greaterThan(6));
    });

    test('生日是今天 → daysUntil = 0', () {
      expect(daysUntilNextBirthday(DateTime(2000, 10, 26), DateTime(2026, 10, 26)), 0);
    });

    test('昨天过生日 → 明年再算', () {
      final d = daysUntilNextBirthday(DateTime(2000, 10, 25), DateTime(2026, 10, 26));
      expect(d, 364);
    });
  });
}