import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

enum CustomerSortOption {
  soonestBirthday,
  nameAsc,
  newest,
}

String getSortOptionLabel(CustomerSortOption option) {
  switch (option) {
    case CustomerSortOption.soonestBirthday:
      return 'ใกล้วันเกิด';
    case CustomerSortOption.nameAsc:
      return 'ก - ฮ';
    case CustomerSortOption.newest:
      return 'เพิ่มล่าสุด';
  }
}

/// Bottom sheet modal สำหรับเลือกการจัดเรียงสารบบลูกดวง
class CustomerSortModal extends StatelessWidget {
  final CustomerSortOption currentOption;
  final ValueChanged<CustomerSortOption> onOptionSelected;

  const CustomerSortModal({
    super.key,
    required this.currentOption,
    required this.onOptionSelected,
  });

  static Future<void> show({
    required BuildContext context,
    required CustomerSortOption currentOption,
    required ValueChanged<CustomerSortOption> onOptionSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => CustomerSortModal(
        currentOption: currentOption,
        onOptionSelected: onOptionSelected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFCBD5E1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ), // end of drag handle Container

                // ---------- A4 Card Preview ----------
                const SizedBox(height: 16),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 320),
                    child: AspectRatio(
                      aspectRatio: 1 / 1.414,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Image.asset(
                              'assets/templates/1.png',
                              fit: BoxFit.cover,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    'ขอแสดงความสุขวันเกิด!',
                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'จากทีม Hora Day',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              Row(
                children: [
                  Icon(Icons.sort_rounded, color: context.goldColor, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'จัดเรียงสารบบลูกดวง',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _SortRadioItem(
                icon: Icons.cake_outlined,
                title: 'ใกล้ถึงวันเกิดที่สุด',
                subtitle: 'เรียงตามคนที่วันเกิดใกล้ถึงก่อนใน 365 วัน',
                isSelected: currentOption == CustomerSortOption.soonestBirthday,
                onTap: () => onOptionSelected(CustomerSortOption.soonestBirthday),
              ),
              Divider(height: 1, color: context.borderColor),
              _SortRadioItem(
                icon: Icons.sort_by_alpha_rounded,
                title: 'ตามชื่อลูกดวง (ก - ฮ)',
                subtitle: 'เรียงตามตัวอักษรชื่อภาษาไทย',
                isSelected: currentOption == CustomerSortOption.nameAsc,
                onTap: () => onOptionSelected(CustomerSortOption.nameAsc),
              ),
              Divider(height: 1, color: context.borderColor),
              _SortRadioItem(
                icon: Icons.schedule_rounded,
                title: 'เพิ่มล่าสุด',
                subtitle: 'เรียงตามวันที่บันทึกข้อมูลล่าสุด',
                isSelected: currentOption == CustomerSortOption.newest,
                onTap: () => onOptionSelected(CustomerSortOption.newest),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SortRadioItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SortRadioItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.champagne.withValues(alpha: 0.5)
                    : context.cardColor,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected ? context.goldColor : context.borderColor,
                ),
              ),
              child: Icon(
                icon,
                size: 18,
                color: isSelected ? context.goldColor : context.subTextColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? context.goldColor : context.textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.5, color: context.mutedTextColor),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: context.goldColor, size: 20),
          ],
        ),
      ),
    );
  }
}
