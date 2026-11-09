import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_svg_icons.dart';
import '../utils/line_helper.dart';
import '../utils/thai_date_helper.dart';
import '../views/greeting_card_studio_view.dart';

/// การ์ดอวยพรวันเกิดมงคล — Warm Zen champagne/bronze, ready-to-paste for LINE
class HbdCardDialog extends StatefulWidget {
  final Customer customer;
  final CustomerService? customerService;
  final bool isBottomSheet;

  const HbdCardDialog({
    super.key,
    required this.customer,
    this.customerService,
    this.isBottomSheet = false,
  });

  /// Adaptive: bottom sheet on phone, centered dialog on wider screens
  static Future<void> show(
    BuildContext context, {
    required Customer customer,
    CustomerService? customerService,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => HbdCardDialog(
          customer: customer,
          customerService: customerService,
          isBottomSheet: true,
        ),
      );
    }
    return showDialog(
      context: context,
      builder: (context) => HbdCardDialog(
        customer: customer,
        customerService: customerService,
      ),
    );
  }

  @override
  State<HbdCardDialog> createState() => _HbdCardDialogState();
}

class _HbdCardDialogState extends State<HbdCardDialog> {
  int _selectedBlessingIndex = 0;
  late TextEditingController _customTextController;
  bool _isEditingBlessing = false;

  final List<Map<String, String>> _blessings = [
    {
      'title': 'โชคลาภ & การเงิน',
      'text':
          'สุขสันต์วันเกิด ขออำนาจบารมีและสิ่งศักดิ์สิทธิ์ดลบันดาลให้มีแต่โชคลาภ เงินทองไหลมาเทมาไม่ขาดสาย หยิบจับสิ่งใดเป็นเงินเป็นทอง ดวงชะตารุ่งโรจน์ มั่งคั่งร่ำรวยตลอดทั้งปี',
    },
    {
      'title': 'การงาน & ความสำเร็จ',
      'text':
          'สุขสันต์วันเกิด ขอให้หน้าที่การงานเจริญก้าวหน้า มีชื่อเสียงบารมี ผู้ใหญ่เมตตาอุปถัมภ์ ปัญหาอุปสรรคใดๆ คลี่คลาย สำเร็จสมหวังในทุกเป้าหมายที่ตั้งใจ',
    },
    {
      'title': 'สุขภาพ & ความสุข',
      'text':
          'สุขสันต์วันเกิด ขออวยพรให้มีสุขภาพร่างกายแข็งแรง ปราศจากโรคภัยไข้เจ็บ จิตใจผ่องใสสงบ มีแต่รอยยิ้ม ความอบอุ่น และความสุขรายล้อมในทุกๆ วัน',
    },
    {
      'title': 'ความรัก & เมตตา',
      'text':
          'สุขสันต์วันเกิด ขอให้มีเสน่ห์เมตตามหานิยม ไปที่ใดก็มีคนรักใคร่เอ็นดู ความรักสุขสมหวัง พบเจอแต่กัลยาณมิตรที่ดี เกื้อหนุนนำพาชีวิตไปสู่ความเจริญรุ่งเรือง',
    },
  ];

  @override
  void initState() {
    super.initState();
    _customTextController = TextEditingController(text: _blessings[0]['text']);
  }

  @override
  void dispose() {
    _customTextController.dispose();
    super.dispose();
  }

  void _onBlessingSelected(int index) {
    setState(() {
      _selectedBlessingIndex = index;
      _customTextController.text = _blessings[index]['text']!;
      _isEditingBlessing = false;
    });
  }

  String _getFormattedBlessing() {
    final customer = widget.customer;
    final name = customer.greetingName;
    final blessingText = _customTextController.text.trim();
    return '✦ สุขสันต์วันเกิด คุณ$name ✦\n\n'
        '$blessingText\n\n'
        '— ด้วยความปรารถนาดี จากอาจารย์หมอดูประจำตัว —';
  }

