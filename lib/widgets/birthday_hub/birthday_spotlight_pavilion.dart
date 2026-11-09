import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../services/customer_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/thai_date_helper.dart';
import 'birthday_celebrant_card.dart';

class BirthdaySpotlightPavilion extends StatelessWidget {
  final List<Customer> todayBirthdays;
  final List<Customer> upcomingBirthdays;
  final DateTime now;
  final CustomerService customerService;
  final ValueChanged<Customer> onOpenCustomerDetail;
  final ValueChanged<Customer>? onSendCard;

  const BirthdaySpotlightPavilion({
    super.key,
    required this.todayBirthdays,
    required this.upcomingBirthdays,
    required this.now,
    required this.customerService,
    required this.onOpenCustomerDetail,
    this.onSendCard,
  });


  @override
  Widget build(BuildContext context) {
    final dayName = ThaiDateHelper.dayOfWeekName(now.weekday);
    final auspiciousColor = ThaiDateHelper.dayAuspiciousColor(now.weekday);
    final auspiciousDirection = ThaiDateHelper.dayAuspiciousDirection(now.weekday);
    final auspiciousRerk = ThaiDateHelper.dayAuspiciousRerk(now.weekday);
    final hasToday = todayBirthdays.isNotEmpty;

    if (hasToday) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.caramelBronze.withValues(alpha: 0.5), width: 1.2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x06000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pavilion Banner Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: const Color(0xFFDC2626).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.cake_outlined, color: Color(0xFFDC2626), size: 16),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          'ลูกดวงฉลองวันเกิดวันนี้',
                          style: TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.bold,
                            color: context.textColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: AppColors.champagne.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${todayBirthdays.length} ท่าน',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: context.goldColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Celebrant Showcase Cards
            ...todayBirthdays.map((c) => BirthdayCelebrantCard(
                  customer: c,
                  customerService: customerService,
                  onOpenCustomerDetail: onOpenCustomerDetail,
                  onSendCard: onSendCard != null ? () => onSendCard!(c) : null,
                )),
          ],
        ),
      );
    }

    // When no birthdays today, show Horoscope Alignment Summary
    return Container(
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppColors.getDayColor(now.weekday),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'สิริมงคลประจำ$dayName (วันนี้)',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: context.textColor),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2.5),
                decoration: BoxDecoration(
                  color: AppColors.champagne.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  auspiciousColor,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: context.goldColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'ฤกษ์มงคล: $auspiciousRerk • ทิศมงคล: $auspiciousDirection',
            style: TextStyle(fontSize: 12, color: context.subTextColor),
          ),
          if (upcomingBirthdays.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131A29) : AppColors.ivory,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.borderColor),
              ),
              child: Row(
                children: [
                  Icon(Icons.hourglass_top_rounded, size: 16, color: context.goldColor),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'อีก ${upcomingBirthdays.first.daysUntilNextBirthday} วัน จะถึงวันเกิดคุณ "${upcomingBirthdays.first.fullName}" (ครบรอบ ${upcomingBirthdays.first.turningAge} ปี)',
                      style: TextStyle(fontSize: 12, color: context.textColor, fontWeight: FontWeight.w500),
                    ),
                  ),
                  const SizedBox(width: 6),
                  TextButton(
                    onPressed: () => onOpenCustomerDetail(upcomingBirthdays.first),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text('ดูข้อมูล', style: TextStyle(fontSize: 11.5, color: context.goldColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
