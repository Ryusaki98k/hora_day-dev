import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../utils/app_colors.dart';
import '../utils/thai_date_helper.dart';

/// ฟอร์มบันทึกดวงชะตาลูกดวงแบบ Distilled (Distilled Focus: Name & Birthday)
/// ตัดทอนความซับซ้อนให้เหลือเฉพาะสิ่งสำคัญที่สุด: "ชื่อลูกดวง + วันเกิด"
/// ส่วนข้อมูลเสริม (เบอร์โทร, LINE, เวลาเกิด, บันทึก) จะซ่อนอยู่ใน Progressive Disclosure
class CustomerFormDialog extends StatefulWidget {
  final Customer? initialCustomer;
  final DateTime? defaultBirthDate;
  final Function(Customer customer) onSave;
  final bool isBottomSheet;

  const CustomerFormDialog({
    super.key,
    this.initialCustomer,
    this.defaultBirthDate,
    required this.onSave,
    this.isBottomSheet = false,
  });

  /// แสดง Form เพิ่ม/แก้ไขข้อมูลลูกดวงแบบ Adaptive:
  /// บนหน้าจอมือถือ (< 640px) จะเปิดเป็น Modal Bottom Sheet รูดขึ้นจากด้านล่าง
  /// บนหน้าจอแท็บเล็ต/เดสก์ท็อป (>= 640px) จะเปิดเป็น Dialog กลางจอ
  static Future<void> show(
    BuildContext context, {
    Customer? initialCustomer,
    DateTime? defaultBirthDate,
    required Function(Customer customer) onSave,
  }) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;
    if (isMobile) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => CustomerFormDialog(
          initialCustomer: initialCustomer,
          defaultBirthDate: defaultBirthDate,
          onSave: onSave,
          isBottomSheet: true,
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (context) => CustomerFormDialog(
          initialCustomer: initialCustomer,
          defaultBirthDate: defaultBirthDate,
          onSave: onSave,
          isBottomSheet: false,
        ),
      );
    }
  }

  @override
  State<CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<CustomerFormDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _nicknameController;
  late TextEditingController _lineIdController;
  late TextEditingController _phoneController;
  late TextEditingController _provinceController;
  late TextEditingController _addressController;
  late TextEditingController _birthTimeController;
  late TextEditingController _notesController;

  late DateTime _selectedBirthDate;
  bool _showAdvancedFields = false;

  @override
  void initState() {
    super.initState();
    final c = widget.initialCustomer;
    _fullNameController = TextEditingController(text: c?.fullName ?? '');
    _nicknameController = TextEditingController(text: c?.nickname ?? '');
    _lineIdController = TextEditingController(text: c?.lineId ?? '');
    _phoneController = TextEditingController(text: c?.phone ?? '');
    _provinceController = TextEditingController(text: c?.province ?? '');
    _addressController = TextEditingController(text: c?.address ?? '');
    _birthTimeController = TextEditingController(text: c?.birthTime ?? '');
    _notesController = TextEditingController(text: c?.notes ?? '');

    if (c != null) {
      _selectedBirthDate = c.birthDate;
      // หากมีข้อมูลเสริมอยู่แล้ว ให้เปิดขยายรอไว้เลย
      if (c.phone.isNotEmpty || c.lineId.isNotEmpty || c.province.isNotEmpty || c.address.isNotEmpty || c.notes.isNotEmpty || (c.birthTime != null && c.birthTime!.isNotEmpty)) {
        _showAdvancedFields = true;
      }
    } else {
      // ใช้วันที่ที่ส่งเข้ามาเป็นค่าเริ่มต้น (เช่น วันที่กำลังเลือกใน Birthday Hub) หรือวันเริ่มต้น
      _selectedBirthDate = widget.defaultBirthDate ?? DateTime(1995, 1, 1);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nicknameController.dispose();
    _lineIdController.dispose();
    _phoneController.dispose();
    _provinceController.dispose();
    _addressController.dispose();
    _birthTimeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _getThaiDayOfWeek(DateTime date) {
    const days = [
      'วันจันทร์',
      'วันอังคาร',
      'วันพุธ',
      'วันพฤหัสบดี',
      'วันศุกร์',
      'วันเสาร์',
      'วันอาทิตย์',
    ];
    return days[date.weekday - 1];
  }

  Color _getDayColor(int weekday) {
    switch (weekday) {
      case 1:
        return const Color(0xFFF59E0B);
      case 2:
        return const Color(0xFFEC4899);
      case 3:
        return const Color(0xFF10B981);
      case 4:
        return const Color(0xFFF97316);
      case 5:
        return const Color(0xFF06B6D4);
      case 6:
        return const Color(0xFF8B5CF6);
      case 7:
        return const Color(0xFFEF4444);
      default:
        return AppColors.caramelBronze;
    }
  }

  String _getElementName(int weekday) {
    switch (weekday) {
      case 1:
      case 4:
        return 'ธาตุดิน';
      case 3:
      case 5:
        return 'ธาตุน้ำ';
      case 2:
        return 'ธาตุลม';
      case 6:
      case 7:
        return 'ธาตุไฟ';
      default:
        return 'ธาตุดิน';
    }
  }

  int _calculateTurningAge(DateTime birthDate) {
    final now = DateTime.now();
    var nextBirthdayYear = now.year;
    final thisYearBirthday = DateTime(now.year, birthDate.month, birthDate.day);
    if (thisYearBirthday.isBefore(DateTime(now.year, now.month, now.day))) {
      nextBirthdayYear++;
    }
    return nextBirthdayYear - birthDate.year;
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      helpText: 'เลือกวันเกิดของลูกดวง',
      cancelText: 'ยกเลิก',
      confirmText: 'ตกลง',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              headerBackgroundColor: AppColors.caramelBronze,
              headerForegroundColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final newCustomer = Customer(
      id: widget.initialCustomer?.id ?? 'c_${DateTime.now().millisecondsSinceEpoch}',
      fullName: _fullNameController.text.trim(),
      nickname: _nicknameController.text.trim(),
      birthDate: _selectedBirthDate,
      birthTime: _birthTimeController.text.trim().isNotEmpty
          ? _birthTimeController.text.trim()
          : null,
      lineId: _lineIdController.text.trim(),
      phone: _phoneController.text.trim(),
      province: _provinceController.text.trim(),
      address: _addressController.text.trim(),
      notes: _notesController.text.trim(),
      consentGiven: widget.initialCustomer?.consentGiven,
      consentAt: widget.initialCustomer?.consentAt,
      consentNote: widget.initialCustomer?.consentNote,
      createdAt: widget.initialCustomer?.createdAt,
      lastConsultationDate: widget.initialCustomer?.lastConsultationDate ?? DateTime.now(),
    );

    widget.onSave(newCustomer);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initialCustomer != null;

    if (widget.isBottomSheet) {
      return Container(
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
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
              // Grab handle indicator
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
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: EdgeInsets.fromLTRB(
                    20,
                    8,
                    20,
                    MediaQuery.of(context).viewInsets.bottom + 24,
                  ),
                  child: _buildDistilledForm(isEditing),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 520,
          maxHeight: MediaQuery.sizeOf(context).height * 0.90,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.borderColor, width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x24000000),
                blurRadius: 28,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: _buildDistilledForm(isEditing),
          ),
        ),
      ),
    );
  }

  Widget _buildDistilledForm(bool isEditing) {
    final birthDateStr = ThaiDateHelper.formatFull(_selectedBirthDate);
    final thaiDay = _getThaiDayOfWeek(_selectedBirthDate);
    final dayColor = _getDayColor(_selectedBirthDate.weekday);
    final elementName = _getElementName(_selectedBirthDate.weekday);
    final turningAge = _calculateTurningAge(_selectedBirthDate);

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Distilled Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.champagne.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.7)),
                      ),
                      child: Icon(
                        isEditing ? Icons.edit_calendar_rounded : Icons.cake_rounded,
                        color: context.goldColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'แก้ไขวันเกิดลูกดวง' : 'เพิ่มวันเกิดลูกดวง',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: context.textColor,
                              letterSpacing: -0.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ระบุชื่อและวันเกิดเพื่อผูกดวงชะตาทันที',
                            style: TextStyle(fontSize: 12, color: context.subTextColor),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: context.subTextColor),
                tooltip: 'ปิด',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: context.borderColor),
          const SizedBox(height: 16),

          // 2. PRIMARY FOCUS 1: ชื่อลูกดวง (Name & Nickname)
          Row(
            children: [
              Icon(Icons.badge_outlined, size: 16, color: context.goldColor),
              const SizedBox(width: 6),
              Text(
                'ชื่อลูกดวง *',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: context.textColor),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _fullNameController,
                  autofocus: !isEditing,
                  textInputAction: TextInputAction.next,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: context.textColor),
                  decoration: InputDecoration(
                    labelText: 'ชื่อ - นามสกุล',
                    hintText: 'เช่น พิมพ์พิชชา วงศ์สวรรค์',
                    prefixIcon: Icon(Icons.person_outline, size: 20, color: context.goldColor),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'กรุณาระบุชื่อลูกดวง' : null,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _nicknameController,
                  textInputAction: TextInputAction.done,
                  style: TextStyle(fontSize: 14, color: context.textColor),
                  decoration: InputDecoration(
                    labelText: 'ชื่อเล่น',
                    hintText: 'เช่น น้องพิมพ์',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. PRIMARY FOCUS 2: วันเกิดมงคล (Birthday Hero Selector with Astrological Preview)
          Row(
            children: [
              Icon(Icons.cake_outlined, size: 16, color: context.goldColor),
              const SizedBox(width: 6),
              Text(
                'วันเกิดลูกดวง *',
                style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: context.textColor),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Hero Interactive Birthday Card
          InkWell(
            onTap: _pickDate,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131A29) : const Color(0xFFFDFBF7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF78521A) : AppColors.amberGold.withValues(alpha: 0.8),
                  width: 1.4,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Circular Day Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: dayColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: dayColor, width: 1.5),
                    ),
                    alignment: Alignment.center,
                    child: Icon(Icons.cake_rounded, color: dayColor, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              birthDateStr,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: context.textColor,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.edit_calendar_rounded, size: 16, color: context.goldColor),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            // Day badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: dayColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: dayColor.withValues(alpha: 0.4)),
                              ),
                              child: Text(
                                thaiDay,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: dayColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Element badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF282015) : AppColors.warmSand,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                elementName,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: context.goldColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),

                            // Turning Age
                            Text(
                              'อายุย่าง $turningAge ปี',
                              style: TextStyle(fontSize: 11.5, color: context.subTextColor, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // 4. Primary Fast Submit Button (กดบันทึกได้ทันทีด้วย ชื่อ + วันเกิด)
          ElevatedButton.icon(
            onPressed: _submit,
            icon: Icon(isEditing ? Icons.check_circle_rounded : Icons.bookmark_add_rounded, size: 19),
            label: Text(
              isEditing ? 'บันทึกการแก้ไข' : 'บันทึกวันเกิดลูกดวง',
              style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.caramelBronze,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 2,
              shadowColor: AppColors.caramelBronze.withValues(alpha: 0.3),
            ),
          ),

          const SizedBox(height: 14),

          // 5. Progressive Disclosure: ข้อมูลเสริม (ไม่บังคับ)
          InkWell(
            onTap: () => setState(() => _showAdvancedFields = !_showAdvancedFields),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _showAdvancedFields ? Icons.remove_circle_outline_rounded : Icons.add_circle_outline_rounded,
                    size: 16,
                    color: context.goldColor,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _showAdvancedFields
                        ? 'ซ่อนข้อมูลติดต่อและบันทึกเพิ่มเติม'
                        : '+ เพิ่มข้อมูลติดต่อ & บันทึกเพิ่มเติม (ไม่บังคับ)',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: context.goldColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Collapsible Advanced Fields
          if (_showAdvancedFields)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // เวลาเกิด
                  TextFormField(
                    controller: _birthTimeController,
                    decoration: InputDecoration(
                      labelText: 'เวลาเกิด (เวลาตกฟาก)',
                      hintText: 'เช่น 09:30 น.',
                      prefixIcon: const Icon(Icons.access_time_rounded, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // เบอร์โทรศัพท์ & LINE ID (Optional)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'เบอร์โทรศัพท์',
                            hintText: '08X-XXX-XXXX',
                            prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextFormField(
                          controller: _lineIdController,
                          decoration: InputDecoration(
                            labelText: 'LINE ID',
                            hintText: 'เช่น line_user',
                            prefixIcon: const Icon(Icons.chat_bubble_outline, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // จังหวัด & ที่อยู่
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: TextFormField(
                          controller: _provinceController,
                          decoration: InputDecoration(
                            labelText: 'จังหวัด',
                            hintText: 'เช่น กรุงเทพฯ',
                            prefixIcon: const Icon(Icons.location_on_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 6,
                        child: TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'ที่อยู่',
                            hintText: 'เขต/อำเภอ, ถนน...',
                            prefixIcon: const Icon(Icons.home_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // บันทึกคำพยากรณ์
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'บันทึกคำพยากรณ์ / โน้ต',
                      hintText: 'บันทึกเรื่องที่ปรึกษา, ฤกษ์มงคล...',
                      prefixIcon: const Icon(Icons.history_edu_rounded, size: 20),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
