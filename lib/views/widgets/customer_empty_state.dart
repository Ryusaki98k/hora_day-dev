import 'package:flutter/material.dart';
import '../../utils/animation_helper.dart';
import '../../utils/app_colors.dart';

/// Empty state สำหรับกรณีไม่มีลูกดวงที่ตรงกับ filter/search
class CustomerEmptyState extends StatelessWidget {
  final bool hasActiveFilter;
  final String searchQuery;
  final VoidCallback onClearFilter;
  final VoidCallback onAddNewCustomer;

  const CustomerEmptyState({
    super.key,
    required this.hasActiveFilter,
    required this.searchQuery,
    required this.onClearFilter,
    required this.onAddNewCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: StaggeredEntrance(
          index: 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF282015)
                      : AppColors.champagne.withValues(alpha: 0.4),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF78521A)
                        : AppColors.amberGold.withValues(alpha: 0.5),
                  ),
                ),
                child: Icon(
                  Icons.person_search_rounded,
                  size: 34,
                  color: context.goldColor,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                searchQuery.isNotEmpty
                    ? 'ไม่พบข้อมูลลูกดวงที่ค้นหา'
                    : 'ยังไม่มีลูกดวงในเงื่อนไขนี้',
                style: TextStyle(
                  fontSize: 15,
                  color: context.textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                searchQuery.isNotEmpty
                    ? 'ลองตรวจสอบคำค้นหา หรือค้นหาด้วยเบอร์โทร/ชื่อเล่น'
                    : 'สามารถเลือกหมวดอื่น หรือกดปุ่ม "บันทึกดวงใหม่"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: context.subTextColor, height: 1.4),
              ),
              const SizedBox(height: 18),
              if (hasActiveFilter)
                OutlinedButton.icon(
                  onPressed: onClearFilter,
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('ดูสารบบทั้งหมด'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: context.goldColor,
                    side: BorderSide(color: context.goldColor),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                )
              else
                ElevatedButton.icon(
                  onPressed: onAddNewCustomer,
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('บันทึกดวงท่านแรก'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.caramelBronze,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
