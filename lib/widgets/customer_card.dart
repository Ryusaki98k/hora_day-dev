import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../utils/animation_helper.dart';
import '../utils/app_colors.dart';
import '../utils/app_svg_icons.dart';
import '../utils/thai_date_helper.dart';
import 'hbd_card_dialog.dart';

class CustomerCard extends StatelessWidget {
  final Customer customer;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onBirthdayBlessing;

  const CustomerCard({
    super.key,
    required this.customer,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    this.onBirthdayBlessing,
  });

  Color _getDayColor(int weekday) {
    return AppColors.getDayColor(weekday);
  }

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'คัดลอก$label: $text เรียบร้อยแล้ว',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFF1E293B),
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 76),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final birthDateStr = ThaiDateHelper.formatShort(customer.birthDate);
    final daysUntil = customer.daysUntilNextBirthday;
    final isUpcoming = customer.isUpcomingBirthday;
    final isToday = daysUntil == 0;
    final dayColor = _getDayColor(customer.birthDate.weekday);

    final cardContent = AnimatedPressable(
      scaleDown: 0.98,
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: isToday
              ? (context.isDark ? const Color(0xFF1E2638) : const Color(0xFFFFFDF5))
              : context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isToday
                ? (context.isDark ? AppColors.starGold : AppColors.amberGold)
                : isUpcoming
                    ? context.goldColor
                    : context.borderColor,
            width: isToday ? 1.6 : isUpcoming ? 1.4 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isToday
                  ? (context.isDark ? AppColors.moonGlow : AppColors.goldGlow)
                  : (context.isDark ? const Color(0x33000000) : const Color(0x0A000000)),
              blurRadius: isToday ? 10 : 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Avatar + Name + Birthday status + More Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar with Day Badge
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: dayColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: dayColor, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        customer.initialLetter,
                        style: TextStyle(
                          color: dayColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Name, Nickname & Astrological Summary
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  customer.fullName.isNotEmpty
                                      ? customer.fullName
                                      : customer.displayName,
                                  style: TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.bold,
                                    color: context.textColor,
                                    height: 1.2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (customer.nickname.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: context.chipBgColor,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: context.borderColor),
                                    ),
                                    child: Text(
                                      customer.nickname,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: context.chipTextColor,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${customer.thaiDayOfWeek} • เกิด $birthDateStr (อายุ ${customer.currentAge} ปี)',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.subTextColor,
                              height: 1.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 6),

                    // Birthday Badge & Popup Menu
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isUpcoming)
                          AuspiciousGlowBadge(
                            enabled: isToday,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              margin: const EdgeInsets.only(right: 2),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? (context.isDark ? const Color(0xFF381519) : const Color(0xFFFEF2F2))
                                    : (context.isDark ? const Color(0xFF282015) : const Color(0xFFFEF3C7)),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isToday
                                      ? (context.isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECDD3))
                                      : (context.isDark ? const Color(0xFF78521A) : AppColors.amberGold),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  isToday
                                      ? AppSvgIcons.cake(
                                          size: 11,
                                          color: context.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                        )
                                      : AppSvgIcons.hourglass(
                                          size: 11,
                                          color: context.isDark ? context.goldColor : AppColors.deepGoldText,
                                        ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isToday ? 'วันนี้!' : 'อีก $daysUntil วัน',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isToday
                                          ? (context.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
                                          : (context.isDark ? context.goldColor : AppColors.deepGoldText),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        // Quick 3-dot action menu
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.more_vert, size: 20, color: AppColors.mutedText),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          onSelected: (val) {
                            if (val == 'view') onTap();
                            if (val == 'edit') onEdit();
                            if (val == 'delete') onDelete();
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'view',
                              child: Row(
                                children: [
                                  Icon(Icons.visibility_outlined, size: 18, color: context.textColor),
                                  const SizedBox(width: 8),
                                  const Text('ดูข้อมูลเต็ม', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(Icons.edit_outlined, size: 18, color: AppColors.caramelBronze),
                                  SizedBox(width: 8),
                                  Text('แก้ไขข้อมูล', style: TextStyle(fontSize: 13)),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'delete',
                              child: Row(
                                children: [
                                  Icon(Icons.delete_outline, size: 18, color: Color(0xFFDC2626)),
                                  SizedBox(width: 8),
                                  Text('ลบข้อมูล', style: TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // Bottom Row: Mobile Direct Action Chips (Phone, LINE ID, Birthday Blessing)
                Row(
                  children: [
                    // Phone quick copy chip
                    Expanded(
                      child: InkWell(
                        onTap: () => _copyToClipboard(context, customer.phone, 'เบอร์โทร'),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.phone_outlined, size: 13, color: context.subTextColor),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  customer.phone,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.subText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    if (customer.lineId.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      // LINE ID quick copy chip
                      Expanded(
                        child: InkWell(
                          onTap: () => _copyToClipboard(context, customer.lineId, 'LINE ID'),
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            decoration: BoxDecoration(
                              color: AppColors.champagne.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.warmBorder),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.chat_bubble_outline, size: 13, color: AppColors.deepGoldText),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    customer.lineId,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: AppColors.deepGoldText,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    if (onBirthdayBlessing != null || isUpcoming) ...[
                      const SizedBox(width: 6),
                      SizedBox(
                        height: 40,
                        child: ElevatedButton(
                          onPressed: onBirthdayBlessing ??
                              () => HbdCardDialog.show(
                                    context,
                                    customer: customer,
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.caramelBronze,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'อวยพร',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      );

    return AuspiciousGlowBadge(
      enabled: isToday,
      borderRadius: BorderRadius.circular(14),
      child: cardContent,
    );
  }
}
