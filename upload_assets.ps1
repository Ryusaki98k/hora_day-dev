# =============================================================
#  Upload assets -> Supabase Storage (bucket: assets)
#
#  Usage (PowerShell 5.1+):
#    $env:SUPABASE_SERVICE_ROLE_KEY = "sb_secret_xxx"   # แนะนำ (ข้าม RLS)
#    .\upload_assets.ps1
#
#    ใช้ publishable key ได้ (policy เขียนแบบ anon เปิดไว้ใน
#    storage_assets_policy.sql ข้อ 6):
#    $env:SUPABASE_KEY = "sb_publishable_xxx"
#    .\upload_assets.ps1
#
#    ดูไฟล์ก่อนอัปโหลดโดยไม่ต้องส่งจริง:
#    .\upload_assets.ps1 -DryRun
# =============================================================

param(
  [switch]$DryRun,
  [string]$Bucket = 'assets'
)

$ErrorActionPreference = 'Stop'

$SupabaseUrl = if ($env:SUPABASE_URL) { $env:SUPABASE_URL } else { 'https://pvxggcajiknwdbutciph.supabase.co' }
$ApiKey = if ($env:SUPABASE_SERVICE_ROLE_KEY) {
  $env:SUPABASE_SERVICE_ROLE_KEY
} elseif ($env:SUPABASE_KEY) {
  $env:SUPABASE_KEY
} else {
  'sb_publishable_SPa5dnGin5V9ToB8CVpvCQ_x1D8fmz3'
}

$UsingServiceRole = [bool]$env:SUPABASE_SERVICE_ROLE_KEY

$basePath = Join-Path $PSScriptRoot 'assets'

if (-not (Test-Path -LiteralPath $basePath)) {
  Write-Host "ไม่พบโฟลเดอร์ assets: $basePath" -ForegroundColor Red
  exit 1
}

$contentTypes = @{
  '.png'  = 'image/png'
  '.jpg'  = 'image/jpeg'
  '.jpeg' = 'image/jpeg'
  '.webp' = 'image/webp'
  '.gif'  = 'image/gif'
  '.svg'  = 'image/svg+xml'
  '.zip'  = 'application/zip'
  '.pdf'  = 'application/pdf'
}

$headers = @{
  'apikey'        = $ApiKey
  'Authorization' = "Bearer $ApiKey"
  'x-upsert'      = 'true'
}

# ------------------------------------------------------------
# Preflight: bucket ต้องมีอยู่ก่อน ไม่งั้นทุกไฟล์จะ fail
# ------------------------------------------------------------
Write-Host "Supabase : $SupabaseUrl" -ForegroundColor DarkGray
Write-Host "Bucket   : $Bucket" -ForegroundColor DarkGray
Write-Host "Key      : $(if ($UsingServiceRole) { 'service_role' } else { 'publishable/anon' })" -ForegroundColor DarkGray

$bucketOk = $true
try {
  Invoke-WebRequest -Uri "$SupabaseUrl/storage/v1/bucket/$Bucket" -Headers $headers -Method Get -UseBasicParsing | Out-Null
} catch {
  $bucketOk = $false
  $detail = if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $_.ErrorDetails.Message } else { $_.Exception.Message }
  $code = ''
  try {
    $parsed = $detail | ConvertFrom-Json
    if ($parsed.code) { $code = $parsed.code }
    if ($parsed.message) { $detail = $parsed.message }
  } catch { }
  Write-Host ""
  Write-Host "PREFLIGHT FAILED: bucket '$Bucket' ใช้งานไม่ได้ ($code)" -ForegroundColor Red
  Write-Host $detail -ForegroundColor Red
  Write-Host ""
  Write-Host "วิธีแก้:" -ForegroundColor Yellow
  Write-Host "  1) เปิด Supabase Dashboard -> SQL Editor -> New query" -ForegroundColor Yellow
  Write-Host "  2) วางไฟล์ storage_assets_policy.sql แล้วกด Run" -ForegroundColor Yellow
  Write-Host "     (ไฟล์นี้จะ CREATE bucket + policy; ถ้า bucket ยังไม่มีจะไม่มี policy ให้ใช้)" -ForegroundColor Yellow
  if (-not $UsingServiceRole) {
    Write-Host "  3) ถ้าไม่มี service_role key ให้ตั้ง `$env:SUPABASE_SERVICE_ROLE_KEY ก่อนรันสคริปต์นี้" -ForegroundColor Yellow
  }
  if (-not $DryRun) { exit 1 }
  Write-Host ""
  Write-Host "(โหมด DryRun - แสดงรายการไฟล์ที่จะอัปโหลด แต่ยังไม่ส่งจริง)" -ForegroundColor DarkGray
}

# ------------------------------------------------------------
# Upload
# ------------------------------------------------------------
$files = Get-ChildItem -LiteralPath $basePath -Recurse -File | Sort-Object FullName
$ok = 0
$fail = @()

foreach ($file in $files) {
  $relativePath = $file.FullName.Substring($basePath.Length + 1).Replace('\', '/')
  $encodedPath = (($relativePath -split '/') | ForEach-Object { [System.Uri]::EscapeDataString($_) }) -join '/'
  $publicUrl = "$SupabaseUrl/storage/v1/object/public/$Bucket/$encodedPath"

  $ext = $file.Extension.ToLowerInvariant()
  $contentType = if ($contentTypes.ContainsKey($ext)) { $contentTypes[$ext] } else { 'application/octet-stream' }

  if ($DryRun) {
    Write-Host "[DRY] $relativePath  ($([math]::Round($file.Length / 1KB, 1)) KB)  -> $publicUrl" -ForegroundColor DarkGray
    $ok++
    continue
  }

  Write-Host "Uploading: $relativePath  ($([math]::Round($file.Length / 1KB, 1)) KB)" -ForegroundColor Cyan

  try {
    $bytes = [System.IO.File]::ReadAllBytes($file.FullName)
    Invoke-RestMethod -Uri "$SupabaseUrl/storage/v1/object/$Bucket/$encodedPath" `
      -Method Post -Headers $headers -Body $bytes -ContentType $contentType | Out-Null
    Write-Host "  OK  $publicUrl" -ForegroundColor Green
    $ok++
  } catch {
    $status = $null
    if ($_.Exception.Response) { $status = [int]$_.Exception.Response.StatusCode }
    $detail = if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $_.ErrorDetails.Message } else { $_.Exception.Message }
    Write-Host "  FAILED (HTTP $status): $detail" -ForegroundColor Red
    $fail += "$relativePath -> $detail"
  }
}

Write-Host ""
Write-Host "สรุป: สำเร็จ $ok / ทั้งหมด $($files.Count)" -ForegroundColor $(if ($fail.Count -eq 0) { 'Green' } else { 'Yellow' })

if ($fail.Count -gt 0) {
  Write-Host "ไฟล์ที่ล้มเหลว:" -ForegroundColor Red
  $fail | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
  exit 1
}
