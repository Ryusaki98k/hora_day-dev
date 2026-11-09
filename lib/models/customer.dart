import '../utils/date_utilities.dart' as date_utils;

class Customer {
  final String id;
  final String fullName;
  final String nickname;
  final DateTime birthDate;
  final String? birthTime; // เวลาเกิด เช่น 08:30 น.
  final String lineId;
  final String phone;
  final String province;
  final String address;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastConsultationDate;
  final DateTime? lastContactAt;
  final bool? consentGiven;
  final DateTime? consentAt;
  final String? consentNote;
  final DateTime? deletedAt;

  Customer({
    required this.id,
    required this.fullName,
    required this.nickname,
    required this.birthDate,
    this.birthTime,
    required this.lineId,
    required this.phone,
    required this.province,
    required this.address,
    this.notes = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastConsultationDate,
    this.lastContactAt,
    this.consentGiven,
    this.consentAt,
    this.consentNote,
    this.deletedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// คำนวณจำนวนวันจนถึงวันเกิดครั้งถัดไป โดยเทียบกับวันที่กำหนด (รองรับ 29 ก.พ. / ปีอธิกสุรทิน)
  int daysUntilBirthdayOn(DateTime today) {
    return date_utils.daysUntilNextBirthday(birthDate, today);
  }

  /// คำนวณจำนวนวันจนถึงวันเกิดครั้งถัดไป (0 = วันนี้, 1 = พรุ่งนี้, 2 = อีก 2 วัน)
  int get daysUntilNextBirthday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return daysUntilBirthdayOn(today);
  }

  /// ตรวจสอบว่าใกล้ถึงวันเกิดใน 1-2 วัน หรือวันนี้หรือไม่ โดยเทียบกับวันที่กำหนด
  bool isUpcomingBirthdayOn(DateTime today) {
    final days = daysUntilBirthdayOn(today);
    return days >= 0 && days <= 2;
  }

  /// ตรวจสอบว่าใกล้ถึงวันเกิดใน 1-2 วัน หรือวันนี้หรือไม่
  bool get isUpcomingBirthday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return isUpcomingBirthdayOn(today);
  }

  /// คำนวณอายุเต็มปีในวันเกิดรอบถัดไป
  int get turningAge {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final days = daysUntilBirthdayOn(today);
    final nextBirthdayDate = today.add(Duration(days: days));
    return nextBirthdayDate.year - birthDate.year;
  }

  /// อายุปัจจุบัน (ปี)
  int get currentAge {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return date_utils.completedAge(birthDate, today);
  }

