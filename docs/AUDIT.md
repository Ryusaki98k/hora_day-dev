# AUDIT.md — Hora Day (ก่อนเริ่ม Phase 0)

สรุปสถานะโค้ดปัจจุบันทั้งหมด ก่อนแก้ไขอะไรทั้งสิ้น ตามขั้นตอน 0.1 ของ PLAN.md

## 1. State management

ใช้ `ChangeNotifier` + `ValueListenableBuilder` / `ListenableBuilder`

| ไฟล์ | คลาส | หน้าที่ |
|---|---|---|
| `lib/services/customer_service.dart` | `CustomerService extends ChangeNotifier` | Hold `List<Customer>` ในหน่วยความจำ, alert listeners เมื่อเปลี่ยน, ซิงค์กับ Supabase realtime (`stream(primaryKey: ['id'])`) |
| `lib/services/consultation_service.dart` | `ConsultationService extends ChangeNotifier` | Hold `Map<String, List<Consultation>>` keyed by customerId, realtime stream ตาราง consultations |
| `lib/utils/app_colors.dart` | `AppThemeController` | `ValueNotifier<ThemeMode>` สลับ light/dark |

**ข้อสังเกต:** บริการถูกสร้างใน `_MainNavigationShellState.initState()` (main.dart:208-209) แล้วส่งผ่าน constructor ลงไปยัง views ทุกตัว ไม่มี DI container / service locator

## 2. Routing

ไม่มี named route / router package ใช้ `IndexedStack` ใน `MainNavigationShell` สลับ 2 แท็บ:

- Index 0: `HomeView`
- Index 1: `CustomerDirectoryView`

การนำทางอื่นใช้ `Navigator.of(context).push(MaterialPageRoute(...))` เช่น เปิด `NotesView`, `StatsView` จาก home_view.dart

Dialog แสดง inline ใน `main.dart` (`CustomerFormDialog.show`, `CustomerDetailDialog.show`, `_confirmDeleteCustomer`)

## 3. ที่เก็บข้อมูล

### Primary: Supabase (PostgreSQL)
- `supabase_flutter: ^2.18.0`
- URL และ publishable key **ฮาร์ดคodedไว้ใน `lib/main.dart:20-21`** (ต้องย้ายออกทันที — ละเมิดกฎ "ห้ามใส่ secret ใน repo")
- ตารางใน `supabase_schema.sql`: `customers`, `consultations`
- RLS เปิด แต่ 정책เป็น `using (true) with check (true)` อนุญาตทุกอย่างทั้งอ่านเขียน (ยังไม่แยกผู้ใช้)
- Realtime subscription เปิดทั้งสองตาราง
- `Customer.toSupabaseMap()` / `fromMap()` ใช้ snake_case, id เป็น string แปลงเป็น int ก่อนส่ง Supabase (schema ใช้ `bigint identity`)

### Fallback: Mock data ในหน่วยความจำ
ถ้า Supabase 初始化ล้มเหลวหรือยังไม่ได้ init `CustomerService` จะโหลด `_loadInitialSampleData()` ข้อมูลตัวอย่าง 4 คน (customer_serialization_test: บอกว่าใช้ข้อมูลตัวอย่างโดยอัตโนมัติ)

**ไม่มี:** Local database (Hive/SQLite/Isar), secure storage, file-based persistence นอกจาก mock ใน RAM

## 4. โครงโฟลเดอร์ (ปัจจุบัน)

