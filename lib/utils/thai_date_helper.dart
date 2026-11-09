class ThaiDateHelper {
  static const months = [
    'มกราคม',
    'กุมภาพันธ์',
    'มีนาคม',
    'เมษายน',
    'พฤษภาคม',
    'มิถุนายน',
    'กรกฎาคม',
    'สิงหาคม',
    'กันยายน',
    'ตุลาคม',
    'พฤศจิกายน',
    'ธันวาคม',
  ];

  static const shortMonths = [
    'ม.ค.',
    'ก.พ.',
    'มี.ค.',
    'เม.ย.',
    'พ.ค.',
    'มิ.ย.',
    'ก.ค.',
    'ส.ค.',
    'ก.ย.',
    'ต.ค.',
    'พ.ย.',
    'ธ.ค.',
  ];

  /// รูปแบบย่อ: เช่น 15 ต.ค. 2538
  static String formatShort(DateTime date) {
    return '${date.day} ${shortMonths[date.month - 1]} ${date.year + 543}';
  }

  /// รูปแบบเต็ม: เช่น 15 ตุลาคม 2538
  static String formatFull(DateTime date) {
    return '${date.day} ${months[date.month - 1]} ${date.year + 543}';
  }

  /// วันและเดือน: เช่น 15 ตุลาคม
  static String formatDayMonth(DateTime date) {
    return '${date.day} ${months[date.month - 1]}';
  }

  /// ชื่อเดือนตามเลข 1-12
  static String monthName(int month) {
    if (month < 1 || month > 12) return '';
    return months[month - 1];
  }

  /// เดือนและปี พ.ศ. เช่น กันยายน 2569
  static String formatMonthYear(DateTime date) {
    return '${months[date.month - 1]} ${date.year + 543}';
  }

  /// ชื่อเดือนปัจจุบัน
  static String currentMonthName() {
    return months[DateTime.now().month - 1];
  }

  static const daysOfWeek = [
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];

  /// ชื่อวันในสัปดาห์
  static String dayOfWeekName(int weekday) {
    if (weekday < 1 || weekday > 7) return '';
    return daysOfWeek[weekday - 1];
  }

  /// สีมงคลและธาตุประจำวันเกิด
  static String dayAuspiciousColor(int weekday) {
    switch (weekday) {
      case 1:
        return 'สีเหลือง / ขาว (ธาตุดิน)';
      case 2:
        return 'สีชมพู (ธาตุลม)';
      case 3:
        return 'สีเขียว (ธาตุน้ำ)';
      case 4:
        return 'สีส้ม / ทอง (ธาตุดิน)';
      case 5:
        return 'สีฟ้า / น้ำเงิน (ธาตุน้ำ)';
      case 6:
        return 'สีม่วง / ดำ (ธาตุไฟ)';
      case 7:
        return 'สีแดง (ธาตุไฟ)';
      default:
        return 'สีมงคล';
    }
  }

  /// ทิศมงคลประจำวัน (ทิศโชคลาภ-บารมี)
  static String dayAuspiciousDirection(int weekday) {
    switch (weekday) {
      case 1:
        return 'ทิศตะวันออก (เสน่ห์เมตตา)';
      case 2:
        return 'ทิศตะวันออกเฉียงใต้ (โชคลาภ)';
      case 3:
        return 'ทิศใต้ (อำนาจบารมี)';
      case 4:
        return 'ทิศตะวันตกเฉียงใต้ (ปัญญาการค้า)';
      case 5:
        return 'ทิศตะวันตก (ความเจริญก้าวหน้า)';
      case 6:
        return 'ทิศตะวันตกเฉียงเหนือ (ความมั่นคง)';
      case 7:
        return 'ทิศตะวันออกเฉียงเหนือ (ชัยชนะเกียรติยศ)';
      default:
        return 'ทิศตะวันออก';
    }
  }

  /// ฤกษ์มงคลประจำวันตามหลักโหราศาสตร์
  static String dayAuspiciousRerk(int weekday) {
    switch (weekday) {
      case 1:
        return 'มหัทธโนฤกษ์ (09:19 - 10:45 น.)';
      case 2:
        return 'ภูมิปาโลฤกษ์ (10:29 - 11:59 น.)';
      case 3:
        return 'ราชาฤกษ์ (13:39 - 15:00 น.)';
      case 4:
        return 'เทวีฤกษ์ (08:49 - 10:15 น.)';
      case 5:
        return 'มหัทธโนฤกษ์ (11:09 - 12:35 น.)';
      case 6:
        return 'ราชาฤกษ์ (14:19 - 15:45 น.)';
      case 7:
        return 'ภูมิปาโลฤกษ์ (09:39 - 11:05 น.)';
      default:
        return 'มหัทธโนฤกษ์';
    }
  }

  /// พรมงคลและข้อคิดคำพยากรณ์ประจำวัน
  static Map<String, String> getDailyBlessing(int weekday) {
    switch (weekday) {
      case 1:
        return {
          'title': 'จันทร์ผ่องอำนวยโชค',
          'description': 'เหมาะแก่การส่งต่อไมตรี วาจาสุภาพนำพาความสำเร็จ เจรจาการงานราบรื่นและปิดการขายมงคล',
          'mantra': 'โอม จันทรา ศศิประภา มหาลาภัง ภวันตุ เม',
        };
      case 2:
        return {
          'title': 'อังคารเดชานุภาพ',
          'description': 'ความมุ่งมั่นและกล้าหาญนำพาชัยชนะ งานที่ท้าทายจะคลี่คลายด้วยความเด็ดเดี่ยวรอบคอบ',
          'mantra': 'โอม ภุมมายะ นะมะหะ มหาเตชัง ประสิทธิ เม',
        };
      case 3:
        return {
          'title': 'พุธสุริยะปัญญา',
          'description': 'วาจาเป็นทรัพย์ สื่อสารด้วยเมตตาย่อมมีผู้คล้อยตาม การค้าและการให้คำปรึกษาเจริญรุ่งเรือง',
          'mantra': 'โอม พุธายะ สิทธิการัง ลาภัง สัพพะทา',
        };
      case 4:
        return {
          'title': 'พฤหัสบดีครูบารมี',
          'description': 'วันแห่งสติปัญญาและแสงสว่าง การอบรมถ่ายทอดความรู้และการอวยพรลูกดวงบังเกิดศุภผลยิ่งใหญ่',
          'mantra': 'โอม คุรุเว นะมะหะ มหาปัญโญ ประสิทธิ เม',
        };
      case 5:
        return {
          'title': 'ศุกร์โภคทรัพย์สุนทรีย์',
          'description': 'ลาภผลเนืองนอง การเงินหมุนเวียนคล่องตัว มิตรภาพรอบตัวนำพาความสุขและความรื่นรมย์',
          'mantra': 'โอม ศุกรายะ มหาธะนัง สัพพะสุขัง ภวันตุ เม',
        };
      case 6:
        return {
          'title': 'เสาร์มั่นคงยืนยง',
          'description': 'ความอดทนสร้างรากฐานดั่งขุนเขา ทรัพย์สินและการงานหยั่งรากลึกอย่างมั่นคงและปลอดภัย',
          'mantra': 'โอม สะเนศะรายะ นะมะหะ มหาถิรัง สัพพะสิทธิ เม',
        };
      case 7:
        return {
          'title': 'อาทิตย์เรืองรองเกียรติยศ',
          'description': 'พลังบารมีเปล่งประกาย ได้รับการยกย่องสรรเสริญ ผู้ใหญ่ให้การสนับสนุนอย่างมั่นคง',
          'mantra': 'โอม สุริยายะ นะมะหะ มหาเตโช ประสิทธิ เม',
        };
      default:
        return {
          'title': 'สิริมงคลสถาพร',
          'description': 'ขอให้เป็นวันที่เปี่ยมด้วยความสุข สงบ และโชคลาภในทุกก้าวย่าง',
          'mantra': 'สัพพะมังคะละมุปปันนัง',
        };
    }
  }
}
