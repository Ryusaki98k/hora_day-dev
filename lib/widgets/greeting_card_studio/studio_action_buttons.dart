import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../utils/app_colors.dart';
import '../../utils/line_helper.dart';

class StudioActionButtons extends StatelessWidget {
  final bool isDownloading;
  final VoidCallback onDownload;
  final VoidCallback onCopyBlessing;
  final Customer? selectedCustomer;
  final String formattedBlessingText;

  const StudioActionButtons({
    super.key,
    required this.isDownloading,
    required this.onDownload,
    required this.onCopyBlessing,
    this.selectedCustomer,
    required this.formattedBlessingText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: isDownloading ? null : onDownload,
            icon: isDownloading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_rounded, size: 20),
            label: Text(
              isDownloading ? 'กำลังสร้างภาพความละเอียดสูง...' : 'ดาวน์โหลดการ์ดลงเครื่อง (HD)',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: context.goldColor,
              foregroundColor: context.isDark ? AppColors.celestialVoid : Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: onCopyBlessing,
                icon: const Icon(Icons.copy_rounded, size: 16),
                label: const Text('คัดลอกคำอวยพร', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: context.goldColor,
                  side: BorderSide(color: context.goldColor),
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
            if (selectedCustomer?.lineId.isNotEmpty ?? false) ...[
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    LineHelper.openLineChat(
                      context,
                      rawLineId: selectedCustomer!.lineId,
                      customerName: selectedCustomer!.fullName,
                      copyMessageBeforeOpen: formattedBlessingText,
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                  label: const Text('ส่ง LINE', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B900),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
