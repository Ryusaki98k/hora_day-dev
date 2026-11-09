import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// หน้านโยบายความเป็นส่วนตัว (PDPA) แบบ static
/// แสดงข้อมูลเกี่ยวกับการเก็บรวบรวม ใช้ และเปิดเผยข้อมูลส่วนบุคคล
class PdpaPolicyPage extends StatelessWidget {
  const PdpaPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.canvasColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text(
          'นโยบายความเป็นส่วนตัว',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSection(
            context,
            title: '1. ข้อมูลที่เราเก็บรวบรวม',
            content: 'แอปเก็บข้อมูลส่วนบุคคลที่ท่านมอบให้โดยตรง เช่น ชื่อ-นามสกุล, ชื่อเล่น, LINE ID, '
                'เบอร์โทรศัพท์, จังหวัด, ที่อยู่, วันเกิด, เวลาเกิด และบันทึกคำพยากรณ์ '
                'ข้อมูลเหล่านี้ใช้เพื่อจัดทำดวงชะตา ส่งคำอวยพรวันเกิด และให้บริการปรึกษาด้านโหราศาสตร์',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '2. วัตถุประสงค์การเก็บข้อมูล',
            content: 'ข้อมูลส่วนบุคคลถูกเก็บรวบรวมเพื่อวัตถุประสงค์ดังต่อไปนี้เท่านั้น:\n'
                '• จัดทำบันทึกดวงชะตาและวันเกิดของลูกดวง\n'
                '• ส่งคำอวยพรและแจ้งเตือนวันเกิดใกล้ถึง\n'
                '• ให้บริการปรึกษาและพยากรณ์ดวงชะตา\n'
                '• สำรองข้อมูลและกู้คืนข้อมูลเมื่อท่านร้องขอ',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '3. การเปิดเผยข้อมูล',
            content: 'แอปไม่เปิดเผยข้อมูลส่วนบุคคลแก่บุคคลภายนอก เว้นแต่ได้รับความยินยอมจากท่าน '
                'หรือเป็นไปตามกฎหมายที่บังคับใช้ ข้อมูลทั้งหมดเก็บอยู่ในอุปกรณ์ของท่าน '
                'หรือในระบบ Supabase ที่ท่านเชื่อมต่อ',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '4. สิทธิของเจ้าของข้อมูล',
            content: 'ท่านมีสิทธิในการ:\n'
                '• ถอนความยินยอมในการประมวลผลข้อมูลส่วนบุคคล\n'
                '• ขอเข้าถึง แก้ไข หรือลบข้อมูลส่วนบุคคลของตน\n'
                '• ขอสำเนาข้อมูลที่เก็บไว้ (ผ่านฟังก์ชันสำรองข้อมูล)\n'
                '• ขอให้ลบข้อมูลส่วนบุคคลทั้งหมดอย่างถาวร (ต้องยืนยันสองขั้นตอน)',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '5. การรักษาความปลอดภัย',
            content: 'แอปใช้มาตรการรักษาความปลอดภัยที่เหมาะสมเพื่อป้องกันการเข้าถึง '
                'หรือเปิดเผยข้อมูลโดยไม่ได้รับอนุญาต ข้อมูลที่ส่งไปยัง Supabase ถูกเข้ารหัส '
                'ผ่าน HTTPS ทุกครั้ง',
          ),
          const SizedBox(height: 16),
          _buildSection(
            context,
            title: '6. การรักษาข้อมูล',
            content: 'ข้อมูลส่วนบุคคลจะถูกเก็บไว้ตราบเท่าที่ท่านยังใช้งานแอป '
                'หรือจนกว่าท่านจะร้องขอให้ลบ เมื่อลบข้อมูลแล้ว ข้อมูลจะถูกทำลายอย่างถาวร '
                'และไม่สามารถกู้คืนได้',
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.champagne.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.5)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ผู้ควบคุมข้อมูลส่วนบุคคล',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Hora Day — สมุดดวงชะตา & ศูนย์วันเกิดมงคล\n'
                  'อีเมล: privacy@horaday.example\n'
                  'วันที่เผยแพร่: ตุลาคม 2569',
                  style: TextStyle(fontSize: 12, color: context.subTextColor, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required String title, required String content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: context.textColor,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          content,
          style: TextStyle(fontSize: 13, color: context.subTextColor, height: 1.5),
        ),
      ],
    );
  }
}
