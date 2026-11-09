import 'package:flutter/material.dart';
import '../../models/customer.dart';
import '../../utils/app_colors.dart';
import '../../utils/line_helper.dart';

/// รายการสารบบลูกดวงแบบ list พร้อม popup menu
class CustomerAstrologicalLedger extends StatelessWidget {
  final List<Customer> customers;
  final Function(Customer) onCustomerDetail;
  final Function(Customer) onEditCustomer;
  final Function(Customer) onDeleteCustomer;
  final void Function(String text, String label) onCopyToClipboard;

  const CustomerAstrologicalLedger({
    super.key,
    required this.customers,
    required this.onCustomerDetail,
    required this.onEditCustomer,
    required this.onDeleteCustomer,
    required this.onCopyToClipboard,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
      itemCount: customers.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final customer = customers[index];
        final isToday = customer.daysUntilNextBirthday == 0;

        return Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isToday
                  ? (context.isDark
                      ? const Color(0xFFEF4444).withValues(alpha: 0.6)
                      : const Color(0xFFFECDD3))
                  : context.borderColor,
              width: isToday ? 1.2 : 1.0,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: CustomerLedgerItem(
              customer: customer,
              onCustomerDetail: onCustomerDetail,
              onEditCustomer: onEditCustomer,
              onDeleteCustomer: onDeleteCustomer,
              onCopyToClipboard: onCopyToClipboard,
            ),
          ),
        );
      },
    );
  }
}

/// Widget สำหรับแสดงข้อมูลลูกดวงแต่ละคนใน list
class CustomerLedgerItem extends StatelessWidget {
  final Customer customer;
  final Function(Customer) onCustomerDetail;
  final Function(Customer) onEditCustomer;
  final Function(Customer) onDeleteCustomer;
  final void Function(String text, String label) onCopyToClipboard;

  const CustomerLedgerItem({
    super.key,
    required this.customer,
    required this.onCustomerDetail,
    required this.onEditCustomer,
    required this.onDeleteCustomer,
    required this.onCopyToClipboard,
  });

  Color _getDayColor(int weekday) => AppColors.getDayColor(weekday);