  /// วันในสัปดาห์เกิดตามหลักโหราศาสตร์ไทย (จันทร์ - อาทิตย์)
  String get thaiDayOfWeek {
    const days = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์',
    ];
    return days[birthDate.weekday - 1];
  }

  /// คำย่อวันเกิดภาษาไทย (เช่น จ., อ., พ., พฤ., ศ., ส., อา.)
  String get thaiWeekdayAbbr {
    const abbrs = ['จ.', 'อ.', 'พ.', 'พฤ.', 'ศ.', 'ส.', 'อา.'];
    return abbrs[birthDate.weekday - 1];
  }

  /// ชื่อหลักสำหรับแสดงผล (ถ้าไม่มีชื่อ-นามสกุล จะแสดง LINE ID โดยอัตโนมัติ)
  String get displayName {
    final fn = fullName.trim();
    final nn = nickname.trim();
    final li = lineId.trim();

    if (fn.isNotEmpty) {
      if (nn.isNotEmpty) {
        return '$fn ($nn)';
      }
      return fn;
    }
    if (nn.isNotEmpty) {
      return nn;
    }
    if (li.isNotEmpty) {
      return li.startsWith('@') ? li : '@$li';
    }
    return 'ลูกดวง';
  }

  /// ชื่อสำหรับเรียกทักทายหรือใช้บนการ์ดอวยพร
  String get greetingName {
    final nn = nickname.trim();
    final fn = fullName.trim();
    final li = lineId.trim();

    if (nn.isNotEmpty) return nn;
    if (fn.isNotEmpty) return fn;
    if (li.isNotEmpty) return li.startsWith('@') ? li : '@$li';
    return 'ลูกดวง';
  }

  /// ตัวอักษรย่อสำหรับ Avatar Monogram (ปลอดภัย 100% ไม่เกิด RangeError)
  String get initialLetter {
    final nn = nickname.trim();
    if (nn.isNotEmpty) {
      return nn.substring(0, 1);
    }
    final fn = fullName.trim();
    if (fn.isNotEmpty) {
      return fn.substring(0, 1);
    }
    final li = lineId.replaceFirst('@', '').trim();
    if (li.isNotEmpty) {
      return li.substring(0, 1).toUpperCase();
    }
    return 'ล';
  }

  /// แปลงเวลาเกิดเป็นรูปแบบ Time ของ PostgreSQL (HH:mm:ss)
  static String formatTimeForSupabase(String? timeStr) {
    if (timeStr == null || timeStr.trim().isEmpty) {
      return '00:00:00';
    }
    final cleaned = timeStr.replaceAll('น.', '').replaceAll('น', '').trim();
    final parts = cleaned.split(RegExp(r'[:.]'));
    if (parts.length == 1) {
      final h = parts[0].padLeft(2, '0');
      return '$h:00:00';
    } else if (parts.length == 2) {
      final h = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      return '$h:$m:00';
    } else if (parts.length >= 3) {
      final h = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      final s = parts[2].padLeft(2, '0');
      return '$h:$m:$s';
    }
    return '00:00:00';
  }

  /// จัดรูปแบบเวลาเกิดสำหรับแสดงผลในหน้าจอ (เช่น 08:30 น.)
  static String? _parseDisplayBirthTime(dynamic rawTime) {
    if (rawTime == null) return null;
    final str = rawTime.toString().trim();
    if (str.isEmpty || str == '00:00:00' || str == '00:00') return null;
    final parts = str.replaceAll('น.', '').replaceAll('น', '').trim().split(':');
    if (parts.length >= 2) {
      final h = parts[0].padLeft(2, '0');
      final m = parts[1].padLeft(2, '0');
      return '$h:$m น.';
    }
    return str;
  }

  /// แปลงข้อมูลสำหรับส่งไปเก็บที่ Supabase (snake_case)
  Map<String, dynamic> toSupabaseMap({bool isInsert = false}) {
    final map = <String, dynamic>{
      'full_name': fullName,
      'nickname': nickname,
      'birth_date': birthDate.toIso8601String().split('T').first,
      'birth_time': formatTimeForSupabase(birthTime),
      'line_id': lineId,
      'phone': phone,
      'province': province,
      'address': address,
      'notes': notes,
      'last_consultation_date': lastConsultationDate?.toIso8601String(),
      'last_contact_at': lastContactAt?.toIso8601String(),
      'consent_given': consentGiven,
      'consent_at': consentAt?.toIso8601String(),
      'consent_note': consentNote,
      'updated_at': updatedAt.toUtc().toIso8601String(),
      'deleted_at': deletedAt?.toUtc().toIso8601String(),
    };
    // กรณีอัปเดต ถ้ามี numeric id ให้ส่งไปด้วย
    if (!isInsert && int.tryParse(id) != null) {
      map['id'] = int.parse(id);
    }
    return map;
  }

  /// แปลงข้อมูลสำหรับ Supabase / Database
  Map<String, dynamic> toMap() => toSupabaseMap();

  /// สร้าง Object จาก Map ของ Supabase (รองรับทั้ง snake_case และ camelCase)
  factory Customer.fromMap(Map<String, dynamic> map, [String? docId]) {
    final rawDate = map['birth_date'] ?? map['birthDate'];
    DateTime parsedBirthDate = DateTime.now();
    if (rawDate != null) {
      parsedBirthDate = DateTime.tryParse(rawDate.toString()) ?? DateTime.now();
    }

    final rawCreated = map['created_at'] ?? map['createdAt'];
    DateTime parsedCreated = DateTime.now();
    if (rawCreated != null) {
      parsedCreated = DateTime.tryParse(rawCreated.toString()) ?? DateTime.now();
    }

    final rawConsultation = map['last_consultation_date'] ?? map['lastConsultationDate'];
    DateTime? parsedConsultation;
    if (rawConsultation != null) {
      parsedConsultation = DateTime.tryParse(rawConsultation.toString());
    }

    final rawUpdated = map['updated_at'] ?? map['updatedAt'];
    DateTime? parsedUpdated;
    if (rawUpdated != null) {
      parsedUpdated = DateTime.tryParse(rawUpdated.toString());
    }

    final rawDeleted = map['deleted_at'] ?? map['deletedAt'];
    DateTime? parsedDeleted;
    if (rawDeleted != null) {
      parsedDeleted = DateTime.tryParse(rawDeleted.toString());
    }

    final rawLastContact = map['last_contact_at'] ?? map['lastContactAt'];
    DateTime? parsedLastContact;
    if (rawLastContact != null) {
      parsedLastContact = DateTime.tryParse(rawLastContact.toString());
    }

    final rawConsentGiven = map['consent_given'] ?? map['consentGiven'];
    bool? parsedConsentGiven;
    if (rawConsentGiven != null) {
      parsedConsentGiven = rawConsentGiven is bool
          ? rawConsentGiven
          : (rawConsentGiven.toString().toLowerCase() == 'true');
    }

    final rawConsentAt = map['consent_at'] ?? map['consentAt'];
    DateTime? parsedConsentAt;
    if (rawConsentAt != null) {
      parsedConsentAt = DateTime.tryParse(rawConsentAt.toString());
    }

    final rawConsentNote = map['consent_note'] ?? map['consentNote'];
    String? parsedConsentNote;
    if (rawConsentNote != null) {
      parsedConsentNote = rawConsentNote.toString();
    }

    return Customer(
      id: docId ?? map['id']?.toString() ?? '',
      fullName: (map['full_name'] ?? map['fullName'] ?? '').toString(),
      nickname: (map['nickname'] ?? '').toString(),
      birthDate: parsedBirthDate,
      birthTime: _parseDisplayBirthTime(map['birth_time'] ?? map['birthTime']),
      lineId: (map['line_id'] ?? map['lineId'] ?? '').toString(),
      phone: (map['phone'] ?? '').toString(),
      province: (map['province'] ?? '').toString(),
      address: (map['address'] ?? '').toString(),
      notes: (map['notes'] ?? '').toString(),
      createdAt: parsedCreated,
      updatedAt: parsedUpdated,
      lastConsultationDate: parsedConsultation,
      lastContactAt: parsedLastContact,
      consentGiven: parsedConsentGiven,
      consentAt: parsedConsentAt,
      consentNote: parsedConsentNote,
      deletedAt: parsedDeleted,
    );
  }

  Customer copyWith({
    String? id,
    String? fullName,
    String? nickname,
    DateTime? birthDate,
    String? birthTime,
    String? lineId,
    String? phone,
    String? province,
    String? address,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastConsultationDate,
    DateTime? lastContactAt,
    bool? consentGiven,
    DateTime? consentAt,
    String? consentNote,
    DateTime? deletedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      lineId: lineId ?? this.lineId,
      phone: phone ?? this.phone,
      province: province ?? this.province,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      lastConsultationDate: lastConsultationDate ?? this.lastConsultationDate,
      lastContactAt: lastContactAt ?? this.lastContactAt,
      consentGiven: consentGiven ?? this.consentGiven,
      consentAt: consentAt ?? this.consentAt,
      consentNote: consentNote ?? this.consentNote,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
