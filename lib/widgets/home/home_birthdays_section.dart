import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/customer.dart';
import '../../services/customer_service.dart';
import '../../utils/animation_helper.dart';
import '../../utils/app_colors.dart';
import 'home_birthday_item.dart';

class HomeBirthdaysSection extends StatelessWidget {
  final CustomerService customerService;
  final VoidCallback onAddNewCustomer;

  const HomeBirthdaysSection({
    super.key,
    required this.customerService,
    required this.onAddNewCustomer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // All Birthdays Section Title
        StaggeredEntrance(
          index: 2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        'รายการวันเกิดลูกดวงทั้งหมด',
                        style: GoogleFonts.prompt(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: context.textColor,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (customerService.customers.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2.5,
                        ),
                        decoration: BoxDecoration(
                          color: context.chipBgColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${customerService.customers.length} ท่าน',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.bold,
                            color: context.chipTextColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 6),
              TextButton.icon(
                onPressed: onAddNewCustomer,
                icon: const Icon(Icons.add, size: 16),
                label: const Text(
                  'เพิ่ม',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: context.goldColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  minimumSize: const Size(48, 36),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        if (customerService.customers.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 18,
            ),
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: context.borderColor),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.people_outline_rounded,
                  size: 22,
                  color: context.goldColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'ยังไม่มีข้อมูลลูกดวง — กดปุ่ม "+ เพิ่ม" เพื่อบันทึกวันเกิดแรกของคุณ',
                    style: TextStyle(
                      fontSize: 13,
                      color: context.subTextColor,
                      height: 1.35,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onAddNewCustomer,
                  style: TextButton.styleFrom(
                    minimumSize: const Size(48, 44),
                  ),
                  child: Text(
                    '+ เพิ่มข้อมูล',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: context.goldColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          Builder(
            builder: (context) {
              final sortedCustomers = List<Customer>.from(customerService.customers)
                ..sort((a, b) => a.daysUntilNextBirthday.compareTo(b.daysUntilNextBirthday));

              return Container(
                decoration: BoxDecoration(
                  color: context.cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: context.isDark
                          ? const Color(0x33000000)
                          : const Color(0x06000000),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Column(
                    children: [
                      for (int i = 0; i < sortedCustomers.length; i++) ...[
                        if (i > 0)
                          Divider(
                            height: 1,
                            thickness: 0.8,
                            color: context.borderColor,
                            indent: 72,
                            endIndent: 16,
                          ),
                        HomeBirthdayItem(
                          customer: sortedCustomers[i],
                          customerService: customerService,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}