  void _copyBlessing() {
    final textToCopy = _getFormattedBlessing();

    Clipboard.setData(ClipboardData(text: textToCopy));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'คัดลอกคำอวยพรแล้ว · วางใน LINE ได้เลย',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.caramelBronze,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      ),
    );
  }

  void _copyAndOpenLine() {
    final textToCopy = _getFormattedBlessing();
    LineHelper.openLineChat(
      context,
      rawLineId: widget.customer.lineId,
      customerName: widget.customer.displayName,
      copyMessageBeforeOpen: textToCopy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final customer = widget.customer;
    final turningAge = customer.turningAge;
    final birthDateStr = ThaiDateHelper.formatDayMonth(customer.birthDate);
    final blessingText = _customTextController.text;
    final sheet = widget.isBottomSheet;

    final scrollBody = SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, sheet ? 8 : 20, 20, 22),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: context.isDark ? const Color(0xFF1E293B) : AppColors.champagne,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: context.borderColor,
                          ),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: context.goldColor,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'อวยพรวันเกิดมงคล',
                              style: GoogleFonts.prompt(
                                fontSize: 16.5,
                                fontWeight: FontWeight.w700,
                                color: context.textColor,
                                letterSpacing: -0.2,
                              ),
                            ),
                            Text(
                              'คัดลอกส่ง LINE ได้ทันที',
                              style: TextStyle(
                                fontSize: 12,
                                color: context.subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close_rounded,
                          color: context.subTextColor,
                        ),
                        tooltip: 'ปิด',
                        constraints: const BoxConstraints(
                          minWidth: 44,
                          minHeight: 44,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Warm Zen blessing card preview
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: context.isDark
                            ? const [
                                Color(0xFF1E2538),
                                Color(0xFF131A29),
                                Color(0xFF0F172A),
                              ]
                            : const [
                                Color(0xFFF8F1E3),
                                Color(0xFFF3E8D4),
                                Color(0xFFE8D5B5),
                              ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: context.borderColor,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 22,
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: context.isDark ? const Color(0xFF1E293B) : Colors.white.withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: context.borderColor,
                            ),
                          ),
                          child: Text(
                            'สุขสันต์วันเกิดมงคล',
                            style: GoogleFonts.prompt(
                              color: context.goldColor,
                              letterSpacing: 0.4,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          customer.displayName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.prompt(
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                            color: context.textColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${customer.thaiDayOfWeek} • $birthDateStr • ครบรอบ $turningAge ปี',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: context.subTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: context.borderColor,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Icon(
                                Icons.auto_awesome,
                                color: context.goldColor,
                                size: 14,
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: context.borderColor,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: context.isDark ? const Color(0xFF0B0F19) : Colors.white.withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Text(
                            blessingText,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.5,
                              height: 1.6,
                              color: context.textColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          '— ด้วยความปรารถนาดี จากอาจารย์หมอดูประจำตัว —',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 11,
                            color: context.subTextColor,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'เลือกธีมคำอวยพร',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: context.textColor,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isEditingBlessing = !_isEditingBlessing;
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: context.goldColor,
                          minimumSize: const Size(48, 44),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                        ),
                        icon: Icon(
                          _isEditingBlessing
                              ? Icons.check_rounded
                              : Icons.edit_note_rounded,
                          size: 18,
                        ),
                        label: Text(
                          _isEditingBlessing ? 'เสร็จสิ้น' : 'แก้ไข',
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: List.generate(_blessings.length, (index) {
                      final isSelected =
                          _selectedBlessingIndex == index && !_isEditingBlessing;
                      final item = _blessings[index];
                      return ChoiceChip(
                        label: Text(item['title']!),
                        selected: isSelected,
                        selectedColor: context.goldColor.withValues(alpha: 0.18),
                        backgroundColor: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        labelStyle: TextStyle(
                          fontSize: 12,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w500,
                          color: isSelected
                              ? context.goldColor
                              : context.textColor,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? context.goldColor
                              : context.borderColor,
                        ),
                        onSelected: (selected) {
                          if (selected) _onBlessingSelected(index);
                        },
                      );
                    }),
                  ),
                  if (_isEditingBlessing) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: _customTextController,
                      maxLines: 4,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'พิมพ์หรือแก้ไขคำอวยพรได้ตามต้องการ...',
                        hintStyle: TextStyle(color: context.mutedTextColor),
                        filled: true,
                        fillColor: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                        contentPadding: const EdgeInsets.all(12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: context.borderColor,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: context.goldColor,
                            width: 1.4,
                          ),
                        ),
                      ),
                      style: TextStyle(fontSize: 13.5, height: 1.45, color: context.textColor),
                    ),
                  ],
                  const SizedBox(height: 18),
                  if (widget.customer.lineId.isNotEmpty) ...[
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _copyAndOpenLine,
                        icon: const Icon(Icons.chat_bubble_rounded, size: 18),
                        label: Text(
                          'คัดลอก & เปิดแชท LINE (${widget.customer.lineId})',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00B900),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  SizedBox(
                    height: 44,
                    child: OutlinedButton.icon(
                      onPressed: _copyBlessing,
                      icon: const Icon(Icons.copy_rounded, size: 17),
                      label: Text(
                        widget.customer.lineId.isNotEmpty
                            ? 'คัดลอกคำอวยพรอย่างเดียว'
                            : 'คัดลอกคำอวยพรส่ง LINE',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: context.goldColor,
                        side: BorderSide(color: context.goldColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 44,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => GreetingCardStudioView(
                              customerService:
                                  widget.customerService ?? CustomerService(),
                              initialCustomer: widget.customer,
                            ),
                          ),
                        );
                      },
                      icon: AppSvgIcons.palette(
                        size: 18,
                        color: context.isDark ? AppColors.celestialVoid : Colors.white,
                      ),
                      label: const Text(
                        'ออกแบบการ์ด & ดาวน์โหลดลงเครื่อง (HD)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.goldColor,
                        foregroundColor: context.isDark ? AppColors.celestialVoid : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
    );

    final decoration = BoxDecoration(
      color: context.cardColor,
      borderRadius: sheet
          ? const BorderRadius.vertical(top: Radius.circular(20))
          : BorderRadius.circular(16),
      border: Border.all(color: context.borderColor),
      boxShadow: const [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 20,
          offset: Offset(0, 8),
        ),
      ],
    );

    if (sheet) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.92,
          ),
          child: Container(
            decoration: decoration,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderColor,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                Expanded(child: scrollBody),
              ],
            ),
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 480,
          maxHeight: MediaQuery.sizeOf(context).height * 0.90,
        ),
        child: Container(
          decoration: decoration,
          child: scrollBody,
        ),
      ),
    );
  }
}
