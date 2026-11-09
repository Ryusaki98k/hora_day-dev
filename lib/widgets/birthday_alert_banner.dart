import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/customer.dart';
import '../utils/app_colors.dart';
import 'birthday_chatbox_dialog.dart';
import 'hbd_card_dialog.dart';

/// แถบแจ้งเตือนวันเกิดใกล้ถึง — Warm Zen, primary CTA = อวยพร
class BirthdayAlertBanner extends StatefulWidget {
  final List<Customer> upcomingCustomers;
  final VoidCallback? onFilterTap;

  const BirthdayAlertBanner({
    super.key,
    required this.upcomingCustomers,
    this.onFilterTap,
  });

  @override
  State<BirthdayAlertBanner> createState() => _BirthdayAlertBannerState();
}

class _BirthdayAlertBannerState extends State<BirthdayAlertBanner> {
  bool _isCollapsed = false;

  @override
  Widget build(BuildContext context) {
    if (widget.upcomingCustomers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFDF8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.amberGold.withValues(alpha: 0.55),
          width: 1.2,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () {
              setState(() => _isCollapsed = !_isCollapsed);
            },
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.champagne,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.amberGold.withValues(alpha: 0.45),
                      ),
                    ),
                    child: const Icon(
                      Icons.celebration_outlined,
                      color: AppColors.caramelBronze,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'วันเกิดลูกดวงเร็วๆ นี้ (${widget.upcomingCustomers.length} ท่าน)',
                          style: GoogleFonts.prompt(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.deepGoldText,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'เตรียมส่งคำอวยพรมงคลล่วงหน้า — แตะอวยพรเพื่อคัดลอกส่ง LINE',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.subText,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isCollapsed
                          ? Icons.keyboard_arrow_down_rounded
                          : Icons.keyboard_arrow_up_rounded,
                      color: AppColors.caramelBronze,
                      size: 22,
                    ),
                    tooltip: _isCollapsed ? 'แสดงรายการ' : 'ซ่อนรายการ',
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    onPressed: () {
                      setState(() => _isCollapsed = !_isCollapsed);
                    },
                  ),
                ],
              ),
            ),
          ),
          if (!_isCollapsed) ...[
            Divider(
              height: 1,
              thickness: 0.8,
              color: AppColors.amberGold.withValues(alpha: 0.35),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: widget.upcomingCustomers.map((customer) {
                    final days = customer.daysUntilNextBirthday;
                    final isToday = days == 0;
                    final isTomorrow = days == 1;

                    final String badgeLabel;
                    final Color badgeBg;
                    final Color badgeColor;

                    if (isToday) {
                      badgeLabel = 'วันนี้!';
                      badgeBg = context.isDark ? const Color(0xFF381519) : const Color(0xFFFEF2F2);
                      badgeColor = context.isDark ? const Color(0xFFFCA5A5) : AppColors.daySunday;
                    } else if (isTomorrow) {
                      badgeLabel = 'พรุ่งนี้';
                      badgeBg = context.isDark ? const Color(0xFF282015) : AppColors.champagne;
                      badgeColor = context.isDark ? context.goldColor : AppColors.deepGoldText;
                    } else {
                      badgeLabel = 'อีก $days วัน';
                      badgeBg = context.isDark ? const Color(0xFF1E293B) : AppColors.warmSand;
                      badgeColor = context.isDark ? context.subTextColor : AppColors.subText;
                    }

                    return Container(
                      margin: const EdgeInsets.only(right: 10),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: context.cardColor,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isToday
                              ? (context.isDark ? const Color(0xFF7F1D1D) : AppColors.daySunday.withValues(alpha: 0.55))
                              : context.borderColor,
                          width: isToday ? 1.4 : 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: isToday
                                  ? AppColors.daySunday.withValues(alpha: 0.12)
                                  : AppColors.champagne,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              customer.initialLetter,
                              style: TextStyle(
                                color: isToday
                                    ? AppColors.daySunday
                                    : AppColors.caramelBronze,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.greetingName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: context.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: badgeBg,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  badgeLabel,
                                  style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.bold,
                                    color: badgeColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 12),
                          SizedBox(
                            height: 40,
                            child: ElevatedButton(
                              onPressed: () => HbdCardDialog.show(
                                context,
                                customer: customer,
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.caramelBronze,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'อวยพร',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          SizedBox(
                            height: 40,
                            width: 40,
                            child: IconButton.outlined(
                              onPressed: () => BirthdayChatboxDialog.show(
                                context,
                                customer: customer,
                              ),
                              tooltip: 'ดูโปรไฟล์',
                              style: IconButton.styleFrom(
                                foregroundColor: AppColors.subText,
                                side: const BorderSide(
                                  color: AppColors.warmBorder,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              icon: const Icon(
                                Icons.person_outline_rounded,
                                size: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
