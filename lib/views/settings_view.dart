import 'package:flutter/material.dart';

import '../services/customer_service.dart';
import '../models/customer.dart';
import '../utils/app_colors.dart';

/// หน้า Settings — เข้าจากไอคอนใน header ของ Home
/// ประกอบด้วย: เกณฑ์ใกล้วันเกิด, ถังขยะ, เกี่ยวกับ/เวอร์ชัน
class SettingsView extends StatefulWidget {
  final CustomerService customerService;

  const SettingsView({super.key, required this.customerService});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  int _threshold = 30;

  @override
  void initState() {
    super.initState();
    _threshold = widget.customerService.nearBirthdayThreshold;
  }

  @override
  Widget build(BuildContext context) {
    final deleted = widget.customerService.deletedCustomers;
    final isCompact = MediaQuery.sizeOf(context).width < 640;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: Text(
          'การตั้งค่า',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        centerTitle: isCompact,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card: เกณฑ์ใกล้วันเกิด
          _buildSectionCard(
            context,
            title: 'เกณฑ์ "ใกล้วันเกิด"',
            subtitle: 'ลูกดวงที่จะถึงวันเกิดภายในกี่วันถือว่าใกล้',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text('จำนวนวัน: ',
                        style: TextStyle(fontSize: 14, color: context.subTextColor)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: TextFormField(
                        initialValue: _threshold.toString(),
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textColor),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: context.borderColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          isDense: true,
                        ),
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null && n > 0 && n <= 365) {
                            setState(() => _threshold = n);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('วัน', style: TextStyle(fontSize: 14, color: context.subTextColor)),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final messenger = ScaffoldMessenger.of(context);
                      await widget.customerService.setNearBirthdayThreshold(_threshold);
                      if (mounted) {
                        messenger.showSnackBar(
                          SnackBar(
                            content: const Text('บันทึกเกณฑ์ใกล้วันเกิดแล้ว'),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFF059669),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.caramelBronze,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Text('บันทึก'),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Card: ถังขยะ
          _buildSectionCard(
            context,
            title: 'ถังขยะลูกดวง',
            subtitle: '${deleted.length} รายการที่รอการลบถาวร',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (deleted.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'ถังขยะว่างเปล่า',
                      style: TextStyle(fontSize: 13, color: Colors.black54, fontStyle: FontStyle.italic),
                    ),
                  )
                else
                  ...deleted.map((c) => _trashRow(context, c)),

                const SizedBox(height: 12),
                if (deleted.isNotEmpty)
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _confirmEmptyTrash(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('ลบถาวรทั้งหมด'),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Card: เกี่ยวกับ
          _buildSectionCard(
            context,
            title: 'เกี่ยวกับแอป',
            subtitle: 'Hora Day — สมุดดวงชะตา & ศูนย์วันเกิดมงคล',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('เวอร์ชัน: 0.1.0+1',
                    style: TextStyle(fontSize: 14, color: Colors.black54)),
                const SizedBox(height: 8),
                const Text(
                  'พัฒนาสำหรับหมอดูและนักพยากรณ์ชาวไทย\n'
                  'ข้อมูลทั้งหมดเก็บในเครื่องของคุณ (หรือ Supabase ที่คุณเชื่อมต่อ)\n'
                  'สำรองข้อมูลสม่ำเสมอผ่านหน้าสำรองข้อมูล',
                  style: TextStyle(fontSize: 13, color: Colors.black54, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDark
                ? const Color(0x33000000)
                : const Color(0x0A000000),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                    ),
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: context.subTextColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _trashRow(BuildContext context, Customer c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9),
            ),
            alignment: Alignment.center,
            child: const Text('🗑️', style: TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  c.displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'ลบเมื่อ ${_formatTime(c.deletedAt)}',
                  style: TextStyle(fontSize: 11, color: context.subTextColor),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.restore, color: Color(0xFF059669), size: 18),
                tooltip: 'กู้คืน',
                onPressed: () async {
                  await widget.customerService.restoreCustomer(c.id);
                  setState(() {});
                },
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
              IconButton(
                icon: const Icon(Icons.delete_forever, color: Colors.red, size: 18),
                tooltip: 'ลบถาวร',
                onPressed: () => _confirmHardDelete(context, c),
                constraints: const BoxConstraints(),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime? dt) {
    if (dt == null) return '-';
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmHardDelete(BuildContext context, Customer c) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('ลบถาวร', style: TextStyle(color: context.textColor)),
        content: Text(
          'คุณต้องการลบข้อมูลของ "${c.displayName}" ถาวรใช่หรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
          style: TextStyle(color: context.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              await widget.customerService.hardDeleteCustomer(c.id);
              if (mounted) {
                Navigator.of(context).pop();
                setState(() {});
              }
            },
            child: const Text('ลบถาวร'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmEmptyTrash(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: context.cardColor,
        title: Text('ลบถังขยะทั้งหมด', style: TextStyle(color: context.textColor)),
        content: Text(
          'คุณต้องการลบลูกดวงในถังขยะทั้งหมดถาวรหรือไม่?\nการกระทำนี้ไม่สามารถย้อนกลับได้',
          style: TextStyle(color: context.subTextColor),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final deleted = widget.customerService.deletedCustomers;
              for (final c in deleted) {
                await widget.customerService.hardDeleteCustomer(c.id);
              }
              if (mounted) {
                Navigator.of(context).pop();
                setState(() {});
              }
            },
            child: const Text('ลบถาวรทั้งหมด'),
          ),
        ],
      ),
    );
  }
}
