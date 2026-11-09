import 'package:flutter/material.dart';
import '../services/customer_service.dart';
import '../utils/app_colors.dart';
import 'calendar_popup_dialog.dart';
import 'notes_popup_dialog.dart';

/// แผงทางลัดดวงชะตา (Studio Quick Actions) แบบ Instant Zero-Animation
class StudioQuickActions extends StatelessWidget {
  final CustomerService customerService;
  final VoidCallback onAddNewCustomer;
  final VoidCallback onOpenCalendar;
  final VoidCallback onOpenNotes;
  final VoidCallback onOpenStats;

  const StudioQuickActions({
    super.key,
    required this.customerService,
    required this.onAddNewCustomer,
    required this.onOpenCalendar,
    required this.onOpenNotes,
    required this.onOpenStats,
  });

  void _handleOpenCalendar(BuildContext context) {
    CalendarPopupDialog.show(
      context,
      customerService: customerService,
      onOpenFullHub: onOpenCalendar,
    );
  }

  void _handleOpenNotes(BuildContext context) {
    NotesPopupDialog.show(
      context,
      customerService: customerService,
      onOpenFullNotes: onOpenNotes,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x04000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 1. เพิ่มลูกดวง
          Expanded(
            child: _QuickActionItem(
              label: 'เพิ่มลูกดวง',
              iconWidget: const _QuickActionIconBox(
                icon: Icons.person_add_alt_1_rounded,
                bgColor: Color(0xFFEEF2FF),
                borderColor: Color(0xFFC7D2FE),
                iconColor: Color(0xFF4F46E5),
              ),
              onTap: onAddNewCustomer,
            ),
          ),

          // 2. ปฏิทินวันเกิด
          Expanded(
            child: _QuickActionItem(
              label: 'ปฏิทินวันเกิด',
              iconWidget: const _QuickActionIconBox(
                icon: Icons.calendar_month_rounded,
                bgColor: Color(0xFFFEF2F2),
                borderColor: Color(0xFFFECACA),
                iconColor: Color(0xFFDC2626),
              ),
              onTap: () => _handleOpenCalendar(context),
            ),
          ),

          // 3. สมุดบันทึก
          Expanded(
            child: _QuickActionItem(
              label: 'สมุดบันทึก',
              iconWidget: const _QuickActionIconBox(
                icon: Icons.menu_book_rounded,
                bgColor: Color(0xFFFFFBEB),
                borderColor: Color(0xFFFDE68A),
                iconColor: Color(0xFFD97706),
              ),
              onTap: () => _handleOpenNotes(context),
            ),
          ),

          // 4. สถิติภาพรวม
          Expanded(
            child: _QuickActionItem(
              label: 'สถิติภาพรวม',
              iconWidget: const _QuickActionIconBox(
                icon: Icons.bar_chart_rounded,
                bgColor: Color(0xFFF0FDF4),
                borderColor: Color(0xFFBBF7D0),
                iconColor: Color(0xFF059669),
              ),
              onTap: onOpenStats,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionIconBox extends StatelessWidget {
  final IconData icon;
  final Color bgColor;
  final Color borderColor;
  final Color iconColor;

  const _QuickActionIconBox({
    required this.icon,
    required this.bgColor,
    required this.borderColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: context.isDark ? bgColor.withValues(alpha: 0.15) : bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.isDark ? borderColor.withValues(alpha: 0.35) : borderColor, width: 1.2),
      ),
      alignment: Alignment.center,
      child: Icon(icon, color: iconColor, size: 22),
    );
  }
}

class _QuickActionItem extends StatelessWidget {
  final String label;
  final Widget iconWidget;
  final VoidCallback onTap;

  const _QuickActionItem({
    required this.label,
    required this.iconWidget,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      splashColor: AppColors.champagne.withValues(alpha: 0.3),
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 3),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: context.textColor,
                fontWeight: FontWeight.w600,
                fontFamily: 'Prompt',
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
