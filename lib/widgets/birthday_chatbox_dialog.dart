import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../utils/app_colors.dart';
import '../utils/app_svg_icons.dart';
import '../utils/thai_date_helper.dart';
import 'hbd_card_dialog.dart';

/// หน้าต่าง Popup รูปร่างแบบแชท (Chatbox) ขยาย Rounded 25px แสดงข้อมูลลูกค้า
/// พร้อม Animation เปิดตัวสไตล์ Chat Popup (Scale Pop + Staggered Bubbles เข้าทีละข้อความ)
class BirthdayChatboxDialog extends StatefulWidget {
  final Customer customer;
  final Function(Customer updatedCustomer)? onUpdateNotes;
  final bool isBottomSheet;

  const BirthdayChatboxDialog({
    super.key,
    required this.customer,
    this.onUpdateNotes,
    this.isBottomSheet = false,
  });

  /// แสดง Birthday Chatbox แบบ Adaptive:
  /// บนหน้าจอมือถือ (< 640px) จะเปิดเป็น Modal Bottom Sheet คล้ายแอปแชทจริง (LINE / Messages) พร้อมช่องพิมพ์ที่ลอยเหนือแป้นพิมพ์
  /// บนหน้าจอแท็บเล็ต/เดสก์ท็อป (>= 640px) จะเปิดเป็น Chat Popup Dialog กลางจอ
  static Future<void> show(
    BuildContext context, {
    required Customer customer,
    Function(Customer updatedCustomer)? onUpdateNotes,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => BirthdayChatboxDialog(
          customer: customer,
          onUpdateNotes: onUpdateNotes,
          isBottomSheet: true,
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => BirthdayChatboxDialog(
          customer: customer,
          onUpdateNotes: onUpdateNotes,
          isBottomSheet: false,
        ),
      );
    }
  }

  @override
  State<BirthdayChatboxDialog> createState() => _BirthdayChatboxDialogState();
}

class _BirthdayChatboxDialogState extends State<BirthdayChatboxDialog> {
  late Customer _currentCustomer;
  final ScrollController _scrollController = ScrollController();
  final List<String> _sentNotes = [];

