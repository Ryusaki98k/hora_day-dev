import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

/// ตัวช่วยเปิด LINE แชทของลูกดวงผ่าน LINE ID หรือ deep link
class LineHelper {
  LineHelper._();

  /// ตรวจสอบว่ามี Line ID หรือไม่
  static bool hasLineId(String? lineId) {
    return lineId != null && lineId.trim().isNotEmpty;
  }

  /// สร้าง URL สำหรับเปิด LINE แชท
  static Uri getLineUri(String rawLineId) {
    final cleanId = rawLineId.trim();
    if (cleanId.startsWith('http://') || cleanId.startsWith('https://') || cleanId.startsWith('line://')) {
      return Uri.parse(cleanId);
    }

    if (cleanId.startsWith('@')) {
      // สำหรับ LINE Official Account
      return Uri.parse('https://line.me/R/ti/p/$cleanId');
    }

    // สำหรับ LINE ID บุคคลทั่วไป
    return Uri.parse('https://line.me/ti/p/~$cleanId');
  }

  /// เปิด LINE แชทโดยตรง และสามารถคัดลอกข้อความเตรียมส่งได้
  static Future<void> openLineChat(
    BuildContext context, {
    required String rawLineId,
    String? copyMessageBeforeOpen,
    String? customerName,
  }) async {
    final cleanId = rawLineId.trim();
    if (cleanId.isEmpty) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  customerName != null
                      ? 'ลูกดวง "$customerName" ยังไม่ได้ระบุ LINE ID'
                      : 'ยังไม่ได้ระบุข้อมูล LINE ID',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          backgroundColor: const Color(0xFF64748B),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    // หากมีข้อความ ให้คัดลอกลงคลิปบอร์ดเตรียมวางในแชท
    if (copyMessageBeforeOpen != null && copyMessageBeforeOpen.trim().isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: copyMessageBeforeOpen));
    }

    final uri = getLineUri(cleanId);

    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        // Fallback: ลองเปิดผ่าน scheme line://
        final fallbackScheme = cleanId.startsWith('@')
            ? Uri.parse('line://ti/p/$cleanId')
            : Uri.parse('line://ti/p/~$cleanId');
        final fallbackLaunched = await launchUrl(fallbackScheme, mode: LaunchMode.externalApplication);

        if (!fallbackLaunched) {
          // หากเปิดไม่ได้ ให้คัดลอก ID ให้แทน
          await Clipboard.setData(ClipboardData(text: cleanId));
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('ไม่สามารถเปิดแอป LINE ได้โดยตรง คัดลอก LINE ID: $cleanId ให้แล้ว'),
              backgroundColor: const Color(0xFFDC2626),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: cleanId));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เปิด LINE ไม่สำเร็จ (คัดลอก ID: $cleanId ให้แล้ว)'),
          backgroundColor: const Color(0xFF334155),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
