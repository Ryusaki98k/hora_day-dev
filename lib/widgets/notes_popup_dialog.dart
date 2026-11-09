import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/app_colors.dart';
import 'customer_detail_dialog.dart';

/// ป๊อปอัปพระสมุดคำพยากรณ์ (Astrological Notes Codex Popup Dialog)
/// เปิดขึ้นด้วยแอนิเมชันกางสมุด 3D พร้อมอ่านและค้นหาบันทึกคำพยากรณ์
class NotesPopupDialog extends StatefulWidget {
  final CustomerService customerService;
  final VoidCallback onOpenFullNotes;

  const NotesPopupDialog({
    super.key,
    required this.customerService,
    required this.onOpenFullNotes,
  });

  static Future<void> show(
    BuildContext context, {
    required CustomerService customerService,
    required VoidCallback onOpenFullNotes,
  }) {
    return showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (context) {
        return NotesPopupDialog(
          customerService: customerService,
          onOpenFullNotes: onOpenFullNotes,
        );
      },
    );
  }

  @override
  State<NotesPopupDialog> createState() => _NotesPopupDialogState();
}

class _NotesPopupDialogState extends State<NotesPopupDialog> {
  String _searchQuery = '';
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
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            c.nickname.toLowerCase().contains(q) ||
            c.notes.toLowerCase().contains(q) ||
            c.thaiDayOfWeek.toLowerCase().contains(q);
      }).toList();
    }
    return list;
  }

  void _copyNote(Customer customer) {
    Clipboard.setData(ClipboardData(text: '${customer.displayName} (${customer.thaiDayOfWeek})\n${customer.notes}'));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'คัดลอกบันทึกของ ${customer.displayName} แล้ว',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: AppColors.darkText,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredNotes();
    final allNotesCount = widget.customerService.customersWithNotes.length;
    final isMobile = MediaQuery.of(context).size.width < 640;

    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isMobile ? MediaQuery.of(context).size.width * 0.94 : 520,
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: context.borderColor),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x28000000),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. Grimoire Header (ปกพระสมุดสีเขียวหยก)
                  Container(
                    padding: const EdgeInsets.fromLTRB(18, 14, 14, 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: context.isDark
                            ? const [Color(0xFF064E3B), Color(0xFF0F172A)]
                            : const [Color(0xFFD1FAE5), Color(0xFFA7F3D0)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border(
                        bottom: BorderSide(color: context.isDark ? const Color(0xFF065F46) : const Color(0xFF6EE7B7), width: 1),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: const [
                              BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 2)),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF10B981),
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'พระสมุดคำพยากรณ์',
                                style: TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                  color: context.textColor,
                                ),
                              ),
                              Text(
                                'บันทึกดวงชะตาทั้งหมด $allNotesCount เรื่อง',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: context.isDark ? const Color(0xFF6EE7B7) : const Color(0xFF047857),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Close Button
                        IconButton(
                          icon: Icon(Icons.close_rounded, size: 20, color: context.textColor),
                          onPressed: () => Navigator.of(context).pop(),
                          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ),

                  // 2. Search Input
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: context.isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: context.borderColor),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) => setState(() => _searchQuery = val),
                        style: TextStyle(fontSize: 13, color: context.textColor),
                        decoration: InputDecoration(
                          hintText: 'ค้นหาคำทำนาย, ลูกดวง, วันเกิด...',
                          hintStyle: TextStyle(fontSize: 12.5, color: context.mutedTextColor),
                          prefixIcon: Icon(Icons.search_rounded, size: 18, color: context.goldColor),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear_rounded, size: 16, color: context.mutedTextColor),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                        ),
                      ),
                    ),
                  ),

                  // 3. Notes Folio List
                  Flexible(
                    child: filtered.isEmpty
                        ? Center(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: AppColors.champagne.withValues(alpha: 0.4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.history_edu_rounded, size: 24, color: AppColors.caramelBronze),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _searchQuery.isNotEmpty ? 'ไม่พบบันทึกที่ตรงกับคำค้นหา' : 'ยังไม่มีบันทึกดวงชะตา',
                                    style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: context.textColor),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            physics: const BouncingScrollPhysics(),
                            padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                            itemBuilder: (context, index) {
                              final customer = filtered[index];
                              final weekday = customer.birthDate.weekday;
                              final dayColor = _getDayMineralColor(weekday);
                              final dayAbbr = _getThaiWeekdayAbbr(weekday);

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: context.cardColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: context.borderColor),
                                  boxShadow: const [
                                    BoxShadow(color: Color(0x04000000), blurRadius: 4, offset: Offset(0, 1)),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Top Header with Wax Seal
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(10, 8, 8, 6),
                                        color: dayColor.withValues(alpha: context.isDark ? 0.18 : 0.08),
                                        child: Row(
                                          children: [
                                            // Wax Seal Circle
                                            Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: dayColor,
                                                shape: BoxShape.circle,
                                              ),
                                              alignment: Alignment.center,
                                              child: Text(
                                                dayAbbr,
                                                style: const TextStyle(
                                                  fontSize: 9.5,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Row(
                                                children: [
                                                  Text(
                                                    customer.displayName,
                                                    style: TextStyle(
                                                      fontSize: 13,
                                                      fontWeight: FontWeight.bold,
                                                      color: context.textColor,
                                                    ),
                                                  ),
                                                  if (customer.nickname.isNotEmpty) ...[
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '(${customer.nickname})',
                                                      style: TextStyle(
                                                        fontSize: 11,
                                                        color: context.goldColor,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ],
                                                  const Spacer(),
                                                  Text(
                                                    '${customer.thaiDayOfWeek} • อายุ ${customer.turningAge} ปี',
                                                    style: TextStyle(fontSize: 10.5, color: context.mutedTextColor),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(Icons.copy_rounded, size: 14, color: context.subTextColor),
                                              onPressed: () => _copyNote(customer),
                                              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
                                              padding: EdgeInsets.zero,
                                              tooltip: 'คัดลอกบันทึก',
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Parchment Reading Body
                                      InkWell(
                                        onTap: () {
                                          Navigator.of(context).pop();
                                          CustomerDetailDialog.show(
                                            context,
                                            customer: customer,
                                            onUpdate: (updated) => widget.customerService.updateCustomer(updated),
                                            onDelete: () => widget.customerService.deleteCustomer(customer.id),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Text(
                                            customer.notes,
                                            style: TextStyle(
                                              fontSize: 12.5,
                                              color: context.textColor,
                                              height: 1.45,
                                            ),
                                            maxLines: 4,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // 4. Footer Action (เปิดสมุดบันทึกเต็มจอ)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: context.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      border: Border(top: BorderSide(color: context.borderColor)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'พบ ${filtered.length} บันทึก',
                          style: TextStyle(fontSize: 12, color: context.subTextColor, fontWeight: FontWeight.w500),
                        ),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                            widget.onOpenFullNotes();
                          },
                          icon: const Icon(Icons.open_in_full_rounded, size: 15),
                          label: const Text('เปิดสมุดเต็มจอ'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF059669),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
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
    );
  }
}
