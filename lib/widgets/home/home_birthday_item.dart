import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../services/customer_service.dart';
import '../../utils/animation_helper.dart';
import '../../utils/app_colors.dart';
import '../../views/greeting_card_studio_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../customer_detail_dialog.dart';
import '../customer_form_dialog.dart';
import '../hbd_card_dialog.dart';

class HomeBirthdayItem extends StatelessWidget {
  final Customer customer;
  final CustomerService customerService;

  const HomeBirthdayItem({
    super.key,
    required this.customer,
    required this.customerService,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = customer.daysUntilNextBirthday == 0;
    final dayColor = AppColors.getDayColor(customer.birthDate.weekday);

    final itemWidget = LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 360;

        final badgeWidget = Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 1.5,
          ),
          decoration: BoxDecoration(
            color: isToday
                ? (context.isDark
                    ? AppColors.daySunday.withValues(alpha: 0.24)
                    : const Color(0xFFFEF2F2))
                : context.chipBgColor,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: isToday
                  ? (context.isDark
                      ? AppColors.daySunday.withValues(alpha: 0.6)
                      : const Color(0xFFFECDD3))
                  : (context.isDark
                      ? AppColors.celestialBorder
                      : AppColors.amberGold.withValues(alpha: 0.4)),
            ),
          ),
          child: Text(
            isToday
                ? 'วันนี้!'
                : (customer.daysUntilNextBirthday == 1
                    ? 'อีก 1 วัน'
                    : 'อีก ${customer.daysUntilNextBirthday} วัน'),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isToday ? AppColors.daySunday : context.chipTextColor,
            ),
          ),
        );

        return Material(
          color: isToday
              ? (context.isDark
                  ? AppColors.starGold.withValues(alpha: 0.09)
                  : const Color(0xFFFFFDF8))
              : Colors.transparent,
          child: InkWell(
            onTap: () {
              CustomerDetailDialog.show(
                context,
                customer: customer,
                onUpdate: (updated) => customerService.updateCustomer(updated),
                onDelete: () => customerService.deleteCustomer(customer.id),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: isToday
                          ? dayColor.withValues(alpha: context.isDark ? 0.28 : 0.16)
                          : dayColor.withValues(alpha: context.isDark ? 0.20 : 0.10),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isToday ? dayColor : dayColor.withValues(alpha: 0.4),
                        width: isToday ? 1.5 : 1.0,
                      ),
                      boxShadow: context.isDark
                          ? [
                              BoxShadow(
                                color: dayColor.withValues(alpha: isToday ? 0.45 : 0.15),
                                blurRadius: isToday ? 8 : 4,
                              ),
                            ]
                          : null,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      customer.initialLetter,
                      style: TextStyle(
                        color: dayColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          customer.displayName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 5,
                          runSpacing: 2,
                          children: [
                            Text(
                              'เกิด ${customer.thaiDayOfWeek} • ${customer.turningAge} ปี',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            badgeWidget,
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton.outlined(
                      onPressed: () {
                        CustomerFormDialog.show(
                          context,
                          initialCustomer: customer,
                          onSave: (updated) => customerService.updateCustomer(updated),
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      tooltip: 'แก้ไขข้อมูล',
                      padding: EdgeInsets.zero,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.subTextColor,
                        side: BorderSide(
                          color: context.borderColor,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: IconButton.outlined(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => GreetingCardStudioView(
                              customerService: customerService,
                              initialCustomer: customer,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.palette_outlined, size: 16),
                      tooltip: 'ทำการ์ดมงคล',
                      padding: EdgeInsets.zero,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.goldColor,
                        side: BorderSide(color: context.goldColor.withValues(alpha: 0.6)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  if (isCompact)
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: IconButton.filled(
                        onPressed: () => HbdCardDialog.show(
                          context,
                          customer: customer,
                          customerService: customerService,
                        ),
                        icon: const Icon(Icons.card_giftcard_rounded, size: 16),
                        tooltip: 'อวยพร',
                        style: IconButton.styleFrom(
                          backgroundColor: context.goldColor,
                          foregroundColor: context.isDark
                              ? AppColors.celestialVoid
                              : Colors.white,
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    )
                  else
                    SizedBox(
                      height: 36,
                      child: ElevatedButton(
                        onPressed: () => HbdCardDialog.show(
                          context,
                          customer: customer,
                          customerService: customerService,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.goldColor,
                          foregroundColor: context.isDark
                              ? AppColors.celestialVoid
                              : Colors.white,
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SvgPicture.asset(
                              'assets/icons/blessing.svg',
                              width: 16,
                              height: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'อวยพร',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (isToday) {
      return AuspiciousGlowBadge(
        enabled: true,
        child: itemWidget,
      );
    }
    return itemWidget;
  }
}
