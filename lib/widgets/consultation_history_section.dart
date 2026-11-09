import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/consultation.dart';
import '../models/customer.dart';
import '../services/consultation_service.dart';
import '../utils/app_colors.dart';
import '../utils/thai_date_helper.dart';

class ConsultationHistorySection extends StatefulWidget {
  final Customer customer;
  final ConsultationService consultationService;

  const ConsultationHistorySection({
    super.key,
    required this.customer,
    required this.consultationService,
  });

  @override
  State<ConsultationHistorySection> createState() => _ConsultationHistorySectionState();
}

class _ConsultationHistorySectionState extends State<ConsultationHistorySection> {
  final _contentController = TextEditingController();
  final _feeController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _contentController.dispose();
    _feeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _addConsultation() async {
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('กรุณากรอกข้อมูลก่อนบันทึก'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    double? fee;
    final feeText = _feeController.text.trim();
    if (feeText.isNotEmpty) {
      fee = double.tryParse(feeText.replaceAll(',', ''));
    }

    final consultation = Consultation(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: widget.customer.id,
      consultationDate: _selectedDate,
      content: content,
      fee: fee,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      createdAt: DateTime.now(),
    );

    try {
      await widget.consultationService.addConsultation(consultation);
      _contentController.clear();
      _feeController.clear();
      _notesController.clear();
      setState(() => _selectedDate = DateTime.now());
      HapticFeedback.lightImpact();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('บันทึกคำปรึกษาใหม่เรียบร้อยแล้ว'),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final consultations = widget.consultationService.getConsultationsForCustomer(widget.customer.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.champagne.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.7)),
              ),
              child: const Icon(Icons.history_rounded, color: AppColors.caramelBronze, size: 16),
            ),
            const SizedBox(width: 10),
            Text(
              'ประวัติการปรึกษา',
              style: GoogleFonts.prompt(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.amberGold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                '${consultations.length} รายการ',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: context.goldColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: context.cardColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: context.borderColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: context.surfaceColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: context.borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today_rounded, size: 16, color: context.goldColor),
                            const SizedBox(width: 8),
                            Text(
                              ThaiDateHelper.formatShort(_selectedDate),
                              style: TextStyle(fontSize: 13, color: context.textColor),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 120,
                    child: TextField(
                      controller: _feeController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
                      style: TextStyle(fontSize: 13, color: context.textColor),
                      decoration: InputDecoration(
                        hintText: 'ค่าบริการ',
                        hintStyle: TextStyle(fontSize: 12, color: context.mutedTextColor),
                        prefixIcon: Icon(Icons.payments_outlined, size: 16, color: context.goldColor),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.borderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.borderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.goldColor)),
                        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
                        filled: true,
                        fillColor: context.surfaceColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _contentController,
                maxLines: 3,
                style: TextStyle(fontSize: 13, color: context.textColor),
                decoration: InputDecoration(
                  hintText: 'เนื้อหาการปรึกษา *',
                  hintStyle: TextStyle(fontSize: 12, color: context.mutedTextColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.goldColor)),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: context.surfaceColor,
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _notesController,
                maxLines: 2,
                style: TextStyle(fontSize: 13, color: context.textColor),
                decoration: InputDecoration(
                  hintText: 'หมายเหตุเพิ่มเติม (ถ้ามี)',
                  hintStyle: TextStyle(fontSize: 12, color: context.mutedTextColor),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.borderColor)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.borderColor)),
                  focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: context.goldColor)),
                  contentPadding: const EdgeInsets.all(12),
                  filled: true,
                  fillColor: context.surfaceColor,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _addConsultation,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: const Text('เพิ่มคำปรึกษา'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.goldColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (consultations.isNotEmpty) ...[
          const SizedBox(height: 14),
          ...consultations.map((c) => _buildConsultationItem(context, c)),
        ],
      ],
    );
  }

  Widget _buildConsultationItem(BuildContext context, Consultation consultation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                ThaiDateHelper.formatShort(consultation.consultationDate),
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: context.goldColor,
                ),
              ),
              const Spacer(),
              if (consultation.fee != null && consultation.fee! > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${NumberFormat('#,###').format(consultation.fee)} บาท',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.green,
                    ),
                  ),
                ),
            ],
          ),
          if (consultation.content != null && consultation.content!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              consultation.content!,
              style: TextStyle(fontSize: 13, color: context.textColor, height: 1.5),
            ),
          ],
          if (consultation.notes != null && consultation.notes!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'หมายเหตุ: ${consultation.notes}',
              style: TextStyle(fontSize: 12, color: context.subTextColor, height: 1.4),
            ),
          ],
        ],
      ),
    );
  }
}