```
lib/
  main.dart                  # App shell, bottom nav 2 แท็บ, dialog logic, service instances
  models/
    customer.dart            # Customer entity + date/age calculations + Supabase map
    consultation.dart        # Consultation entity
    card_theme_style.dart
    card_element_style.dart
    card_asset_item.dart
  services/
    customer_service.dart    # ChangeNotifier, Supabase + mock fallback
    consultation_service.dart
  views/
    home_view.dart
    customer_directory_view.dart
    birthday_hub_view.dart
    notes_view.dart
    stats_view.dart
    greeting_card_studio_view.dart
    widgets/                 # ย่อยใน views
  widgets/
    home/                    # home_sanctuary_header, home_pulse_card, home_birthday_*
    birthday_hub/            # timeline, spotlight, meridian, astrolabe, etc.
    greeting_card_studio/    # canvas, canva controls, form controls, action buttons, etc.
    customer_card.dart
    customer_form_dialog.dart
    customer_detail_dialog.dart
    notes_popup_dialog.dart
    calendar_popup_dialog.dart
    hbd_card_dialog.dart
    birthday_chatbox_dialog.dart
    birthday_alert_banner.dart
    consultation_history_section.dart
    celestrial_starfield.dart
    card_asset_library.dart
    card_asset_property_bar.dart
    loading_animation_widget.dart
    studio_quick_actions.dart
    studio_internal_property_bar.dart
    studio_canva_controls.dart
    studio_form_controls.dart
    studio_download_dialog.dart
    studio_canvas_element.dart
    greeting_card_canvas.dart
    card_auspicious_background_painter.dart
    timeline_node_painter.dart
  utils/
    thai_date_helper.dart    # Thai date formatting, auspicious color/direction/rerk/blessing per weekday
    line_helper.dart         # LINE deep link helper (https://line.me/ti/p/~{id})
    card_saver.dart          # Platform channel: web (dart:html Blob download), io (path_provider Downloads), stub
    card_saver_web.dart
    card_saver_io.dart
    card_saver_stub.dart
    app_colors.dart          # Theme colors + AppThemeController + AppThemeToggleButton
    app_svg_icons.dart
    animation_helper.dart
assets/
  templates/                 # Card template images + SVGs (1.png, 2.png, 3.png, *.zip, A4_template.svg)
  icons/                     # blessing.svg, sun.svg, โหรา.svg, โหรา2.svg, ลูกแก้ว.svg
test/
  customer_serialization_test.dart
  widget_test.dart           # Smoke test + imports main.dart
  screen_size_audit_test.dart # 8 screen sizes, pump widget on all views
```

## 5. Packages + เวอร์ชัน (pubspec.yaml)

```yaml
dependencies:
  flutter: sdk
  flutter_dotenv: ^6.0.1        # มีแต่ยังไม่ใช้ใน main.dart (secret ฮาร์ดคoded)
  flutter_svg: ^2.3.0
  google_fonts: ^8.2.0
  intl: ^0.20.3
  path_provider: ^2.1.6
  supabase_flutter: ^2.18.0
  url_launcher: ^6.3.2
  loading_animation_widget: ^1.3.0
dev_dependencies:
  flutter_test: sdk
  flutter_lints: ^6.0.0
```

ขาด: `local_auth`, `flutter_secure_storage`, `flutter_local_notifications`, `table_calendar`, `fl_chart`, `pdf`, `printing`, `archive` (zip), `excel` / `csv` — ต้องเพิ่มทีละเฟส

## 6. วิธี render / export การ์ด

ใช้ CustomPaint (`GreetingCardCanvas`, `CardAuspiciousBackgroundPainter`, `TimelineNodePainter`) บน `lib/widgets/greeting_card_studio/greeting_card_canvas.dart` และ `birthday_hub/*`

Export/บันทึกรูป: `CardSaver` (card_saver.dart) เรียก implementation ตามแพลตฟอร์มผ่าน conditional import:
- Web (`dart.library.html`): `dart:html` Blob → `Url.createObjectUrlFromBlob` → anchor click download PNG
- Mobile/Desktop (`dart.library.io`): `path_provider` → เขียนไฟล์ไป Downloads / documents
- Stub: โยน `UnsupportedError`

ไม่มีการใช้ `RepaintBoundary → PNG` ปัจจุบัน บันทึกเป็นการเขียนไฟล์ bytes ตรงๆ ไม่ใช่ capture จาก widget tree

## 7. ที่มาของปุ่ม "ส่ง LINE" ปัจจุบัน

`lib/utils/line_helper.dart` `LineHelper.openLineChat()`:
- สร้าง deep link `https://line.me/ti/p/~{lineId}` (บุคคล) หรือ `https://line.me/R/ti/p/{@id}` (Official Account)
- คัดลอกข้อความลงคลิปบอร์ดก่อนเปิด (ถ้ามี)
- เรียก `launchUrl(uri, mode: LaunchMode.externalApplication)` เปิดแอป LINE ภายนอก
- ถ้าเปิดไม่ได้ → fallback `line://ti/p/...` → ถ้ายังเปิดไม่ได้ → คัดลอก LINE ID อย่างเดียว + snack bar

**สรุป:** ปัจจุบัน "ส่ง LINE" เป็นแค่เปิดแชท LINE ภายนอก + คัดลอกข้อความเตรียมวาง **ไม่ใช่** LINE Messaging API ไม่มี webhook, ไม่มี access token, ไม่มีการส่งอัตโนมัติจากเซิร์ฟเวอร์

## 8. Test ที่มีอยู่

