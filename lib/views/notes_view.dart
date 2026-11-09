import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/animation_helper.dart';
import '../utils/app_colors.dart';
import '../utils/thai_date_helper.dart';
import '../widgets/customer_detail_dialog.dart';

/// หน้าจอบันทึกดวงชะตา & พระสมุดคำพยากรณ์ (Astrological Codex & Notes Sanctuary)
/// ออกแบบใหม่หมดจด: สไตล์คัมภีร์ใบลานและปูมโหรโบราณร่วมสมัย ผสานความโปร่งสบาย Warm Zen
class NotesView extends StatefulWidget {
  final CustomerService customerService;

  const NotesView({super.key, required this.customerService});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  String _searchQuery = '';
  String _selectedDayFilter = 'ทั้งหมด';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Color _getDayMineralColor(int weekday) {
    return AppColors.getDayColor(weekday);
  }

  String _getThaiWeekdayAbbr(int weekday) {
    switch (weekday) {
      case 1:
        return 'จ.';
      case 2:
        return 'อ.';
      case 3:
        return 'พ.';
      case 4:
        return 'พฤ.';
      case 5:
        return 'ศ.';
      case 6:
        return 'ส.';
      case 7:
        return 'อา.';
      default:
        return '';
    }
  }

  List<Customer> _getFilteredNotes() {
    var list = widget.customerService.customersWithNotes;

    if (_selectedDayFilter != 'ทั้งหมด') {
      list = list.where((c) => c.thaiDayOfWeek == _selectedDayFilter).toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            c.nickname.toLowerCase().contains(q) ||
            c.notes.toLowerCase().contains(q) ||
            c.province.toLowerCase().contains(q) ||
            c.thaiDayOfWeek.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  void _copyNoteToClipboard(Customer customer) {
    Clipboard.setData(ClipboardData(text: '${customer.displayName} (${customer.thaiDayOfWeek})\n${customer.notes}'));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'คัดลอกบันทึกของ ${customer.displayName} เรียบร้อยแล้ว',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : AppColors.darkText,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredNotes();
    final allNotesCount = widget.customerService.customersWithNotes.length;

    final dayFilters = [
      'ทั้งหมด',
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์',
    ];

    return Scaffold(
      backgroundColor: context.scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.champagne.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.7)),
              ),
              child: AnimatedSparkleIcon(icon: Icons.history_edu_rounded, color: context.goldColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'พระสมุดคำพยากรณ์',
                    style: TextStyle(
                      fontSize: 17.5,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                      letterSpacing: -0.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'บันทึกดวงชะตาลูกดวง ($allNotesCount เรื่อง)',
                    style: TextStyle(fontSize: 11.5, color: context.subTextColor, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            children: [
              // 1. Search Bar with Warm Zen Styling
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.cardColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: context.borderColor),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x06000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: TextStyle(fontSize: 13.5, color: context.textColor),
                    decoration: InputDecoration(
                      hintText: 'ค้นหาคำพยากรณ์ เช่น การงาน, การเงิน, เนื้อคู่, ฤกษ์...',
                      hintStyle: TextStyle(fontSize: 13, color: context.mutedTextColor),
                      prefixIcon: Icon(Icons.search_rounded, color: context.goldColor, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(Icons.clear_rounded, size: 18, color: context.mutedTextColor),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                    ),
                  ),
                ),
              ),

              // 2. Weekday Planetary Strip (ริบบิ้นจักรา ๗ วัน) - 48 dp Android Touch Target
              () {
                final noteCountsByDay = <String, int>{};
                for (final c in widget.customerService.customersWithNotes) {
                  noteCountsByDay[c.thaiDayOfWeek] = (noteCountsByDay[c.thaiDayOfWeek] ?? 0) + 1;
                }

                return Container(
                  height: 48,
                  margin: const EdgeInsets.only(bottom: 6),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: dayFilters.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 6),
                    itemBuilder: (context, idx) {
                      final day = dayFilters[idx];
                      final isSelected = _selectedDayFilter == day;
                      final isDayTag = day.startsWith('วัน');
                      final mineralColor = isDayTag ? _getDayMineralColor(idx) : context.goldColor;
                      final count = isDayTag ? (noteCountsByDay[day] ?? 0) : 0;

                      return Semantics(
                        button: true,
                        selected: isSelected,
                        label: '$day${count > 0 ? ', มี $count บันทึก' : ''}',
                        child: AnimatedPressable(
                          onTap: () => setState(() => _selectedDayFilter = day),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? mineralColor : context.cardColor,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? mineralColor : context.borderColor,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: mineralColor.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            alignment: Alignment.center,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isDayTag) ...[
                                  Container(
                                    width: 6,
                                    height: 6,
                                    margin: const EdgeInsets.only(right: 6),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.white : mineralColor,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ],
                                Text(
                                  day,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : context.subTextColor,
                                  ),
                                ),
                                if (isDayTag && count > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.white.withValues(alpha: 0.28)
                                          : mineralColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : mineralColor,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              }(),

              // 3. Status Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'พบบันทึก ${filtered.length} เรื่อง',
                      style: TextStyle(fontSize: 12, color: context.subTextColor, fontWeight: FontWeight.w600),
                    ),
                    if (_selectedDayFilter != 'ทั้งหมด' || _searchQuery.isNotEmpty)
                      InkWell(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                            _selectedDayFilter = 'ทั้งหมด';
                          });
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          child: Text(
                            'ล้างตัวกรอง',
                            style: TextStyle(
                              fontSize: 12,
                              color: context.goldColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // 4. Notes List - Folio Scroll Style
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF282015) : AppColors.champagne.withValues(alpha: 0.4),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78521A) : AppColors.amberGold.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Icon(Icons.history_edu_rounded, size: 30, color: context.goldColor),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _searchQuery.isNotEmpty ? 'ไม่พบบันทึกที่ตรงกับคำค้นหา' : 'ยังไม่มีบันทึกดวงชะตา',
                                style: TextStyle(fontSize: 14.5, color: context.textColor, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'คุณสามารถเพิ่มบันทึกคำพยากรณ์ได้ในหน้ารายละเอียดลูกดวง',
                                style: TextStyle(fontSize: 12.5, color: context.subTextColor),
                              ),
                            ],
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filtered.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(14, 4, 14, 88),
                        itemBuilder: (context, index) {
                          final customer = filtered[index];
                          final weekday = customer.birthDate.weekday;
                          final dayColor = _getDayMineralColor(weekday);
                          final dayAbbr = _getThaiWeekdayAbbr(weekday);
                          final birthStr = ThaiDateHelper.formatShort(customer.birthDate);

                          return StaggeredEntrance(
                            index: index,
                            child: AnimatedPressable(
                              scaleDown: 0.98,
                              onTap: () {
                                CustomerDetailDialog.show(
                                  context,
                                  customer: customer,
                                  onUpdate: (updated) => widget.customerService.updateCustomer(updated),
                                  onDelete: () => widget.customerService.deleteCustomer(customer.id),
                                );
                              },
                              borderRadius: BorderRadius.circular(14),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: context.borderColor),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0x05000000),
                                      blurRadius: 8,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Header: Avatar + Client Name + Weekday + Copy
                                      Row(
                                        children: [
                                          Container(
                                            width: 38,
                                            height: 38,
                                            decoration: BoxDecoration(
                                              color: dayColor.withValues(alpha: 0.12),
                                              borderRadius: BorderRadius.circular(10),
                                              border: Border.all(color: dayColor.withValues(alpha: 0.3)),
                                            ),
                                            alignment: Alignment.center,
                                            child: Text(
                                              dayAbbr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: dayColor,
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
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                    color: context.textColor,
                                                  ),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 2),
                                                Text(
                                                  '${customer.thaiDayOfWeek} • เกิด $birthStr • อายุย่าง ${customer.turningAge} ปี',
                                                  style: TextStyle(fontSize: 11.5, color: context.subTextColor),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ),
                                          ),
                                          // Copy button
                                          AnimatedPressable(
                                            scaleDown: 0.90,
                                            onTap: () => _copyNoteToClipboard(customer),
                                            borderRadius: BorderRadius.circular(10),
                                            child: Tooltip(
                                              message: 'คัดลอกบันทึก',
                                              child: Container(
                                                width: 42,
                                                height: 42,
                                                alignment: Alignment.center,
                                                decoration: BoxDecoration(
                                                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : const Color(0xFFF7F4EE),
                                                  borderRadius: BorderRadius.circular(10),
                                                  border: Border.all(color: context.borderColor),
                                                ),
                                                child: Icon(Icons.copy_rounded, size: 17, color: context.subTextColor),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),

                                      const SizedBox(height: 12),

                                      // Note Body Text (Pure, breathable typography without nested borders)
                                      Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131A29) : AppColors.ivory,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          customer.notes,
                                          style: TextStyle(
                                            fontSize: 13.5,
                                            color: context.textColor,
                                            height: 1.55,
                                          ),
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      // Footer info
                                      Wrap(
                                        alignment: WrapAlignment.spaceBetween,
                                        crossAxisAlignment: WrapCrossAlignment.center,
                                        spacing: 8,
                                        runSpacing: 4,
                                        children: [
                                          if (customer.address.isNotEmpty || customer.province.isNotEmpty)
                                            ConstrainedBox(
                                              constraints: const BoxConstraints(maxWidth: 130),
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(Icons.location_on_outlined, size: 13, color: context.mutedTextColor),
                                                  const SizedBox(width: 4),
                                                  Flexible(
                                                    child: Text(
                                                      customer.address.isNotEmpty ? customer.address : customer.province,
                                                      style: TextStyle(fontSize: 11.5, color: context.mutedTextColor),
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  'แตะเพื่อดูรายละเอียดดวง',
                                                  style: TextStyle(
                                                    fontSize: 11.5,
                                                    color: context.goldColor,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Icon(Icons.chevron_right_rounded, size: 14, color: context.goldColor),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
