# Phase 0 — แผนย่อ (docs/phase-0-notes.md)

อ้างอิง: PLAN.md เฟส 0 งาน 0.1–0.11

## สถานะปัจจุบัน (baseline)
- `flutter analyze`: 2 warnings (unused import ใน main.dart:12, consultation_history_section.dart:9) ไม่มี error
- `flutter test`: ผ่านทั้งหมด 52 테スト
- โค้ดอยู่บน branch `main` ยังไม่มี branch feature/phase-0

## แผนดำเนินการ (ทีละงาน commit เล็กๆ)

| งาน | รายละเอียด | สถานะ |
|---|---|---|
| 0.1 | Audit — สร้าง docs/AUDIT.md (ห้ามแก้โค้ด) | เสร็จ |
| 0.2 | ตรวจข้อสังเกต 3 ข้อจากหัวข้อ 2 แล้วรายงานผล | รอดำเนินการ |
| 0.3 | Repository layer: `ClientRepository`, `SettingsRepository` interface | รอดำเนินการ |
| 0.4 | Schema versioning: `schemaVersion` + migration runner; migration แรกเพิ่มฟิลด์ Client ใหม่ | รอดำเนินการ |
| 0.5 | Soft delete + Undo: `deletedAt`, snackbar 5 วินาที, หน้าถังขยะใน Settings | รอดำเนินการ |
| 0.6 | หน้า Settings: เข้าจาก header Home, เกณฑ์ใกล้วันเกิด (default 30 วัน), ถังขยะ, เกี่ยวกับ | รอดำเนินการ |
| 0.7 | ล็อกแอป: PIN 4–6 หลัก hash+salt, ล็อกเมื่อเปิด/พื้นหลัง, ผิด 5 ครั้งหน่วง, biometric mobile, flutter_secure_storage | รอดำเนินการ |
| 0.8 | สำรอง/กู้คืน: Export JSON+CSV, Import JSON validate/preview/กลยุทธ์ซ้ำ, ปฏิเสธเวอร์ชันใหม่กว่า | รอดำเนินการ |
| 0.9 | PDPA เบื้องต้น: ช่องยินยอม, ปุ่มลบถาวร 2 ขั้น, หน้านโยบายข้อมูล static | รอดำเนินการ |
| 0.10 | Shared utilities + unit test: toBuddhistYear, formatThaiDate, daysUntilNextBirthday (29 ก.พ. → 28 ก.พ.), completedAge, ageYang, turningAge, weekdayOf, elementOfWeekday | รอดำเนินการ |
| 0.11 | Error/empty/loading widgets กลาง + global error handler เก็บ log ใน Settings | รอดำเนินการ |

## เกณฑ์ผ่าน (ต้องครบทุกข้อก่อนเริ่มเฟส 1)
- เปิดแอปต้องใส่ PIN (เมื่อเปิดใช้) ล็อกใหม่หลังพื้นหลังตามเวลาที่ตั้ง
- Export → ลบข้อมูลทั้งหมด → Import กลับ ได้ข้อมูลครบเหมือนเดิม
- ลบลูกดวง → เลิกทำได้ → อยู่ในถังขยะ → กู้คืนได้ → ลบถาวรได้
- ตั้งเกณฑ์ใกล้วันเกิด 90 วัน → Home แสดง "วันเกิดใกล้ถึง = 1" ตามฟิกซ์เจอร์
- unit test ของ utilities ผ่านทุกเคสในหัวข้อ 9
- `flutter analyze` + `flutter test` ผ่าน ไม่มี warning ใหม่

## ข้อที่ยังต้องชัดเจน (ใช้ค่าเริ่มต้นแล้วจดใน DECISIONS.md)
- Single-user, Supabase backend — ตามโค้ดปัจจุบัน
- Secret (Supabase key) จะย้ายไป `.env` + `flutter_dotenv` ในงาน 0.3/0.4