  String _getThaiWeekdayAbbr(int weekday) {
    switch (weekday) {
      case 1: return 'จ.';
      case 2: return 'อ.';
      case 3: return 'พ.';
      case 4: return 'พฤ.';
      case 5: return 'ศ.';
      case 6: return 'ส.';
      case 7: return 'อา.';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekday = customer.birthDate.weekday;
    final dayColor = _getDayColor(weekday);
    final dayAbbr = _getThaiWeekdayAbbr(weekday);
    final isUpcoming = customer.isUpcomingBirthday;
    final isToday = customer.daysUntilNextBirthday == 0;

    return Material(
      color: isToday
          ? (Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1E293B)
              : const Color(0xFFFFFDF8))
          : Colors.transparent,
      child: InkWell(
        onTap: () => onCustomerDetail(customer),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. Weekday Monogram Avatar
                  _buildDayAvatar(dayColor, dayAbbr, isToday),

                  const SizedBox(width: 13),

                  // 2. Client Identity & Details
                  Expanded(
                    child: _buildIdentitySection(
                      context,
                      isUpcoming: isUpcoming,
                      isToday: isToday,
                    ),
                  ),

                  const SizedBox(width: 4),

                  // 3. LINE Chat Button
                  if (customer.lineId.isNotEmpty)
                    _buildLineButton(context),

                  // 4. Popup Menu
                  _buildPopupMenu(context),
                ],
              ),
            ),
            // Today accent bar
            if (isToday)
              Positioned(
                left: 0,
                top: 10,
                bottom: 10,
                child: Container(
                  width: 3.5,
                  decoration: const BoxDecoration(
                    color: AppColors.amberGold,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(3),
                      bottomRight: Radius.circular(3),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayAvatar(Color dayColor, String dayAbbr, bool isToday) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: isToday
            ? dayColor.withValues(alpha: 0.16)
            : dayColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday ? dayColor : dayColor.withValues(alpha: 0.35),
          width: isToday ? 1.2 : 1.0,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        dayAbbr,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          color: dayColor,
        ),
      ),
    );
  }

  Widget _buildIdentitySection(
    BuildContext context, {
    required bool isUpcoming,
    required bool isToday,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Name + upcoming badge
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 2,
          children: [
            Text(
              customer.displayName,
              style: TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (isUpcoming) _buildUpcomingBadge(context, isToday),
          ],
        ),
        const SizedBox(height: 4),
        // Astrological summary
        Text(
          'เกิด ${customer.thaiDayOfWeek} • ${customer.turningAge} ปี',
          style: TextStyle(
            fontSize: 12,
            color: context.subTextColor,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildUpcomingBadge(BuildContext context, bool isToday) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: isToday
            ? (context.isDark ? const Color(0xFF381519) : const Color(0xFFFEF2F2))
            : (context.isDark
                ? const Color(0xFF282015)
                : AppColors.champagne.withValues(alpha: 0.6)),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isToday
              ? (context.isDark ? const Color(0xFF7F1D1D) : const Color(0xFFFECDD3))
              : (context.isDark
                  ? const Color(0xFF78521A)
                  : AppColors.amberGold.withValues(alpha: 0.4)),
        ),
      ),
      child: Text(
        isToday ? 'วันนี้!' : 'อีก ${customer.daysUntilNextBirthday} วัน',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isToday
              ? (context.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
              : context.goldColor,
        ),
      ),
    );
  }

  Widget _buildLineButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 4),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF132B1D) : const Color(0xFFE8F9EE),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: context.isDark ? const Color(0xFF166534) : const Color(0xFF86EFAC),
        ),
      ),
      child: IconButton(
        icon: Icon(
          Icons.chat_bubble_rounded,
          size: 17,
          color: context.isDark ? const Color(0xFF4ADE80) : const Color(0xFF00B900),
        ),
        tooltip: 'เปิดแชท LINE (${customer.lineId})',
        padding: const EdgeInsets.all(6),
        constraints: const BoxConstraints(minWidth: 34, minHeight: 34),
        onPressed: () => LineHelper.openLineChat(
          context,
          rawLineId: customer.lineId,
          customerName: customer.displayName,
        ),
      ),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert_rounded, size: 18, color: context.mutedTextColor),
      tooltip: 'ตัวเลือกเพิ่มเติม',
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      onSelected: (val) {
        if (val == 'detail') {
          onCustomerDetail(customer);
        } else if (val == 'edit') {
          onEditCustomer(customer);
        } else if (val == 'open_line' && customer.lineId.isNotEmpty) {
          LineHelper.openLineChat(
            context,
            rawLineId: customer.lineId,
            customerName: customer.displayName,
          );
        } else if (val == 'phone' && customer.phone.isNotEmpty) {
          onCopyToClipboard(customer.phone, 'เบอร์โทร');
        } else if (val == 'line' && customer.lineId.isNotEmpty) {
          onCopyToClipboard(customer.lineId, 'LINE ID');
        } else if (val == 'delete') {
          onDeleteCustomer(customer);
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'detail',
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16, color: context.textColor),
              const SizedBox(width: 8),
              Text('ดูรายละเอียดดวง', style: TextStyle(fontSize: 13, color: context.textColor)),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 16, color: context.textColor),
              const SizedBox(width: 8),
              Text('แก้ไขข้อมูล', style: TextStyle(fontSize: 13, color: context.textColor)),
            ],
          ),
        ),
        if (customer.lineId.isNotEmpty) ...[
          PopupMenuItem(
            value: 'open_line',
            child: Row(
              children: [
                const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF00B900)),
                const SizedBox(width: 8),
                Text(
                  'เปิดแชท LINE (${customer.lineId})',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF00B900),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'line',
            child: Row(
              children: [
                Icon(Icons.copy_rounded, size: 16, color: context.subTextColor),
                const SizedBox(width: 8),
                Text('คัดลอก LINE (${customer.lineId})', style: TextStyle(fontSize: 13, color: context.textColor)),
              ],
            ),
          ),
        ],
        if (customer.phone.isNotEmpty)
          PopupMenuItem(
            value: 'phone',
            child: Row(
              children: [
                const Icon(Icons.phone_outlined, size: 16, color: Color(0xFF059669)),
                const SizedBox(width: 8),
                Text('คัดลอกเบอร์ (${customer.phone})', style: TextStyle(fontSize: 13, color: context.textColor)),
              ],
            ),
          ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFDC2626)),
              SizedBox(width: 8),
              Text('ลบข้อมูล', style: TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
            ],
          ),
        ),
      ],
    );
  }
}
