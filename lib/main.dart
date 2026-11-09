import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'models/customer.dart';
import 'services/customer_service.dart';
import 'utils/app_colors.dart';
import 'views/customer_directory_view.dart';
import 'views/home_view.dart';
import 'widgets/customer_detail_dialog.dart';
import 'widgets/customer_form_dialog.dart';
import 'services/consultation_service.dart';
import 'security/app_lock_controller.dart';
import 'security/pin_store.dart';
import 'security/pin_entry_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env');
    final supabaseUrl = dotenv.env['SUPABASE_URL'];
    final supabaseKey = dotenv.env['SUPABASE_PUBLISHABLE_KEY'];

    if (supabaseUrl != null &&
        supabaseUrl.isNotEmpty &&
        supabaseKey != null &&
        supabaseKey.isNotEmpty) {
      await Supabase.initialize(
        url: supabaseUrl,
        publishableKey: supabaseKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        storageOptions: const StorageClientOptions(
          retryAttempts: 10,
        ),
      );
    }
  } catch (e) {
    debugPrint('Supabase/Dotenv init skipped or failed: $e. Using local storage fallback.');
  }

  runApp(const HoraDayApp());
}

class HoraDayApp extends StatelessWidget {
  const HoraDayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: AppThemeController.themeModeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'Hora Day - ระบบจัดการลูกดวง & วันเกิดมงคล',
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            scrollbars: true,
          ),
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // Warm Zen Washi Theme (โหมดสว่าง: สบายตา คลีน มินิมอล)
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.caramelBronze,
              primary: AppColors.caramelBronze,
              surface: AppColors.ivory,
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: AppColors.ivory,
            fontFamily: GoogleFonts.sarabun().fontFamily,
            textTheme: GoogleFonts.sarabunTextTheme(
              ThemeData.light().textTheme,
            ).copyWith(
              displayLarge: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.darkText),
              displayMedium: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.darkText),
              displaySmall: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.darkText),
              headlineLarge: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.darkText),
              headlineMedium: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.darkText),
              headlineSmall: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.darkText),
              titleLarge: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.darkText),
              titleMedium: GoogleFonts.prompt(fontWeight: FontWeight.w600, color: AppColors.darkText),
              titleSmall: GoogleFonts.prompt(fontWeight: FontWeight.w600, color: AppColors.darkText),
            ),
            cardTheme: CardThemeData(
              color: AppColors.warmCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.warmCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: AppColors.darkText),
              titleTextStyle: GoogleFonts.prompt(
                color: AppColors.darkText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: WidgetStateProperty.all(true),
              trackVisibility: WidgetStateProperty.all(true),
              thickness: WidgetStateProperty.all(8.0),
              radius: const Radius.circular(4.0),
              thumbColor: WidgetStateProperty.all(Colors.grey[600]),
            ),
          ),

          // Deep Celestial Sanctuary Theme (โหมดมืด: รัตติกาลมืดมนต์ขลัง ถนอมสายตา)
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppColors.starGold,
              primary: AppColors.starGold,
              surface: AppColors.midnightSlate,
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: AppColors.celestialVoid,
            fontFamily: GoogleFonts.sarabun().fontFamily,
            textTheme: GoogleFonts.sarabunTextTheme(
              ThemeData.dark().textTheme,
            ).copyWith(
              displayLarge: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.starlightText),
              displayMedium: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.starlightText),
              displaySmall: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.starlightText),
              headlineLarge: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.starlightText),
              headlineMedium: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.starlightText),
              headlineSmall: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.starlightText),
              titleLarge: GoogleFonts.prompt(fontWeight: FontWeight.bold, color: AppColors.starlightText),
              titleMedium: GoogleFonts.prompt(fontWeight: FontWeight.w600, color: AppColors.starlightText),
              titleSmall: GoogleFonts.prompt(fontWeight: FontWeight.w600, color: AppColors.starlightText),
            ),
            cardTheme: CardThemeData(
              color: AppColors.midnightSlate,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: AppColors.midnightSlate,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            outlinedButtonTheme: OutlinedButtonThemeData(
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              scrolledUnderElevation: 0,
              surfaceTintColor: Colors.transparent,
              iconTheme: const IconThemeData(color: AppColors.starlightText),
              titleTextStyle: GoogleFonts.prompt(
                color: AppColors.starlightText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            scrollbarTheme: ScrollbarThemeData(
              thumbVisibility: WidgetStateProperty.all(true),
              trackVisibility: WidgetStateProperty.all(true),
              thickness: WidgetStateProperty.all(8.0),
              radius: const Radius.circular(4.0),
              thumbColor: WidgetStateProperty.all(Colors.grey[400]),
            ),
          ),

          home: const MainNavigationShell(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatefulWidget {
  const MainNavigationShell({super.key});

  @override
  State<MainNavigationShell> createState() => _MainNavigationShellState();
}

class _MainNavigationShellState extends State<MainNavigationShell>
    with WidgetsBindingObserver {
  late final CustomerService _customerService;
  late final ConsultationService _consultationService;
  late final PinStore _pinStore;
  late final AppLockController _lockController;
  int _currentTabIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _customerService = CustomerService();
    _consultationService = ConsultationService();
    final isWeb = kIsWeb;
    _pinStore = PinStore(isWeb: isWeb);
    _lockController = AppLockController(pinStore: _pinStore, isWeb: isWeb);
    _checkLock();
  }

  Future<void> _checkLock() async {
    final shouldLock = await _lockController.shouldLock();
    if (!shouldLock) {
      if (mounted) setState(() {});
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      await _lockController.onBackground();
    } else if (state == AppLifecycleState.resumed) {
      await _lockController.onForeground();
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lockController.dispose();
    _customerService.dispose();
    _consultationService.dispose();
    super.dispose();
  }

  void _openAddCustomerDialog() {
    CustomerFormDialog.show(
      context,
      onSave: (newCustomer) async {
        try {
          await _customerService.addCustomer(newCustomer);
          if (mounted) {
            final name = newCustomer.fullName.isNotEmpty
                ? newCustomer.fullName
                : (newCustomer.nickname.isNotEmpty ? newCustomer.nickname : newCustomer.lineId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('เพิ่มข้อมูล "$name" เรียบร้อยแล้ว'),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF047857),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('บันทึกข้อมูลไม่สำเร็จ: $e'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      },
    );
  }

  void _openEditCustomerDialog(Customer customer) {
    CustomerFormDialog.show(
      context,
      initialCustomer: customer,
      onSave: (updatedCustomer) async {
        try {
          await _customerService.updateCustomer(updatedCustomer);
          if (mounted) {
            final name = updatedCustomer.fullName.isNotEmpty
                ? updatedCustomer.fullName
                : (updatedCustomer.nickname.isNotEmpty ? updatedCustomer.nickname : updatedCustomer.lineId);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text('บันทึกการแก้ไขข้อมูล "$name" แล้ว'),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFF1E293B),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('แก้ไขข้อมูลไม่สำเร็จ: $e'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      },
    );
  }

  void _openCustomerDetailDialog(Customer customer) {
    CustomerDetailDialog.show(
      context,
      customer: customer,
      consultationService: _consultationService,
      onUpdate: (updated) async {
        try {
          await _customerService.updateCustomer(updated);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('อัปเดตข้อมูลเรียบร้อยแล้ว'),
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('อัปเดตข้อมูลไม่สำเร็จ: $e'),
                behavior: SnackBarBehavior.floating,
                backgroundColor: const Color(0xFFDC2626),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            );
          }
        }
      },
      onDelete: () => _executeDeleteCustomer(customer),
    );
  }

  Future<void> _executeDeleteCustomer(Customer customer) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await _customerService.deleteCustomer(customer.id);
      if (mounted) {
        _showUndoSnackbar(
          messenger,
          customer,
          onUndo: () async {
            await _customerService.restoreCustomer(customer.id);
            if (mounted) {
              messenger.showSnackBar(
                SnackBar(
                  content: Text('กู้คืน "${customer.fullName.isNotEmpty ? customer.fullName : customer.lineId}" เรียบร้อยแล้ว'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFF059669),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              );
            }
          },
        );
      }
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(
            content: Text('ลบข้อมูลไม่สำเร็จ: $e'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: const Color(0xFFDC2626),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  void _confirmDeleteCustomer(Customer customer) {
    final isMobile = MediaQuery.sizeOf(context).width < 640;
    final content = Container(
      constraints: BoxConstraints(
        maxWidth: 400,
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(22))
            : BorderRadius.circular(14),
        border: isMobile ? null : Border.all(color: context.borderColor),
        boxShadow: [
          BoxShadow(
            color: context.isDark ? const Color(0x66000000) : const Color(0x1F000000),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
          children: [
            if (isMobile)
              Container(
                width: 38,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: context.isDark ? const Color(0xFF475569) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2).withValues(alpha: context.isDark ? 0.2 : 1.0),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 28),
            ),
            const SizedBox(height: 14),
            Text(
              'ลบข้อมูลลูกดวง',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: context.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'คุณต้องการลบข้อมูลของ "${customer.displayName}" ใช่หรือไม่?\nข้อมูลประวัติและบันทึกคำพยากรณ์ทั้งหมดจะถูกลบถาวร',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: context.subTextColor, height: 1.4),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(color: context.borderColor),
                    ),
                    child: Text('ยกเลิก', style: TextStyle(color: context.subTextColor, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _executeDeleteCustomer(customer);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDC2626),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text('ลบข้อมูล', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );

    if (isMobile) {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (context) => content,
      );
    } else {
      showDialog(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.transparent,
          child: content,
        ),
      );
    }
  }

  /// แสดง snackbar หลังลบ (soft delete) พร้อมปุ่ม "เลิกทำ" 5 วินาที
  void _showUndoSnackbar(
    ScaffoldMessengerState messenger,
    Customer customer, {
    required VoidCallback onUndo,
  }) {
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.delete_outline_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'ลบข้อมูล "${customer.fullName.isNotEmpty ? customer.fullName : customer.lineId}" เรียบร้อยแล้ว',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFDC2626),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'เลิกทำ',
          textColor: Colors.white,
          onPressed: onUndo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppLockWrapper(
      lockController: _lockController,
      child: ListenableBuilder(
        listenable: _customerService,
        builder: (context, _) {
          final upcomingCustomers = _customerService.upcomingBirthdayCustomers;

          return Scaffold(
            backgroundColor: context.canvasColor,
            body: IndexedStack(
              index: _currentTabIndex,
              children: [
                HomeView(
                  customerService: _customerService,
                  onNavigateToTab: (tabIndex) {
                    setState(() => _currentTabIndex = tabIndex);
                  },
                  onAddNewCustomer: _openAddCustomerDialog,
                ),
                CustomerDirectoryView(
                  customerService: _customerService,
                  onAddNewCustomer: _openAddCustomerDialog,
                  onEditCustomer: _openEditCustomerDialog,
                  onCustomerDetail: _openCustomerDetailDialog,
                  onDeleteCustomer: _confirmDeleteCustomer,
                ),
              ],
            ),
            bottomNavigationBar: SafeArea(
            top: false,
            child: Container(
              decoration: BoxDecoration(
                color: context.isDark
                    ? AppColors.midnightSlate.withValues(alpha: 0.95)
                    : Colors.white.withValues(alpha: 0.95),
                border: Border(
                  top: BorderSide(
                    color: context.isDark ? AppColors.celestialBorder : AppColors.warmBorder,
                    width: 1.0,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: context.isDark
                        ? const Color(0x33000000)
                        : const Color(0x0A78350F),
                    blurRadius: 10,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: NavigationBar(
                selectedIndex: _currentTabIndex,
                onDestinationSelected: (index) => setState(() => _currentTabIndex = index),
                backgroundColor: Colors.transparent,
                indicatorColor: context.isDark
                    ? AppColors.starGold.withValues(alpha: 0.22)
                    : AppColors.champagne.withValues(alpha: 0.55),
                indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
                height: 64,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                destinations: [
                  NavigationDestination(
                    icon: upcomingCustomers.isNotEmpty
                        ? Badge(
                            label: Text(
                              '${upcomingCustomers.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: const Color(0xFFEF4444),
                            child: const Icon(Icons.cake_outlined),
                          )
                        : const Icon(Icons.cake_outlined),
                    selectedIcon: upcomingCustomers.isNotEmpty
                        ? Badge(
                            label: Text(
                              '${upcomingCustomers.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor: const Color(0xFFEF4444),
                            child: Icon(
                              Icons.cake,
                              color: context.goldColor,
                            ),
                          )
                        : Icon(
                            Icons.cake,
                            color: context.goldColor,
                          ),
                    label: 'วันเกิดมงคล',
                  ),
                  NavigationDestination(
                    icon: const Icon(Icons.people_alt_outlined),
                    selectedIcon: Icon(
                      Icons.people_alt,
                      color: context.goldColor,
                    ),
                    label: 'รายชื่อลูกดวง',
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}
}




