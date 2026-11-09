import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../services/customer_service.dart';
import '../../utils/app_colors.dart';
import '../../utils/line_helper.dart';
import '../../views/greeting_card_studio_view.dart';
import '../hbd_card_dialog.dart';

class BirthdayCelebrantCard extends StatelessWidget {
  final Customer customer;
  final CustomerService customerService;
  final ValueChanged<Customer> onOpenCustomerDetail;
  final VoidCallback? onSendCard;

  const BirthdayCelebrantCard({
    super.key,
    required this.customer,
    required this.customerService,
    required this.onOpenCustomerDetail,
    this.onSendCard,
  });

  @override
  Widget build(BuildContext context) {
    final dayColor = AppColors.getDayColor(customer.birthDate.weekday);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: () => onOpenCustomerDetail(customer),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Row(
                  children: [
                    // Avatar
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: dayColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: dayColor.withValues(alpha: 0.35)),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        customer.initialLetter,
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: dayColor),
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
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: context.textColor,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'ฉลองครบรอบ ${customer.turningAge} ปีบริบูรณ์ • ${customer.thaiDayOfWeek}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFFDC2626),
                            ),
                          ),
                          if (customer.birthTime != null && customer.birthTime!.isNotEmpty)
                            Text(
                              'เวลาเกิด: ${customer.birthTime} น.',
                              style: TextStyle(fontSize: 11, color: context.subTextColor),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Primary: อวยพร + secondary copy/detail
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isUltraCompact = constraints.maxWidth < 280;
                    if (isUltraCompact) {
                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: onSendCard ?? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (context) => GreetingCardStudioView(
                                            customerService: customerService,
                                            initialCustomer: customer,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.palette_outlined,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'ทำการ์ด',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.caramelBronze,
                                      side: const BorderSide(
                                        color: AppColors.caramelBronze,
                                      ),
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: ElevatedButton.icon(
                                    onPressed: () => HbdCardDialog.show(
                                      context,
                                      customer: customer,
                                      customerService: customerService,
                                    ),
                                    icon: const Icon(
                                      Icons.auto_awesome,
                                      size: 16,
                                    ),
                                    label: const Text(
                                      'อวยพร',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                      maxLines: 1,
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.caramelBronze,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              if (customer.lineId.isNotEmpty) ...[
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton.icon(
                                      onPressed: () => LineHelper.openLineChat(
                                        context,
                                        rawLineId: customer.lineId,
                                        customerName: customer.fullName,
                                      ),
                                      icon: Icon(
                                        Icons.chat_bubble_rounded,
                                        size: 16,
                                        color: context.isDark ? const Color(0xFF4ADE80) : const Color(0xFF00B900),
                                      ),
                                      label: const Text(
                                        'LINE',
                                        style: TextStyle(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF00B900),
                                        ),
                                      ),
                                      style: OutlinedButton.styleFrom(
                                        backgroundColor: context.isDark
                                            ? const Color(0xFF132B1D)
                                            : const Color(0xFFE8F9EE),
                                        side: BorderSide(
                                          color: context.isDark
                                              ? const Color(0xFF166534)
                                              : const Color(0xFF86EFAC),
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              Expanded(
                                child: SizedBox(
                                  height: 48,
                                  child: OutlinedButton.icon(
                                    onPressed: () => onOpenCustomerDetail(customer),
                                    icon: const Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      size: 14,
                                    ),
                                    label: const Text(
                                      'ดูข้อมูล',
                                      style: TextStyle(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: AppColors.caramelBronze,
                                      side: BorderSide(
                                        color: context.isDark
                                            ? const Color(0xFF334155)
                                            : AppColors.warmBorder,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    }

                    return Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: OutlinedButton.icon(
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
                              icon: const Icon(
                                Icons.palette_outlined,
                                size: 16,
                              ),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'ทำการ์ด',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.caramelBronze,
                                side: const BorderSide(
                                  color: AppColors.caramelBronze,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              onPressed: () => HbdCardDialog.show(
                                context,
                                customer: customer,
                                customerService: customerService,
                              ),
                              icon: const Icon(
                                Icons.auto_awesome,
                                size: 16,
                              ),
                              label: const FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  'อวยพร',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.caramelBronze,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (customer.lineId.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          SizedBox(
                            width: 48,
                            height: 48,
                            child: IconButton.outlined(
                              onPressed: () => LineHelper.openLineChat(
                                context,
                                rawLineId: customer.lineId,
                                customerName: customer.fullName,
                              ),
                              icon: Icon(
                                Icons.chat_bubble_rounded,
                                size: 17,
                                color: context.isDark ? const Color(0xFF4ADE80) : const Color(0xFF00B900),
                              ),
                              tooltip: 'เปิดแชท LINE (${customer.lineId})',
                              padding: EdgeInsets.zero,
                              style: IconButton.styleFrom(
                                backgroundColor: context.isDark
                                    ? const Color(0xFF132B1D)
                                    : const Color(0xFFE8F9EE),
                                foregroundColor: context.isDark ? const Color(0xFF4ADE80) : const Color(0xFF00B900),
                                side: BorderSide(
                                  color: context.isDark
                                      ? const Color(0xFF166534)
                                      : const Color(0xFF86EFAC),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(width: 6),
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: IconButton.outlined(
                            onPressed: () => onOpenCustomerDetail(customer),
                            icon: const Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 14,
                            ),
                            tooltip: 'ดูรายละเอียด',
                            padding: EdgeInsets.zero,
                            style: IconButton.styleFrom(
                              foregroundColor: AppColors.caramelBronze,
                              side: BorderSide(
                                color: context.isDark
                                    ? const Color(0xFF334155)
                                    : AppColors.warmBorder,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
