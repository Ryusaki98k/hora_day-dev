import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/customer.dart';
import '../../utils/app_colors.dart';
import '../../utils/line_helper.dart';

class StudioDownloadSuccessDialog extends StatelessWidget {
  final String pathOrNotice;
  final String filename;
  final Customer? selectedCustomer;
  final String formattedBlessingText;

  const StudioDownloadSuccessDialog({
    super.key,
    required this.pathOrNotice,
    required this.filename,
    this.selectedCustomer,
    required this.formattedBlessingText,
  });

  static Future<void> show(
    BuildContext context, {
    required String pathOrNotice,
    required String filename,
    Customer? selectedCustomer,
    required String formattedBlessingText,
  }) {
    return showDialog(
      context: context,
      builder: (context) => StudioDownloadSuccessDialog(
        pathOrNotice: pathOrNotice,
        filename: filename,
        selectedCustomer: selectedCustomer,
        formattedBlessingText: formattedBlessingText,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: context.cardColor,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF059669).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF059669),
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'ดาวน์โหลดการ์ดสำเร็จ!',
              style: GoogleFonts.prompt(
                fontWeight: FontWeight.bold,
                fontSize: 17,
                color: context.textColor,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'บันทึกภาพการ์ดอวยพรวันเกิดความละเอียดสูง (HD) เรียบร้อยแล้ว',
            style: TextStyle(
              fontSize: 13.5,
              color: context.textColor,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: context.isDark
                  ? const Color(0xFF1E293B)
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                const Icon(Icons.image_outlined, size: 18, color: AppColors.caramelBronze),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    filename,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'monospace',
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          if (!kIsWeb) ...[
            const SizedBox(height: 8),
            Text(
              'บันทึกที่: $pathOrNotice',
              style: TextStyle(fontSize: 11, color: context.subTextColor),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
      actions: [
        if (selectedCustomer?.lineId.isNotEmpty ?? false)
          TextButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              LineHelper.openLineChat(
                context,
                rawLineId: selectedCustomer!.lineId,
                customerName: selectedCustomer!.fullName,
                copyMessageBeforeOpen: formattedBlessingText,
              );
            },
            icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF00B900)),
            label: const Text(
              'เปิด LINE แชท',
              style: TextStyle(color: Color(0xFF00B900), fontWeight: FontWeight.bold),
            ),
          ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(),
          style: ElevatedButton.styleFrom(
            backgroundColor: context.goldColor,
            foregroundColor: context.isDark ? AppColors.celestialVoid : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('ตกลง'),
        ),
      ],
    );
  }
}