| ไฟล์ | สิ่งที่ทดสอบ |
|---|---|
| `test/customer_serialization_test.dart` | Unit: `toSupabaseMap()` เขียน province/last_consultation_date ครบ, null ส่ง null, birthTime ว่าง → `00:00:00`, round-trip `fromMap` |
| `test/widget_test.dart` | Smoke: ปั๊ม `HoraDayApp` ทุกขนาดหน้าจอ, หา text 'ลูกดวง' |
| `test/screen_size_audit_test.dart` | Widget test บน 8 ขนาดหน้าจอ (320×568 ถึง 1280×800) สำหรับทุก view หลัก |

**ข้อสังเกต:** Test ใช้ `DateTime.now()` จำนวนมาก → ไม่ determinsitic (วันเกิด "วันนี้/พรุ่งนี้" เปลี่ยนตามวันที่จริง) ไม่มี test สำหรับวันที่ขอบ (29 ก.พ., ข้ามปี, timezone) ยัง

## 9. Lint rule

`analysis_options.yaml`: include `package:flutter_lints/flutter.yaml`, exclude `build/`, `android/`, `ios/`, `web/`, `windows/`

pubspec ใช้ `flutter_lints: ^6.0.0`

## 10. ข้อสังเกตสำคัญที่ต้องแก้ใน Phase 0 (จาก screenshot + code review)

1. **Secret ใน repo:** Supabase URL + publishable key ฮาร์ดคoded ใน `lib/main.dart:20-21` → ต้องย้ายไป `.env` + `flutter_dotenv` และใส่ `.env` ใน `.gitignore`
2. **ไม่มี soft delete:** `deleteCustomer()` ลบถาวรจาก Supabase และจาก RAM ทันที ไม่มี `deletedAt`, ไม่มีถังขยะ, ไม่มี undo
3. **ไม่มี schema versioning:** ไม่มี `schemaVersion`, ไม่มี migration runner
4. **เกณฑ์ "ใกล้วันเกิด" ฮาร์ดคoded:** `Customer.isUpcomingBirthday` ตรวจ 0–2 วันเท่านั้น (`customer.dart:47-49`) แอปแสดง badge ตามตัวนี้ ต้องย้ายเป็นค่าตั้งค่าได้ (ค่าเริ่มต้น 30 วัน)
5. **`birthDate` เก็บเป็น DateTime พร้อมเวลา** แค่วันเดียวควรเก็บ date-only (ไม่มีเวลา/timezone) ตามกติกาใน PLAN.md
6. **ID ไม่ใช่ UUID:** mock data ใช้ '01', '02', ... Supabase schema ใช้ `bigint identity` → ต้องย้ายเป็น UUID
7. **ไม่มี Settings หน้า:** ไม่มีหน้าตั้งค่า PIN, ความปลอดภัย, สำรองข้อมูล, เกณฑ์ใกล้วันเกิด
8. **ไม่มีแอปล็อก (PIN):** ไม่มี `local_auth`, `flutter_secure_storage`
9. **ไม่มี export/import:** ไม่มี JSON/CSV backup
10. **อวาตาร์ไม่สอดคล้อง:** ตามข้อสังเกตใน PLAN.md หัวข้อ 2 ข้อ 1 — Home แสดง "T" แต่รายชื่อแสดง "อา." สำหรับคนเดียวกัน (`initialLetter` vs `thaiWeekdayAbbr` อาจใช้คนละ logic)
11. **`displayName` fallback:** fallback เป็น lineId แต่บางที่ใส่ `@` นำหน้า บางที่ไม่ใส่ (`initialLetter` strip `@`, `displayName` เพิ่ม `@`) ต้องทำให้สอดคล้องกัน

## 11. ตัวอย่างข้อมูล (fixture) ตรงกับ screenshot

mock data ใน `customer_service.dart:_loadInitialSampleData()` ใช้ `DateTime.now()` สำหรับวันเกิดวันนี้/พรุ่งนี้/อีก 2 วัน → test ต้องใช้ fixture แบบ fix วันที่ตาม PLAN.md หัวข้อ 9 (birth `1995-01-01`, today `2026-10-26` ฯลฯ)

---

**สรุป:** ฐานโค้ดดี มีแยก model/service/view ชัดเจน ใช้ Supabase เป็นหลัก มี mock fallback แต่ยังขาดเลเยอร์ repository, schema versioning, soft delete, settings, app lock, backup และ secret จัดการไม่ปลอดภัย พร้อมเริ่ม Phase 0 ได้ทันที
