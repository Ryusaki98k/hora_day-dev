-- =============================================================
--  Hora Day — Supabase Storage: bucket "assets" + RLS policies
--  Run:  Supabase Dashboard → SQL Editor → New query → Run
--  Idempotent: รันซ้ำได้ ปลอดภัย ไม่ลบข้อมูลไฟล์เดิม
--  ทำไมต้องรัน: ตอนนี้ bucket "assets" ยังไม่มีอยู่จริงในโปรเจกต์
--               (GET /storage/v1/bucket/assets → 404 NoSuchBucket)
--               ธรรมดา policy บน storage.objects ไม่ได้สร้าง bucket ให้
-- =============================================================

-- -------------------------------------------------------------
-- 1) สร้าง bucket (public = ดาวน์โหลดผ่าน public URL ได้โดยไม่ต้องใช้ token)
--    public = true ต้องการสำหรับ URL แบบ
--    https://<project>.supabase.co/storage/v1/object/public/assets/<path>
-- -------------------------------------------------------------
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'assets',
  'assets',
  true,
  52428800, -- 50 MB ต่อไฟล์
  ARRAY[
    'image/png',
    'image/jpeg',
    'image/webp',
    'image/gif',
    'image/svg+xml',
    'application/zip',
    'application/pdf'
  ]
)
ON CONFLICT (id) DO UPDATE
  SET public              = EXCLUDED.public,
      file_size_limit     = EXCLUDED.file_size_limit,
      allowed_mime_types  = EXCLUDED.allowed_mime_types,
      updated_at          = now();

-- -------------------------------------------------------------
-- 2) RLS บน storage.objects
-- -------------------------------------------------------------
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- -------------------------------------------------------------
-- 3) ล้าง policy เดิมทั้งหมด (ชื่อใหม่ + ชื่อเก่าที่เคยใช้)
-- -------------------------------------------------------------
DROP POLICY IF EXISTS "assets_select" ON storage.objects;
DROP POLICY IF EXISTS "assets_insert" ON storage.objects;
DROP POLICY IF EXISTS "assets_update" ON storage.objects;
DROP POLICY IF EXISTS "assets_delete" ON storage.objects;
DROP POLICY IF EXISTS "Public read access for assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow upload for assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow update for assets" ON storage.objects;
DROP POLICY IF EXISTS "Allow delete for assets" ON storage.objects;
DROP POLICY IF EXISTS "Public read assets" ON storage.objects;
DROP POLICY IF EXISTS "Anon insert assets" ON storage.objects;
DROP POLICY IF EXISTS "Anon update assets" ON storage.objects;
DROP POLICY IF EXISTS "Anon delete assets" ON storage.objects;
DROP POLICY IF EXISTS "assets_insert_anon" ON storage.objects;
DROP POLICY IF EXISTS "assets_update_anon" ON storage.objects;
DROP POLICY IF EXISTS "assets_delete_anon" ON storage.objects;

-- -------------------------------------------------------------
-- 4) อ่านได้ทุกคน — จำกัด scope ไว้ที่ bucket 'assets' เท่านั้น
--    จำเป็นสำหรับ upsert (ต้องมี SELECT) และการ list ไฟล์
-- -------------------------------------------------------------
CREATE POLICY "assets_select" ON storage.objects
  FOR SELECT TO public
  USING (bucket_id = 'assets');

-- -------------------------------------------------------------
-- 5) เขียนได้เฉพาะผู้ล็อกอิน (authenticated)
--    - service_role (secret key) ข้าม RLS อยู่แล้ว ใช้กับ upload_assets.ps1
--    - UPDATE ต้องมี SELECT ด้วย ข้อ 4 ครอบคลุมแล้ว
-- -------------------------------------------------------------
CREATE POLICY "assets_insert" ON storage.objects
  FOR INSERT TO authenticated
  WITH CHECK (bucket_id = 'assets');

CREATE POLICY "assets_update" ON storage.objects
  FOR UPDATE TO authenticated
  USING (bucket_id = 'assets')
  WITH CHECK (bucket_id = 'assets');

CREATE POLICY "assets_delete" ON storage.objects
  FOR DELETE TO authenticated
  USING (bucket_id = 'assets');

-- =============================================================
--  6) เขียนได้โดยไม่ต้อง login (anon) — เปิดไว้ตามที่เลือก
--     ⚠️ คำเตือน: publishable key ฝังอยู่ใน APK ของผู้ใช้ทุกคน
--        policy ชุดนี้ทำให้ "ใครก็ได้" ที่มี key อัปโหลด/ลบไฟล์ใน bucket ได้
--        → เสี่ยง storage abuse (ใช้โควตา/ค่าใช้จ่ายของโปรเจกต์)
--     ✅ วิธีปิด (แนะนำถ้าเริ่มมีผู้ใช้จริงแล้ว):
--        ลบ 3 policy ชุดนี้ออกจาก SQL Editor แล้วให้ client ที่ login แล้ว
--        ใช้สิทธิ์ authenticated แทน + อัปโหลดผ่าน service_role key
-- =============================================================
CREATE POLICY "assets_insert_anon" ON storage.objects
  FOR INSERT TO anon WITH CHECK (bucket_id = 'assets');
CREATE POLICY "assets_update_anon" ON storage.objects
  FOR UPDATE TO anon USING (bucket_id = 'assets') WITH CHECK (bucket_id = 'assets');
CREATE POLICY "assets_delete_anon" ON storage.objects
  FOR DELETE TO anon USING (bucket_id = 'assets');

-- -------------------------------------------------------------
-- 7) ตรวจสอบผล (ควรได้ 1 bucket และ 7 policy)
--    assets_select / assets_insert / assets_update / assets_delete
--    assets_insert_anon / assets_update_anon / assets_delete_anon
-- -------------------------------------------------------------
-- SELECT id, name, public FROM storage.buckets;
-- SELECT policyname, cmd, roles FROM pg_policies
--  WHERE schemaname = 'storage' AND tablename = 'objects' ORDER BY policyname;
