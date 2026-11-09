// ยูทิลิตีวันที่และอายุสำหรับแอป Hora Day
// ฟังก์ชันเหล่านี้เป็น pure function ไม่พึ่งพา BuildContext หรือ state ของแอป

import 'package:intl/intl.dart';

/// แปลงปี ค.ศ. เป็นปี พ.ศ. (บวก 543)
int toBuddhistYear(int gregorianYear) => gregorianYear + 543;

/// แปลงปี พ.ศ. เป็นปี ค.ศ. (ลบ 543)
int fromBuddhistYear(int buddhistYear) => buddhistYear - 543;

/// จัดรูปแบบวันที่เป็นภาษาไทย
/// [short] = true ให้รูปแบบย่อ เช่น 15 ต.ค. 2569
/// [short] = false ให้รูปแบบเต็ม เช่น 15 ตุลาคม 2569
String formatThaiDate(DateTime date, {bool short = false}) {
  final buddhistYear = toBuddhistYear(date.year);
  if (short) {
    const shortMonths = [
      'ม.ค.', 'ก.พ.', 'มี.ค.', 'เม.ย.', 'พ.ค.', 'มิ.ย.',
      'ก.ค.', 'ส.ค.', 'ก.ย.', 'ต.ค.', 'พ.ย.', 'ธ.ค.',
    ];
    return '${date.day} ${shortMonths[date.month - 1]} $buddhistYear';
  }
  const months = [
    'มกราคม', 'กุมภาพันธ์', 'มีนาคม', 'เมษายน', 'พฤษภาคม', 'มิถุนายน',
    'กรกฎาคม', 'สิงหาคม', 'กันยายน', 'ตุลาคม', 'พฤศจิกายน', 'ธันวาคม',
  ];
  return '${date.day} ${months[date.month - 1]} $buddhistYear';
}

/// จัดรูปแบบวันที่และเวลาเป็นภาษาไทย
String formatThaiDateTime(DateTime dateTime, {bool short = false}) {
  final datePart = formatThaiDate(dateTime, short: short);
  final timePart = DateFormat.Hm().format(dateTime);
  return '$datePart $timePart น.';
}

/// คำนวณจำนวนวันจนถึงวันเกิดครั้งถัดไป
/// กรณีวันเกิดตรงกับ 29 ก.พ. และปีที่คำนวณไม่ใช่ปีอธิกสุรทิน ให้ใช้ 28 ก.พ. แทน
int daysUntilNextBirthday(DateTime birthDate, DateTime today) {
  final todayDate = DateTime(today.year, today.month, today.day);
  final birthMonth = birthDate.month;
  final birthDay = birthDate.day;

  // ปรับวันเกิด 29 ก.พ. เป็น 28 ก.พ. ในปีที่ไม่ใช่ปีอธิกสุรทิน
  int adjustedDay = birthDay;
  if (birthMonth == 2 && birthDay == 29) {
    final isLeap = _isLeapYear(today.year);
    if (!isLeap) adjustedDay = 28;
  }

  var nextBirthday = DateTime(today.year, birthMonth, adjustedDay);
  if (nextBirthday.isBefore(todayDate)) {
    final nextYear = today.year + 1;
    int nextAdjustedDay = birthDay;
    if (birthMonth == 2 && birthDay == 29) {
      if (!_isLeapYear(nextYear)) nextAdjustedDay = 28;
    }
    nextBirthday = DateTime(nextYear, birthMonth, nextAdjustedDay);
  }

  return nextBirthday.difference(todayDate).inDays;
}

/// ตรวจสอบว่าปีใดปีหนึ่งเป็นปีอธิกสุรทินหรือไม่
bool _isLeapYear(int year) {
  return year % 4 == 0 && (year % 100 != 0 || year % 400 == 0);
}

/// คำนวณอายุเต็มปี (completed age) ณ วันที่กำหนด
int completedAge(DateTime birthDate, DateTime today) {
  int age = today.year - birthDate.year;
  if (today.month < birthDate.month ||
      (today.month == birthDate.month && today.day < birthDate.day)) {
    age--;
  }
  return age < 0 ? 0 : age;
}

/// คำนวณอายุตามหลักโหราศาสตร์ไทย (อายุยาง)
/// อายุยางคืออายุที่นับจากปีเกิดถึงปีปัจจุบัน โดยนับรวมปีเกิดเป็นปีแรก
int ageYang(DateTime birthDate, DateTime today) {
  return today.year - birthDate.year + 1;
}

/// คำนวณอายุที่จะถึงในปีนี้ (turning age)
/// อายุที่จะมีในวันเกิดรอบถัดไป
int turningAge(DateTime birthDate, DateTime today) {
  final todayDate = DateTime(today.year, today.month, today.day);
  final thisYearBirthday = DateTime(today.year, birthDate.month, birthDate.day);
  final nextBirthdayYear =
      thisYearBirthday.isBefore(todayDate) ? today.year + 1 : today.year;
  return nextBirthdayYear - birthDate.year;
}

/// ชื่อวันในสัปดาห์ตามภาษาไทย (จันทร์ - อาทิตย์)
String weekdayOf(DateTime date) {
  const days = [
    'วันจันทร์', 'วันอังคาร', 'วันพุธ', 'วันพฤหัสบดี',
    'วันศุกร์', 'วันเสาร์', 'วันอาทิตย์',
  ];
  return days[date.weekday - 1];
}

/// ตัวย่อวันในสัปดาห์ภาษาไทย (จ., อ., พ., พฤ., ศ., ส., อา.)
String weekdayAbbrOf(DateTime date) {
  const abbrs = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
  return abbrs[date.weekday - 1];
}

/// ธาตุประจำวันเกิด (ดิน, น้ำ, ลม, ไฟ)
String elementOfWeekday(int weekday) {
  switch (weekday) {
    case 1: // จันทร์
      return 'ดิน';
    case 2: // อังคาร
      return 'ลม';
    case 3: // พุธ
      return 'น้ำ';
    case 4: // พฤหัสบดี
      return 'ดิน';
    case 5: // ศุกร์
      return 'น้ำ';
    case 6: // เสาร์
      return 'ไฟ';
    case 7: // อาทิตย์
      return 'ไฟ';
    default:
      return 'ดิน';
  }
}

/// สีมงคลประจำวันเกิด
String auspiciousColorOfWeekday(int weekday) {
  switch (weekday) {
    case 1: return 'สีเหลือง / ขาว';
    case 2: return 'สีชมพู';
    case 3: return 'สีเขียว';
    case 4: return 'สีส้ม / ทอง';
    case 5: return 'สีฟ้า / น้ำเงิน';
    case 6: return 'สีม่วง / ดำ';
    case 7: return 'สีแดง';
    default: return 'สีมงคล';
  }
}

/// ทิศมงคลประจำวันเกิด
String auspiciousDirectionOfWeekday(int weekday) {
  switch (weekday) {
    case 1: return 'ทิศตะวันออก';
    case 2: return 'ทิศตะวันออกเฉียงใต้';
    case 3: return 'ทิศใต้';
    case 4: return 'ทิศตะวันตกเฉียงใต้';
    case 5: return 'ทิศตะวันตก';
    case 6: return 'ทิศตะวันตกเฉียงเหนือ';
    case 7: return 'ทิศตะวันออกเฉียงเหนือ';
    default: return 'ทิศตะวันออก';
  }
}

/// ตรวจสอบว่าวันที่กำหนดเป็นวันที่ 29 กุมภาพันธ์หรือไม่
bool isFeb29(DateTime date) => date.month == 2 && date.day == 29;
