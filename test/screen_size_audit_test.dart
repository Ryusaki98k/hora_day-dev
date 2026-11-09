import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hora_day/main.dart';
import 'package:hora_day/services/customer_service.dart';
import 'package:hora_day/views/birthday_hub_view.dart';
import 'package:hora_day/views/customer_directory_view.dart';
import 'package:hora_day/views/greeting_card_studio_view.dart';
import 'package:hora_day/views/notes_view.dart';
import 'package:hora_day/views/stats_view.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ไม่ initialize Supabase ใน test: CustomerService จะ fallback เป็นข้อมูลตัวอย่าง
  // ในเครื่องโดยอัตโนมัติ (ดู _resolveDefaultSupabaseClient) — หลีกเลี่ยงการ์เรียก
  // network และ pending timer จาก RealtimeClient ที่ทำให้ testWidgets ล้มเหลวด้วย
  // "A Timer is still pending even after the widget tree was disposed"

  final testSizes = [
    const Size(320, 568),  // iPhone SE 1st gen (Narrowest mobile)
    const Size(360, 640),  // Standard Android Small
    const Size(375, 667),  // iPhone 8 / SE2
    const Size(390, 844),  // iPhone 12/13/14
    const Size(412, 915),  // Pixel 7 / Large Android
    const Size(768, 1024), // Tablet Portrait (iPad)
    const Size(1024, 768), // Tablet Landscape / Small Desktop
    const Size(1280, 800), // Standard Desktop
  ];

  for (final size in testSizes) {
    group('Screen audit at ${size.width.toInt()}x${size.height.toInt()}', () {
      testWidgets('HoraDayApp (Home & all tabs)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const HoraDayApp());
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });

      testWidgets('GreetingCardStudioView (Tab 0 and Tab 1)', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final service = CustomerService();
        await tester.pumpWidget(
          MaterialApp(
            home: GreetingCardStudioView(customerService: service),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);

        // Switch to Canva Asset Tab (Tab 1)
        final canvaTab = find.textContaining('คลังตกแต่ง Canva');
        if (canvaTab.evaluate().isNotEmpty) {
          await tester.tap(canvaTab.first, warnIfMissed: false);
          await tester.pump(const Duration(milliseconds: 300));
          expect(tester.takeException(), isNull);
        }
      });

      testWidgets('BirthdayHubView', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final service = CustomerService();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BirthdayHubView(customerService: service),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });

      testWidgets('CustomerDirectoryView', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final service = CustomerService();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: CustomerDirectoryView(
                customerService: service,
                onAddNewCustomer: () {},
                onEditCustomer: (_) {},
                onCustomerDetail: (_) {},
                onDeleteCustomer: (_) {},
              ),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });

      testWidgets('NotesView', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final service = CustomerService();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotesView(customerService: service),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });

      testWidgets('StatsView', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final service = CustomerService();
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StatsView(customerService: service),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(tester.takeException(), isNull);
      });
    });
  }
}
