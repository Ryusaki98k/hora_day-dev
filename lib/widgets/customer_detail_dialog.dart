import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/customer.dart';
import '../utils/app_colors.dart';
import '../utils/app_svg_icons.dart';
import '../utils/line_helper.dart';
import '../services/consultation_service.dart';
import 'consultation_history_section.dart';
import '../utils/thai_date_helper.dart';
import 'customer_form_dialog.dart';

/// Dialog / Modal Bottom Sheet แสดงรายละเอียดของลูกดวงแบบ Adaptive
/// ออกแบบตามหลัก Clean Code: แยกคอมโพเนนต์ย่อย (Decomposition), ไร้โค้ดซ้ำซ้อน (DRY),
/// และมีระบบยืนยันความปลอดภัยก่อนลบข้อมูล (Safety by Design)
class CustomerDetailDialog extends StatelessWidget {
  final Customer customer;
  final ValueChanged<Customer> onUpdate;
  final VoidCallback onDelete;
  final bool isBottomSheet;
  final ConsultationService? consultationService;

  const CustomerDetailDialog({
    super.key,
    required this.customer,
    required this.onUpdate,
    required this.onDelete,
    this.isBottomSheet = false,
    this.consultationService,
  });

  /// แสดงหน้ารายละเอียดลูกดวงแบบ Adaptive:
  /// - หน้าจอมือถือ (< 640px): เปิดเป็น Modal Bottom Sheet ปัดเลื่อนง่าย เหมาะกับนิ้วหัวแม่มือ
  /// - แท็บเล็ต/เดสก์ท็อป (>= 640px): เปิดเป็น Dialog ป๊อปอัปกลางหน้าจอ
  static Future<void> show(
    BuildContext context, {
    required Customer customer,
    required ValueChanged<Customer> onUpdate,
    required VoidCallback onDelete,
    ConsultationService? consultationService,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;

    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CustomerDetailDialog(
          customer: customer,
          onUpdate: onUpdate,
          onDelete: onDelete,
          isBottomSheet: true,
          consultationService: consultationService,
        ),
      );
    }

