import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class BirthdayEmptyState extends StatelessWidget {
  final String message;
  final int? selectedDay;
  final VoidCallback onAddBirthday;

  const BirthdayEmptyState({
    super.key,
    required this.message,
    required this.selectedDay,
    required this.onAddBirthday,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.champagne.withValues(alpha: 0.35),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome, size: 26, color: context.goldColor),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: context.textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'สามารถแตะเลือกวันในสายธารด้านบน หรือเลือก "ตลอดเดือน" เพื่อดูรายการทั้งหมด',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: context.subTextColor),
          ),
          const SizedBox(height: 14),
          ElevatedButton.icon(
            onPressed: onAddBirthday,
            icon: const Icon(Icons.cake_rounded, size: 16),
            label: Text(
              selectedDay != null ? 'เพิ่มวันเกิดวันที่ $selectedDay' : 'เพิ่มวันเกิดลูกดวง',
              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.caramelBronze,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
