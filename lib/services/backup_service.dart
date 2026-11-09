import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/customer.dart';
import '../repositories/client_repository.dart';
import '../repositories/local_client_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/local_settings_repository.dart';

/// เวอร์ชันรูปแบบไฟล์สำรอง (ใช้ตรวจสอบความเข้ากันได้ขณะนำเข้าข้อมูล)
const int backupFormatVersion = 1;

/// ผลลัพธ์การตรวจสอบไฟล์ก่อนนำเข้า (preview)
class BackupPreview {
  final int formatVersion;
  final int customerCount;
  final int deletedCount;
  final DateTime? exportedAt;
  final bool isCompatible;
  final String? incompatibilityReason;

  BackupPreview({
    required this.formatVersion,
    required this.customerCount,
    required this.deletedCount,
    this.exportedAt,
    required this.isCompatible,
    this.incompatibilityReason,
  });
}

/// บริการสำรองและกู้คืนข้อมูลลูกดวง (ส่งออกรูปแบบ JSON และ CSV)
class BackupService {
  static const String _jsonFileName = 'hora_day_backup.json';
  static const String _csvFileName = 'hora_day_backup.csv';

  final ClientRepository _repository;
  final SettingsRepository _settings;

  BackupService({
    ClientRepository? repository,
    SettingsRepository? settings,
  })  : _repository = repository ?? LocalClientRepository(),
        _settings = settings ?? LocalSettingsRepository();

  /// ส่งออกข้อมูลลูกดวงทั้งหมด (รวมที่ลบแล้ว) เป็นไฟล์ JSON
  /// คืนเส้นทางไฟล์ที่บันทึกไว้
  Future<String> exportToJson() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_jsonFileName');