    return showDialog(
      context: context,
      builder: (context) => CustomerDetailDialog(
        customer: customer,
        onUpdate: onUpdate,
        onDelete: onDelete,
        isBottomSheet: false,
        consultationService: consultationService,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dayColor = AppColors.getDayColor(customer.birthDate.weekday);

    final content = _DetailBody(
      customer: customer,
      dayColor: dayColor,
      onUpdate: onUpdate,
      onDelete: () => _handleDelete(context),
      onClose: () => Navigator.of(context).pop(),
      consultationService: consultationService ?? ConsultationService(),
    );

    if (isBottomSheet) {
      return _DetailSheetShell(child: content);
    }
    return _DetailDialogShell(child: content);
  }

  // MARK: - Actions & Safety Dialog

  /// แสดง Dialog ยืนยันการลบ เพื่อป้องกันการลบข้อมูลสำคัญโดยอุบัติเหตุ
  Future<void> _handleDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ctx.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        actionsPadding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'ยืนยันการลบลูกดวง',
                style: GoogleFonts.prompt(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: ctx.textColor,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'คุณแน่ใจหรือไม่ว่าต้องการลบข้อมูลของ "${customer.displayName}"?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
          style: TextStyle(
            fontSize: 13.5,
            color: ctx.subTextColor,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'ยกเลิก',
              style: TextStyle(
                color: ctx.subTextColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'ลบข้อมูล',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      HapticFeedback.mediumImpact();
      Navigator.of(context).pop();
      onDelete();
    }
  }

  /// คัดลอกข้อความไปยังคลิปบอร์ดพร้อมสั่นสัมผัสและแสดงผล SnackBar แจ้งเตือน
  static void copyToClipboard(
    BuildContext context, {
    required String text,
    required String message,
  }) {
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  /// โทรออกเบอร์โทรศัพท์ลูกดวงผ่าน tel scheme หรือคัดลอกเมื่อเปิด dialer ไม่ได้
  static Future<void> makePhoneCall(BuildContext context, String phoneNumber) async {
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
    if (cleanNumber.isEmpty) return;

    final uri = Uri.parse('tel:$cleanNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else if (context.mounted) {
      copyToClipboard(
        context,
        text: phoneNumber,
        message: 'คัดลอกเบอร์โทร: $phoneNumber เรียบร้อยแล้ว',
      );
    }
  }
}

// =============================================================================
// MARK: - Body Layout Component
// =============================================================================

class _DetailBody extends StatelessWidget {
  final Customer customer;
  final Color dayColor;
  final ValueChanged<Customer> onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onClose;
  final ConsultationService consultationService;

  const _DetailBody({
    required this.customer,
    required this.dayColor,
    required this.onUpdate,
    required this.onDelete,
    required this.onClose,
    required this.consultationService,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _DialogHeader(),
        const SizedBox(height: 14),
        _ProfileSection(customer: customer, dayColor: dayColor),
        if (customer.isUpcomingBirthday) ...[
          const SizedBox(height: 16),
          _BirthdayAlertBanner(customer: customer),
        ],
        const SizedBox(height: 16),
        _QuickActionButtons(customer: customer, onUpdate: onUpdate),
        const SizedBox(height: 16),
        _ContactInfoCard(customer: customer),
        const SizedBox(height: 16),
        _HoroscopeNotesCard(notes: customer.notes),
        const SizedBox(height: 16),
        ConsultationHistorySection(
          customer: customer,
          consultationService: consultationService,
        ),
        const SizedBox(height: 16),
        _DialogFooter(onDelete: onDelete, onClose: onClose),
      ],
    );
  }
}


// =============================================================================
// MARK: - Shell Containers
// =============================================================================

class _DetailSheetShell extends StatelessWidget {
  final Widget child;

  const _DetailSheetShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 24,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailDialogShell extends StatelessWidget {
  final Widget child;

  const _DetailDialogShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.90,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1F000000),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: child,
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MARK: - Header Component
// =============================================================================

class _DialogHeader extends StatelessWidget {
  const _DialogHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ข้อมูลลูกดวง',
          style: GoogleFonts.prompt(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        IconButton(
          icon: Icon(Icons.close, color: context.mutedTextColor),
          tooltip: 'ปิด',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}

// =============================================================================
// MARK: - Profile Section
// =============================================================================

class _ProfileSection extends StatelessWidget {
  final Customer customer;
  final Color dayColor;

  const _ProfileSection({
    required this.customer,
    required this.dayColor,
  });

  String get _avatarInitial => customer.initialLetter;

  @override
  Widget build(BuildContext context) {
    final birthDateStr = ThaiDateHelper.formatFull(customer.birthDate);
    final hasNickname = customer.nickname.trim().isNotEmpty;
    final hasBirthTime = customer.birthTime != null && customer.birthTime!.trim().isNotEmpty;

    return Row(
      children: [
        // รูปสี่เหลี่ยมโค้งมนประดับสีกรอบแร่ธาตุมงคลประจำวันเกิด
        Semantics(
          label: 'รูปประจำตัวลูกดวง ${customer.displayName}',
          child: Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: dayColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: dayColor, width: 1.8),
            ),
            alignment: Alignment.center,
            child: Text(
              _avatarInitial,
              style: TextStyle(
                color: dayColor,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      customer.displayName,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (hasNickname) ...[
                    const SizedBox(width: 8),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: context.isDark
                              ? const Color(0xFF282015)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          customer.nickname,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.subTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${customer.thaiDayOfWeek} • เกิด $birthDateStr',
                style: TextStyle(fontSize: 13, color: context.subTextColor),
              ),
              if (hasBirthTime) ...[
                const SizedBox(height: 2),
                Text(
                  'เวลาเกิด: ${customer.birthTime}',
                  style: TextStyle(fontSize: 12, color: context.mutedTextColor),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

// =============================================================================
// MARK: - Birthday Alert Banner & Theme Resolver
// =============================================================================

class _BadgeTheme {
  final Color bg;
  final Color border;
  final Color icon;
  final Color text;

  const _BadgeTheme({
    required this.bg,
    required this.border,
    required this.icon,
    required this.text,
  });

  factory _BadgeTheme.resolve({required bool isToday, required bool isDark}) {
    if (isToday) {
      return _BadgeTheme(
        bg: isDark ? const Color(0xFF3B1219) : const Color(0xFFFFF1F2),
        border: isDark ? const Color(0xFFEF4444) : const Color(0xFFDC2626),
        icon: isDark ? const Color(0xFFF87171) : const Color(0xFFDC2626),
        text: isDark ? const Color(0xFFFECDD3) : const Color(0xFF991B1B),
      );
    }
    return _BadgeTheme(
      bg: isDark ? const Color(0xFF38230D) : const Color(0xFFFFFBEB),
      border: isDark ? const Color(0xFFF59E0B) : const Color(0xFFD97706),
      icon: isDark ? const Color(0xFFFDE047) : const Color(0xFFD97706),
      text: isDark ? const Color(0xFFFEF3C7) : const Color(0xFF92400E),
    );
  }
}

class _BirthdayAlertBanner extends StatelessWidget {
  final Customer customer;

  const _BirthdayAlertBanner({required this.customer});

  @override
  Widget build(BuildContext context) {
    final daysUntil = customer.daysUntilNextBirthday;
    final isToday = daysUntil == 0;
    final theme = _BadgeTheme.resolve(isToday: isToday, isDark: context.isDark);

    final message = isToday
        ? 'วันนี้เป็นวันคล้ายวันเกิด! (ครบรอบ ${customer.turningAge} ปี)'
        : 'ใกล้ถึงวันเกิดในอีก $daysUntil วัน (ครบรอบ ${customer.turningAge} ปี)';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.border, width: 1.2),
      ),
      child: Row(
        children: [
          isToday
              ? AppSvgIcons.cake(size: 20, color: theme.icon)
              : AppSvgIcons.hourglass(size: 20, color: theme.icon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: theme.text,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MARK: - Quick Action Buttons
// =============================================================================

class _QuickActionButtons extends StatelessWidget {
  final Customer customer;
  final ValueChanged<Customer> onUpdate;

  const _QuickActionButtons({
    required this.customer,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return Row(
      children: [
        _ActionButton(
          icon: Icons.chat_rounded,
          label: 'เปิด LINE',
          color: const Color(0xFF00B900),
          bgColor: isDark ? const Color(0xFF0F311D) : const Color(0xFFE8F9EE),
          onTap: () {
            LineHelper.openLineChat(
              context,
              rawLineId: customer.lineId,
              customerName: customer.displayName,
            );
          },
        ),
        const SizedBox(width: 8),
        _ActionButton(
          icon: Icons.edit_rounded,
          label: 'แก้ไข',
          color: context.textColor,
          bgColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
          onTap: () {
            Navigator.of(context).pop();
            CustomerFormDialog.show(
              context,
              initialCustomer: customer,
              onSave: onUpdate,
            );
          },
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: Material(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: color.withValues(alpha: 0.35), width: 1.2),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, color: color, size: 22),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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

// =============================================================================
// MARK: - Contact Info Card
// =============================================================================

class _ContactInfoCard extends StatelessWidget {
  final Customer customer;

  const _ContactInfoCard({required this.customer});

  String? _resolveFullAddress() {
    final addr = customer.address.trim();
    final prov = customer.province.trim();

    if (addr.isNotEmpty && prov.isNotEmpty) {
      return addr.contains(prov) ? addr : '$addr $prov';
    } else if (addr.isNotEmpty) {
      return addr;
    } else if (prov.isNotEmpty) {
      return prov;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final hasPhone = customer.phone.trim().isNotEmpty;
    final hasLineId = customer.lineId.trim().isNotEmpty;
    final fullAddress = _resolveFullAddress();

    final lineIdColor = hasLineId
        ? (context.isDark ? const Color(0xFF34D399) : const Color(0xFF047857))
        : context.mutedTextColor;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF131A29) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        children: [
          // เบอร์โทรศัพท์ พร้อมปุ่มโทรออก และปุ่มคัดลอก
          _ContactItemRow(
            icon: Icons.phone_outlined,
            label: 'เบอร์โทร',
            value: hasPhone ? customer.phone : 'ไม่ได้ระบุ',
            actions: hasPhone
                ? [
                    _ContactActionIconButton(
                      icon: Icons.call_rounded,
                      tooltip: 'โทรออก (${customer.phone})',
                      color: const Color(0xFF0284C7),
                      backgroundColor: const Color(0xFF0284C7).withValues(alpha: 0.10),
                      onPressed: () => CustomerDetailDialog.makePhoneCall(context, customer.phone),
                    ),
                    const SizedBox(width: 6),
                    _ContactActionIconButton(
                      icon: Icons.copy_rounded,
                      tooltip: 'คัดลอกเบอร์โทร',
                      color: context.subTextColor,
                      onPressed: () => CustomerDetailDialog.copyToClipboard(
                        context,
                        text: customer.phone,
                        message: 'คัดลอกเบอร์โทร: ${customer.phone} แล้ว',
                      ),
                    ),
                  ]
                : null,
          ),
          Divider(height: 14, color: context.borderColor),

          // LINE ID พร้อมปุ่มเปิดแชท และปุ่มคัดลอก
          _ContactItemRow(
            icon: Icons.chat_bubble_outline,
            label: 'LINE ID',
            value: hasLineId ? customer.lineId : 'ไม่ได้ระบุ',
            valueColor: lineIdColor,
            actions: hasLineId
                ? [
                    _ContactActionIconButton(
                      icon: Icons.open_in_new_rounded,
                      tooltip: 'เปิดแชท LINE',
                      color: const Color(0xFF00B900),
                      backgroundColor: const Color(0xFF00B900).withValues(alpha: 0.10),
                      onPressed: () => LineHelper.openLineChat(
                        context,
                        rawLineId: customer.lineId,
                        customerName: customer.displayName,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _ContactActionIconButton(
                      icon: Icons.copy_rounded,
                      tooltip: 'คัดลอก LINE ID',
                      color: context.subTextColor,
                      onPressed: () => CustomerDetailDialog.copyToClipboard(
                        context,
                        text: customer.lineId,
                        message: 'คัดลอก LINE ID: ${customer.lineId} แล้ว',
                      ),
                    ),
                  ]
                : null,
          ),

          // ที่อยู่ / จังหวัด (ถ้ามี)
          if (fullAddress != null) ...[
            Divider(height: 14, color: context.borderColor),
            _ContactItemRow(
              icon: Icons.home_outlined,
              label: 'ที่อยู่',
              value: fullAddress,
              actions: [
                _ContactActionIconButton(
                  icon: Icons.copy_rounded,
                  tooltip: 'คัดลอกที่อยู่',
                  color: context.subTextColor,
                  onPressed: () => CustomerDetailDialog.copyToClipboard(
                    context,
                    text: fullAddress,
                    message: 'คัดลอกที่อยู่เรียบร้อยแล้ว',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ContactItemRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;
  final List<Widget>? actions;

  const _ContactItemRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: context.subTextColor),
        const SizedBox(width: 8),
        SizedBox(
          width: 75,
          child: Text(
            label,
            style: TextStyle(fontSize: 12.5, color: context.subTextColor),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: valueColor ?? context.textColor,
            ),
          ),
        ),
        if (actions != null) ...[
          const SizedBox(width: 6),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: actions!,
          ),
        ],
      ],
    );
  }
}

/// ปุ่มไอคอนคำสั่งขนาดสัมผัสมาตรฐาน (Touch-friendly 42x42dp) สำหรับเบอร์โทร, LINE และที่อยู่
class _ContactActionIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final Color? backgroundColor;
  final VoidCallback onPressed;

  const _ContactActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.color,
    this.backgroundColor,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final defaultBg = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.03);
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);

    return Semantics(
      button: true,
      label: tooltip,
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: backgroundColor ?? defaultBg,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: borderColor,
                  width: 0.8,
                ),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
          ),
        ),
      ),
    );
  }
}

// =============================================================================
// MARK: - Horoscope Notes Card
// =============================================================================

class _HoroscopeNotesCard extends StatelessWidget {
  final String notes;

  const _HoroscopeNotesCard({required this.notes});

  @override
  Widget build(BuildContext context) {
    final hasNotes = notes.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.isDark ? const Color(0xFF131A29) : const Color(0xFFFAF9F5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 16, color: context.goldColor),
              const SizedBox(width: 8),
              Text(
                'บันทึกดวงชะตา',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: context.textColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasNotes ? notes : 'ยังไม่มีบันทึกดวงชะตาสำหรับลูกดวงท่านนี้',
            style: TextStyle(
              fontSize: 13,
              color: hasNotes ? context.textColor : context.mutedTextColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// =============================================================================
// MARK: - Dialog Footer
// =============================================================================

class _DialogFooter extends StatelessWidget {
  final VoidCallback onDelete;
  final VoidCallback onClose;

  const _DialogFooter({
    required this.onDelete,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          onPressed: onDelete,
          style: TextButton.styleFrom(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          icon: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
          label: const Text(
            'ลบ',
            style: TextStyle(
              color: Colors.red,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onClose,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.caramelBronze,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 0,
          ),
          child: const Text(
            'ปิด',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
