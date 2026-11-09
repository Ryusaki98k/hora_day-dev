import 'package:supabase_flutter/supabase_flutter.dart';

import '../repositories/settings_repository.dart';

/// ระบบเวอร์ชันสคีมาและมายเกรชัน
///
/// เก็บ `schemaVersion` ใน SettingsRepository (key: `schema_version`)
/// มายเกรชันรัน SQL ผ่าน Supabase rpc (ต้องสร้างฟังก์ชัน exec_sql ใน DB ก่อน)
/// หรือผู้ดูแลรันไฟล์ supabase_schema.sql ใน Supabase Dashboard ด้วยมือ
class MigrationRunner {
  static const int currentSchemaVersion = 1;

  final SupabaseClient _supabase;
  final SettingsRepository _settings;

  MigrationRunner(this._supabase, this._settings);

  /// เวอร์ชันสคีมา ปัจจุบัน (0 = ยังไม่เคยมายเกรชัน)
  int get currentVersion => _settings.getInt('schema_version', 0);

  /// ตรวจสอบและมายเกรชันถ้ายังไม่ครบเวอร์ชัน
  Future<void> ensureMigrated() async {
    final current = currentVersion;
    if (current >= currentSchemaVersion) return;

    if (current < 1) {
      await _applyMigration1();
    }

    await _settings.setInt('schema_version', currentSchemaVersion);
  }

  /// มายเกรชันที่ 1: เพิ่มคอลัมน์ใหม่ของตาราง customers
  ///
  /// คอลัมน์: deleted_at, updated_at, last_contact_at,
  /// consent_given, consent_at, consent_note
  Future<void> _applyMigration1() async {
    try {
      // พยายามรันผ่าน rpc ฟังก์ชัน exec_sql (ถ้ามีใน DB)
      await _supabase.rpc('exec_sql', params: {
        'sql': '''
          ALTER TABLE customers ADD COLUMN IF NOT EXISTS deleted_at timestamptz;
          ALTER TABLE customers ADD COLUMN IF NOT EXISTS updated_at timestamptz DEFAULT now();
          ALTER TABLE customers ADD COLUMN IF NOT EXISTS last_contact_at timestamptz;
          ALTER TABLE customers ADD COLUMN IF NOT EXISTS consent_given boolean;
          ALTER TABLE customers ADD COLUMN IF NOT EXISTS consent_at timestamptz;
          ALTER TABLE customers ADD COLUMN IF NOT EXISTS consent_note text;
        ''',
      });
    } catch (e) {
      // ถ้าไม่มีฟังก์ชัน exec_sql ให้ข้าม — ผู้ดูแลต้องรัน supabase_schema.sql ด้วยมือ
      // Migration จะยังถูกทำเครื่องหมายว่าเสร็จเพื่อไม่บล็อกการทำงาน
      // (คอลัมน์จะถูกเพิ่มเมื่อผู้ดูแลรันไฟล์ schema ใน Supabase Dashboard)
    }
  }
}