    final exportData = {
      'format_version': backupFormatVersion,
      'exported_at': DateTime.now().toUtc().toIso8601String(),
      'app_version': '0.1.0+1',
      'customers': _repository.customers.map((c) => _customerToMap(c)).toList(),
      'deleted_customers':
          _repository.deletedCustomers.map((c) => _customerToMap(c)).toList(),
    };

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(exportData),
      flush: true,
    );

    return file.path;
  }

  /// ส่งออกข้อมูลลูกดวงทั้งหมดเป็นไฟล์ CSV
  Future<String> exportToCsv() async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$_csvFileName');

    final buffer = StringBuffer();
    buffer.writeln(
        'id,full_name,nickname,birth_date,birth_time,line_id,phone,province,address,notes,created_at,updated_at,last_consultation_date,last_contact_at,consent_given,consent_at,consent_note,deleted_at,is_deleted');

    for (final c in [..._repository.customers, ..._repository.deletedCustomers]) {
      buffer.writeln(_customerToCsvRow(c));
    }

    await file.writeAsString(buffer.toString(), flush: true);
    return file.path;
  }

  /// อ่านไฟล์ JSON และคืนข้อมูลตัวอย่างก่อนนำเข้า (ไม่เปลี่ยนแปลงข้อมูลในแอป)
  Future<BackupPreview> previewImportFromJson(String filePath) async {
    final file = File(filePath);
    if (!await file.exists()) {
      return BackupPreview(
        formatVersion: 0,
        customerCount: 0,
        deletedCount: 0,
        isCompatible: false,
        incompatibilityReason: 'ไม่พบไฟล์ที่ระบุ',
      );
    }

    final jsonString = await file.readAsString();
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      return BackupPreview(
        formatVersion: 0,
        customerCount: 0,
        deletedCount: 0,
        isCompatible: false,
        incompatibilityReason: 'ไฟล์ JSON ไม่ถูกต้อง: $e',
      );
    }

    final formatVersion = data['format_version'] as int? ?? 0;
    final currentSchemaVersion =
        _settings.getInt('schema_version', 0);

    final customers = (data['customers'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .length;
    final deletedCustomers = (data['deleted_customers'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .length;

    final exportedAtRaw = data['exported_at'] as String?;
    final exportedAt = exportedAtRaw != null
        ? DateTime.tryParse(exportedAtRaw)
        : null;

    // ปฏิเสธหากเวอร์ชันไฟล์ใหม่กว่าระบบปัจจุบัน
    if (formatVersion > backupFormatVersion) {
      return BackupPreview(
        formatVersion: formatVersion,
        customerCount: customers,
        deletedCount: deletedCustomers,
        exportedAt: exportedAt,
        isCompatible: false,
        incompatibilityReason:
            'ไฟล์สำรองมีเวอร์ชันใหม่กว่าระบบ ($formatVersion > $backupFormatVersion) โปรดอัปเดตแอปก่อนนำเข้า',
      );
    }

    // ตรวจสอบความเข้ากันได้ของสคีมา
    String? reason;
    if (currentSchemaVersion < 1 && formatVersion >= 1) {
      reason = 'ระบบยังไม่ได้รันมายเกรชันสคีมา โปรดตั้งค่าแอปให้ครบถ้วนก่อนนำเข้า';
    }

    return BackupPreview(
      formatVersion: formatVersion,
      customerCount: customers,
      deletedCount: deletedCustomers,
      exportedAt: exportedAt,
      isCompatible: reason == null,
      incompatibilityReason: reason,
    );
  }

  /// นำเข้าข้อมูลจากไฟล์ JSON (หลังจากตรวจสอบผ่าน preview แล้ว)
  /// คืนจำนวนลูกดวงที่นำเข้าสำเร็จ
  Future<int> importFromJson(String filePath, {bool replaceAll = false}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('ไม่พบไฟล์ที่ระบุ');
    }

    final jsonString = await file.readAsString();
    final Map<String, dynamic> data;
    try {
      data = jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('ไฟล์ JSON ไม่ถูกต้อง: $e');
    }

    final formatVersion = data['format_version'] as int? ?? 0;
    if (formatVersion > backupFormatVersion) {
      throw Exception(
          'ไฟล์สำรองมีเวอร์ชันใหม่กว่าระบบ ($formatVersion > $backupFormatVersion)');
    }

    int importedCount = 0;

    // นำเข้าลูกค้าที่ยังไม่ลบ
    final customersData =
        (data['customers'] as List? ?? []).whereType<Map<String, dynamic>>();
    for (final cMap in customersData) {
      try {
        final customer = Customer.fromMap(cMap);
        if (replaceAll) {
          await _repository.addCustomer(customer);
        } else {
          final existing = _repository.getCustomerById(customer.id);
          if (existing == null) {
            await _repository.addCustomer(customer);
          }
        }
        importedCount++;
      } catch (_) {
        // ข้ามเรกคอร์ดที่อ่านไม่ได้
      }
    }

    // นำเข้าลูกค้าที่ลบแล้ว (soft-deleted)
    final deletedData =
        (data['deleted_customers'] as List? ?? [])
            .whereType<Map<String, dynamic>>();
    for (final cMap in deletedData) {
      try {
        final customer = Customer.fromMap(cMap);
        if (replaceAll) {
          await _repository.addCustomer(customer);
          await _repository.softDeleteCustomer(customer.id);
        } else {
          final existing = _repository.getCustomerById(customer.id);
          if (existing == null) {
            await _repository.addCustomer(customer);
            await _repository.softDeleteCustomer(customer.id);
          } else if (existing.deletedAt == null && customer.deletedAt != null) {
            await _repository.softDeleteCustomer(customer.id);
          }
        }
        importedCount++;
      } catch (_) {
        // ข้ามเรกคอร์ดที่อ่านไม่ได้
      }
    }

    return importedCount;
  }

  /// นำเข้าข้อมูลจากไฟล์ CSV
  Future<int> importFromCsv(String filePath, {bool replaceAll = false}) async {
    final file = File(filePath);
    if (!await file.exists()) {
      throw Exception('ไม่พบไฟล์ที่ระบุ');
    }

    final lines = await file.readAsLines();
    if (lines.isEmpty) return 0;

    // ข้าม header line
    int importedCount = 0;
    for (int i = 1; i < lines.length; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      try {
        final fields = _parseCsvLine(line);
        if (fields.length < 4) continue;

        final customer = Customer(
          id: fields[0],
          fullName: fields[1],
          nickname: fields[2],
          birthDate: DateTime.tryParse(fields[3]) ?? DateTime(1900, 1, 1),
          birthTime: fields.length > 4 && fields[4].isNotEmpty
              ? fields[4]
              : null,
          lineId: fields.length > 5 ? fields[5] : '',
          phone: fields.length > 6 ? fields[6] : '',
          province: fields.length > 7 ? fields[7] : '',
          address: fields.length > 8 ? fields[8] : '',
          notes: fields.length > 9 ? fields[9] : '',
        );

        if (replaceAll) {
          await _repository.addCustomer(customer);
        } else {
          final existing = _repository.getCustomerById(customer.id);
          if (existing == null) {
            await _repository.addCustomer(customer);
          }
        }
        importedCount++;
      } catch (_) {
        // ข้ามแถวที่อ่านไม่ได้
      }
    }

    return importedCount;
  }

  /// ลบไฟล์สำรองทั้งหมดในโฟลเดอร์เอกสารของแอป
  Future<void> clearLocalBackups() async {
    final directory = await getApplicationDocumentsDirectory();
    final jsonFile = File('${directory.path}/$_jsonFileName');
    final csvFile = File('${directory.path}/$_csvFileName');

    if (await jsonFile.exists()) await jsonFile.delete();
    if (await csvFile.exists()) await csvFile.delete();
  }

  /// ตรวจสอบว่าไฟล์สำรองมีอยู่ในเครื่องหรือไม่
  Future<bool> hasLocalBackup() async {
    final directory = await getApplicationDocumentsDirectory();
    final jsonFile = File('${directory.path}/$_jsonFileName');
    final csvFile = File('${directory.path}/$_csvFileName');
    return await jsonFile.exists() || await csvFile.exists();
  }

  // ---------- private helpers ----------

  Map<String, dynamic> _customerToMap(Customer c) {
    return {
      'id': c.id,
      'full_name': c.fullName,
      'nickname': c.nickname,
      'birth_date': c.birthDate.toIso8601String().split('T').first,
      'birth_time': c.birthTime,
      'line_id': c.lineId,
      'phone': c.phone,
      'province': c.province,
      'address': c.address,
      'notes': c.notes,
      'created_at': c.createdAt.toIso8601String(),
      'updated_at': c.updatedAt.toIso8601String(),
      'last_consultation_date': c.lastConsultationDate?.toIso8601String(),
      'last_contact_at': c.lastContactAt?.toIso8601String(),
      'consent_given': c.consentGiven,
      'consent_at': c.consentAt?.toIso8601String(),
      'consent_note': c.consentNote,
      'deleted_at': c.deletedAt?.toIso8601String(),
    };
  }

  String _customerToCsvRow(Customer c) {
    final fields = [
      c.id,
      _csvEscape(c.fullName),
      _csvEscape(c.nickname),
      c.birthDate.toIso8601String().split('T').first,
      c.birthTime ?? '',
      _csvEscape(c.lineId),
      _csvEscape(c.phone),
      _csvEscape(c.province),
      _csvEscape(c.address),
      _csvEscape(c.notes),
      c.createdAt.toIso8601String(),
      c.updatedAt.toIso8601String(),
      c.lastConsultationDate?.toIso8601String() ?? '',
      c.lastContactAt?.toIso8601String() ?? '',
      c.consentGiven?.toString() ?? '',
      c.consentAt?.toIso8601String() ?? '',
      _csvEscape(c.consentNote ?? ''),
      c.deletedAt?.toIso8601String() ?? '',
      (c.deletedAt != null).toString(),
    ];
    return fields.join(',');
  }

  String _csvEscape(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }

  List<String> _parseCsvLine(String line) {
    final result = <String>[];
    final field = StringBuffer();
    var inQuotes = false;
    var i = 0;

    while (i < line.length) {
      final char = line[i];
      if (inQuotes) {
        if (char == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            field.write('"');
            i += 2;
            continue;
          } else {
            inQuotes = false;
            i++;
            continue;
          }
        } else {
          field.write(char);
          i++;
        }
      } else {
        if (char == '"') {
          inQuotes = true;
          i++;
        } else if (char == ',') {
          result.add(field.toString());
          field.clear();
          i++;
        } else {
          field.write(char);
          i++;
        }
      }
    }
    result.add(field.toString());
    return result;
  }
}