  @override
  void initState() {
    super.initState();
    _currentCustomer = widget.customer;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _closeDialog() {
    Navigator.of(context).pop();
  }

  Color _getDayColor(int weekday) {
    return AppColors.getDayColor(weekday);
  }

  String _getDayColorName(int weekday) {
    switch (weekday) {
      case 1:
        return 'สีเหลือง (ธาตุดิน)';
      case 2:
        return 'สีชมพู (ธาตุลม)';
      case 3:
        return 'สีเขียว (ธาตุน้ำ)';
      case 4:
        return 'สีส้ม/แสด (ธาตุดิน)';
      case 5:
        return 'สีฟ้า/น้ำเงิน (ธาตุน้ำ)';
      case 6:
        return 'สีม่วง/ดำ (ธาตุไฟ)';
      case 7:
        return 'สีแดง (ธาตุไฟ)';
      default:
        return 'มงคล';
    }
  }

  void _copyAllCustomerInfo() {
    final c = _currentCustomer;
    final birthDateStr = ThaiDateHelper.formatFull(c.birthDate);
    final daysUntil = c.daysUntilNextBirthday;
    final bdayStatus = daysUntil == 0
        ? '🎂 วันนี้เป็นวันเกิด!'
        : '⏳ อีก $daysUntil วันถึงวันเกิด';

    final text = '''
📋 ข้อมูลลูกดวง (Hora Day)
━━━━━━━━━━━━━━━━━━━━
👤 ชื่อ-นามสกุล: ${c.fullName} ${c.nickname.isNotEmpty ? '(${c.nickname})' : ''}
📞 เบอร์โทรศัพท์: ${c.phone.isNotEmpty ? c.phone : '-'}
💬 LINE ID: ${c.lineId.isNotEmpty ? c.lineId : '-'}
🎂 วันเกิด: ${c.thaiDayOfWeek} ที่ $birthDateStr
⏰ เวลาตกฟาก: ${c.birthTime != null && c.birthTime!.isNotEmpty ? c.birthTime : 'ไม่ระบุ'}
⏳ อายุ: ${c.currentAge} ปี (ครบรอบ ${c.turningAge} ปี)
🎈 สถานะ: $bdayStatus
🎨 สีมงคล: ${_getDayColorName(c.birthDate.weekday)}
📍 ที่อยู่: ${c.address.isNotEmpty ? c.address : (c.province.isNotEmpty ? c.province : '-')}
📝 บันทึกดวงชะตา: ${c.notes.isNotEmpty ? c.notes : '-'}
━━━━━━━━━━━━━━━━━━━━''';

    Clipboard.setData(ClipboardData(text: text.trim()));
    _showSnackBar('คัดลอกข้อมูลลูกค้าทั้งหมดแล้ว');
  }

  void _copyField(String label, String value) {
    Clipboard.setData(ClipboardData(text: value));
    _showSnackBar('คัดลอก $label ($value) แล้ว');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: const Color(0xFF1E293B),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        duration: const Duration(seconds: 2),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final customer = _currentCustomer;
    final dayColor = _getDayColor(customer.birthDate.weekday);
    final daysUntil = customer.daysUntilNextBirthday;
    final isToday = daysUntil == 0;
    final birthDateStr = ThaiDateHelper.formatFull(customer.birthDate);

    if (widget.isBottomSheet) {
      final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
      final screenHeight = MediaQuery.sizeOf(context).height;

      return Padding(
        padding: EdgeInsets.only(bottom: keyboardHeight),
        child: Container(
          height: screenHeight * 0.88,
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 32,
                offset: Offset(0, -8),
              ),
            ],
          ),
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                // Grab Handle Indicator
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    decoration: BoxDecoration(
                      color: context.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildChatColumn(customer, dayColor, daysUntil, isToday, birthDateStr),
                ),
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
          maxWidth: 520,
          maxHeight: math.min(680.0, MediaQuery.sizeOf(context).height * 0.90),
        ),
        child: Container(
          clipBehavior: Clip.antiAlias,
          // Chatbox รูปร่างแบบแชท ขยาย Rounded 25px
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: context.borderColor, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 32,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: _buildChatColumn(customer, dayColor, daysUntil, isToday, birthDateStr),
        ),
      ),
    );
  }

  Widget _buildChatColumn(
    Customer customer,
    Color dayColor,
    int daysUntil,
    bool isToday,
    String birthDateStr,
  ) {
    return Column(
      children: [
        // ==========================================
        // 1. CHAT HEADER BAR (ขอบบนมน 25px)
        // ==========================================
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(25),
                        topRight: Radius.circular(25),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x15000000),
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Chat Avatar พร้อม Dot สถานะวันเกิด
                        Stack(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: dayColor.withValues(alpha: 0.25),
                                shape: BoxShape.circle,
                                border: Border.all(color: dayColor, width: 2),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                customer.initialLetter,
                                style: TextStyle(
                                  color: dayColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 14,
                                height: 14,
                                decoration: BoxDecoration(
                                  color: isToday ? const Color(0xFFEF4444) : const Color(0xFF10B981),
                                  shape: BoxShape.circle,
                                  border: Border.all(color: const Color(0xFF1E293B), width: 2),
                                ),
                                alignment: Alignment.center,
                                child: isToday
                                    ? AppSvgIcons.cake(size: 8, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 12),

                        // Contact Info & Status
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.displayName,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Container(
                                    width: 7,
                                    height: 7,
                                    decoration: BoxDecoration(
                                      color: isToday ? const Color(0xFFF87171) : const Color(0xFF34D399),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      isToday
                                          ? 'วันนี้วันเกิด! (ครบรอบ ${customer.turningAge} ปี)'
                                          : daysUntil <= 2
                                              ? 'อีก $daysUntil วันจะถึงวันเกิด'
                                              : '${customer.thaiDayOfWeek} • อายุ ${customer.currentAge} ปี',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        color: isToday ? const Color(0xFFFCA5A5) : const Color(0xFFCBD5E1),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Quick Header Actions
                        IconButton(
                          icon: const Icon(
                            Icons.auto_awesome,
                            color: Color(0xFFFFE082),
                            size: 20,
                          ),
                          tooltip: 'อวยพรส่ง LINE',
                          onPressed: () {
                            HbdCardDialog.show(
                              context,
                              customer: customer,
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy_rounded, color: Color(0xFFCBD5E1), size: 19),
                          tooltip: 'คัดลอกข้อมูลทั้งหมด',
                          onPressed: _copyAllCustomerInfo,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 22),
                          tooltip: 'ปิดหน้าต่าง',
                          onPressed: _closeDialog,
                        ),
                      ],
                    ),
                  ),

                // ==========================================
                // 2. CHAT MESSAGES BODY
                // ==========================================
                Expanded(
                  child: Container(
                    color: context.isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                    child: ListView(
                      controller: _scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      children: [
                        // Date/Context Pill divider
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            margin: const EdgeInsets.only(bottom: 14),
                            decoration: BoxDecoration(
                              color: context.isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: context.borderColor),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.mark_chat_unread_outlined, size: 13, color: context.subTextColor),
                                const SizedBox(width: 5),
                                Text(
                                  'ข้อมูลเจ้าชะตา • ${customer.thaiDayOfWeek}',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: context.subTextColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // ----------------------------------------------------
                        // CHAT BUBBLE 1: ข้อมูลทั่วไป & ช่องทางติดต่อ
                        // ----------------------------------------------------
                        _buildIncomingChatBubble(
                          avatarIcon: Icons.account_circle_rounded,
                          avatarColor: const Color(0xFF2563EB),
                          senderName: 'ข้อมูลประวัติ & การติดต่อ',
                          bubbleColor: context.isDark ? const Color(0xFF1E293B) : Colors.white,
                          borderColor: context.borderColor,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildInfoRow(
                                icon: Icons.person_outline_rounded,
                                label: 'ชื่อ-นามสกุล',
                                value: customer.fullName,
                                valueColor: context.textColor,
                                isBold: true,
                              ),
                              if (customer.nickname.isNotEmpty)
                                _buildInfoRow(
                                  icon: Icons.badge_outlined,
                                  label: 'ชื่อเล่น',
                                  value: customer.nickname,
                                ),
                              Divider(height: 14, color: context.borderColor),
                              _buildInfoRowWithAction(
                                icon: Icons.phone_outlined,
                                label: 'เบอร์โทร',
                                value: customer.phone.isNotEmpty ? customer.phone : 'ยังไม่ระบุ',
                                onCopy: customer.phone.isNotEmpty
                                    ? () => _copyField('เบอร์โทร', customer.phone)
                                    : null,
                              ),
                              if (customer.lineId.isNotEmpty)
                                _buildInfoRowWithAction(
                                  icon: Icons.chat_bubble_outline_rounded,
                                  label: 'LINE ID',
                                  value: customer.lineId,
                                  onCopy: () => _copyField('LINE ID', customer.lineId),
                                ),
                              if (customer.address.isNotEmpty || customer.province.isNotEmpty)
                                _buildInfoRow(
                                  icon: Icons.location_on_outlined,
                                  label: 'ที่อยู่',
                                  value: customer.address.isNotEmpty
                                      ? customer.address
                                      : customer.province,
                                ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ----------------------------------------------------
                        // CHAT BUBBLE 2: ข้อมูลวันเกิด & โหราศาสตร์
                        // ----------------------------------------------------
                        _buildIncomingChatBubble(
                          avatarIcon: Icons.auto_awesome_rounded,
                          avatarColor: const Color(0xFFD97706),
                          senderName: 'ข้อมูลวันเกิด & โหราศาสตร์',
                          bubbleColor: context.isDark ? const Color(0xFF1E2538) : const Color(0xFFFFFDF5),
                          borderColor: context.isDark ? const Color(0xFF334155) : const Color(0xFFFDE68A),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Birthday Highlight Box
                              Container(
                                padding: const EdgeInsets.all(10),
                                margin: const EdgeInsets.only(bottom: 10),
                                decoration: BoxDecoration(
                                  color: isToday
                                      ? (context.isDark ? const Color(0xFF450A0A) : const Color(0xFFFEE2E2))
                                      : (context.isDark ? const Color(0xFF2C1E10) : const Color(0xFFFEF3C7)),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isToday
                                        ? (context.isDark ? const Color(0xFF991B1B) : const Color(0xFFFCA5A5))
                                        : (context.isDark ? const Color(0xFF78450A) : const Color(0xFFFCD34D)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: isToday
                                            ? const Color(0xFFDC2626).withValues(alpha: 0.15)
                                            : (context.isDark ? const Color(0xFFFDE047).withValues(alpha: 0.15) : const Color(0xFFD97706).withValues(alpha: 0.15)),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      alignment: Alignment.center,
                                      child: isToday
                                          ? AppSvgIcons.cake(
                                              size: 20,
                                              color: context.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626),
                                            )
                                          : AppSvgIcons.calendar(
                                              size: 20,
                                              color: context.isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706),
                                            ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${customer.thaiDayOfWeek} ที่ $birthDateStr',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                              color: isToday
                                                  ? (context.isDark ? const Color(0xFFFCA5A5) : const Color(0xFFDC2626))
                                                  : (context.isDark ? const Color(0xFFFDE047) : const Color(0xFF92400E)),
                                            ),
                                          ),
                                          Text(
                                            isToday
                                                ? 'วันนี้วันเกิด! ครบรอบ ${customer.turningAge} ปีเต็ม'
                                                : 'อีก $daysUntil วัน จะครบอายุ ${customer.turningAge} ปี (ปัจจุบัน ${customer.currentAge} ปี)',
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: isToday
                                                  ? (context.isDark ? const Color(0xFFFECACA) : const Color(0xFFB91C1C))
                                                  : (context.isDark ? const Color(0xFFFCD34D) : const Color(0xFFB45309)),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              _buildInfoRow(
                                icon: Icons.schedule_rounded,
                                label: 'เวลาตกฟาก',
                                value: customer.birthTime != null && customer.birthTime!.isNotEmpty
                                    ? customer.birthTime!
                                    : 'ไม่ได้ระบุเวลาเกิด',
                                valueColor: context.textColor,
                              ),
                              _buildInfoRow(
                                icon: Icons.palette_outlined,
                                label: 'สีมงคลเกิด',
                                value: _getDayColorName(customer.birthDate.weekday),
                                valueColor: dayColor,
                                isBold: true,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // ----------------------------------------------------
                        // CHAT BUBBLE 3: บันทึกดวงชะตา
                        // ----------------------------------------------------
                        _buildIncomingChatBubble(
                          avatarIcon: Icons.menu_book_rounded,
                          avatarColor: const Color(0xFF059669),
                          senderName: 'บันทึกดวงชะตา & หมายเหตุ',
                          bubbleColor: context.isDark ? const Color(0xFF16242B) : const Color(0xFFF0FDF4),
                          borderColor: context.isDark ? const Color(0xFF1E3A4A) : const Color(0xFFBBF7D0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                customer.notes.isNotEmpty
                                    ? customer.notes
                                    : 'ยังไม่มีบันทึกคำพยากรณ์ สามารถพิมพ์ข้อความด้านล่างเพื่อบันทึกประวัติดวงชะตาได้ทันที',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.45,
                                  color: customer.notes.isNotEmpty
                                      ? context.textColor
                                      : context.mutedTextColor,
                                  fontStyle: customer.notes.isEmpty ? FontStyle.italic : FontStyle.normal,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Outgoing Sent Notes (ถ้ามีการพิมพ์ส่งในหน้าต่างนี้)
                        ..._sentNotes.map((note) => Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: _buildOutgoingChatBubble(note),
                            )),

                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),

              ],
    );
  }

  /// กล่องข้อความสไตล์แชท (Incoming Chat Bubble พร้อมหางแชท Rounded 25px)
  Widget _buildIncomingChatBubble({
    required IconData avatarIcon,
    required Color avatarColor,
    required String senderName,
    required Color bubbleColor,
    required Color borderColor,
    required Widget child,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar icon
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: avatarColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: avatarColor.withValues(alpha: 0.3)),
          ),
          alignment: Alignment.center,
          child: Icon(avatarIcon, size: 16, color: avatarColor),
        ),
        const SizedBox(width: 8),

        // Bubble Content (ขยาย Rounded 25px มีมุมมนแบบ Chat Bubble)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, bottom: 4),
                child: Text(
                  senderName,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: context.subTextColor,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6), // หางแชท
                    topRight: Radius.circular(22),
                    bottomLeft: Radius.circular(22),
                    bottomRight: Radius.circular(22),
                  ),
                  border: Border.all(color: borderColor),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x08000000),
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
                child: child,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// กล่องข้อความตอบกลับสไตล์แชท (Outgoing Chat Bubble ฝั่งขวา)
  Widget _buildOutgoingChatBubble(String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Flexible(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: context.isDark ? const Color(0xFF0284C7) : AppColors.deepSlate,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(22),
                topRight: Radius.circular(6), // หางแชทฝั่งขวา
                bottomLeft: Radius.circular(22),
                bottomRight: Radius.circular(22),
              ),
            ),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.white,
                height: 1.35,
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.caramelBronze.withValues(alpha: 0.85),
          child: const Icon(Icons.person, size: 13, color: Colors.white),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: context.mutedTextColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.subTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? context.textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithAction({
    required IconData icon,
    required String label,
    required String value,
    VoidCallback? onCopy,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Icon(icon, size: 15, color: context.mutedTextColor),
          const SizedBox(width: 8),
          SizedBox(
            width: 85,
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: context.subTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: context.textColor,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onCopy != null)
            InkWell(
              onTap: onCopy,
              borderRadius: BorderRadius.circular(6),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                child: Icon(Icons.copy_rounded, size: 14, color: AppColors.caramelBronze),
              ),
            ),
        ],
      ),
    );
  }

}
