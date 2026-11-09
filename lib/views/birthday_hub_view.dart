import 'package:flutter/material.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/animation_helper.dart';
import '../utils/app_colors.dart';
import '../utils/thai_date_helper.dart';
import '../widgets/birthday_hub/birthday_astrolabe_grid.dart';
import '../widgets/birthday_hub/birthday_hub_header_dial.dart';
import '../widgets/birthday_hub/birthday_meridian_timeline.dart';
import '../widgets/birthday_hub/birthday_spotlight_pavilion.dart';
import '../widgets/customer_detail_dialog.dart';
import '../widgets/customer_form_dialog.dart';
import 'greeting_card_studio_view.dart';

enum BirthdayViewMode {
  timeline,
  calendar,
}

/// หน้าจอศูนย์วันเกิดมงคล (Auspicious Birthday Sanctuary - ปูมโหรวันเกิดดวงดาว)
/// โครงสร้างสไตล์ "Astrological Celestial Meridian & Horizon":
/// 1. Interactive Celestial Date Ribbon & Scope Selector
/// 2. Auspicious Spotlight Pavilion (เวทีฉลองขวัญวันเกิดวันนี้)
/// 3. The Celestial Meridian Timeline (สายธารกาลเวลาเส้นเมอริเดียนดวงดาว)
/// 4. The 7-Mineral Astrolabe Grid (ปฏิทินจักรา ๗ แร่ธาตุ)
class BirthdayHubView extends StatefulWidget {
  final CustomerService customerService;
  final VoidCallback? onNavigateToDirectory;

  const BirthdayHubView({
    super.key,
    required this.customerService,
    this.onNavigateToDirectory,
  });

  @override
  State<BirthdayHubView> createState() => _BirthdayHubViewState();
}

class _BirthdayHubViewState extends State<BirthdayHubView> {
  late DateTime _displayedMonth;
  int? _selectedDay;
  BirthdayViewMode _viewMode = BirthdayViewMode.timeline;
  String _activeScope = 'ทั้งหมด'; // 'ทั้งหมด', 'สัปดาห์นี้', 'วันนี้'

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _displayedMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
  }

  void _prevMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month - 1, 1);
      _selectedDay = null;
    });
  }

  void _nextMonth() {
    setState(() {
      _displayedMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 1);
      _selectedDay = null;
    });
  }

  void _goToCurrentMonth() {
    final now = DateTime.now();
    setState(() {
      _displayedMonth = DateTime(now.year, now.month, 1);
      _selectedDay = now.day;
    });
  }

  void _handleScopeChanged(String scopeKey) {
    setState(() {
      _activeScope = scopeKey;
      if (scopeKey == 'วันนี้') {
        final now = DateTime.now();
        _selectedDay = now.day;
      } else {
        _selectedDay = null;
      }
    });
  }

  List<Customer> _getCustomersForCurrentMonth() {
    return widget.customerService.customers.where((c) {
      return c.birthDate.month == _displayedMonth.month;
    }).toList()
      ..sort((a, b) => a.birthDate.day.compareTo(b.birthDate.day));
  }

  void _openCustomerDetail(Customer customer) {
    CustomerDetailDialog.show(
      context,
      customer: customer,
      onUpdate: (updated) => widget.customerService.updateCustomer(updated),
      onDelete: () => widget.customerService.deleteCustomer(customer.id),
    );
  }

  void _openGreetingCardStudio([Customer? customer]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => GreetingCardStudioView(
          customerService: widget.customerService,
          initialCustomer: customer,
        ),
      ),
    );
  }

  void _openAddBirthdayCustomer([DateTime? date]) {
    final targetDate = date ??
        (_selectedDay != null
            ? DateTime(_displayedMonth.year, _displayedMonth.month, _selectedDay!)
            : DateTime.now());

    CustomerFormDialog.show(
      context,
      defaultBirthDate: targetDate,
      onSave: (newCustomer) {
        widget.customerService.addCustomer(newCustomer);
        setState(() {});
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('บันทึกวันเกิด "${newCustomer.displayName}" (${newCustomer.thaiDayOfWeek}) เรียบร้อยแล้ว'),
                ),
              ],
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color(0xFF047857),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = now.year == _displayedMonth.year && now.month == _displayedMonth.month;
    final totalDaysInMonth = DateTime(_displayedMonth.year, _displayedMonth.month + 1, 0).day;
    final firstWeekday = DateTime(_displayedMonth.year, _displayedMonth.month, 1).weekday % 7;

    final monthTitle = ThaiDateHelper.formatMonthYear(_displayedMonth);
    final monthCustomers = _getCustomersForCurrentMonth();
    final todayBirthdays = widget.customerService.todayBirthdayCustomers;
    final upcomingBirthdays = widget.customerService.upcomingBirthdayCustomers
        .where((c) => c.daysUntilNextBirthday > 0)
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 10,
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.champagne, Color(0xFFF9F3E5)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.6)),
              ),
              child: const AnimatedSparkleIcon(color: AppColors.caramelBronze, size: 18),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'เรือนวันเกิดมงคล',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: context.textColor,
                      letterSpacing: -0.3,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    'เดือน$monthTitle • ${monthCustomers.length} ท่าน',
                    style: TextStyle(fontSize: 11.5, color: context.subTextColor, fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'สตูดิโอการ์ดอวยพรมงคล',
            icon: Icon(
              Icons.card_giftcard_rounded,
              color: context.goldColor,
              size: 22,
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => GreetingCardStudioView(
                    customerService: widget.customerService,
                  ),
                ),
              );
            },
          ),
          // View Mode Switcher Capsule (Timeline vs Calendar)
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: context.borderColor),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x06000000),
                    blurRadius: 4,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildCapsuleModeBtn(
                    mode: BirthdayViewMode.timeline,
                    icon: Icons.timeline_rounded,
                    label: 'สายธาร',
                  ),
                  _buildCapsuleModeBtn(
                    mode: BirthdayViewMode.calendar,
                    icon: Icons.calendar_view_month_rounded,
                    label: 'ผังจักรา',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            physics: const BouncingScrollPhysics(),
            children: [
              // ==========================================
              // 1. MONTH CELESTIAL DIAL & SCOPE PILLS
              // ==========================================
              BirthdayHubHeaderDial(
                monthTitle: monthTitle,
                isCurrentMonth: isCurrentMonth,
                todayCount: todayBirthdays.length,
                upcomingCount: upcomingBirthdays.length,
                monthCount: monthCustomers.length,
                activeScope: _activeScope,
                onPrevMonth: _prevMonth,
                onNextMonth: _nextMonth,
                onGoToCurrentMonth: _goToCurrentMonth,
                onScopeChanged: _handleScopeChanged,
              ),

              const SizedBox(height: 16),

              // ==========================================
              // 2. TODAY'S SPOTLIGHT PAVILION (เวทีฉลองขวัญ)
              // ==========================================
              BirthdaySpotlightPavilion(
                todayBirthdays: todayBirthdays,
                upcomingBirthdays: upcomingBirthdays,
                now: now,
                customerService: widget.customerService,
                onOpenCustomerDetail: _openCustomerDetail,
                onSendCard: _openGreetingCardStudio,
              ),

              const SizedBox(height: 20),

              // ==========================================
              // 3. MAIN DUAL VIEW: CELESTIAL MERIDIAN TIMELINE OR 7-MINERAL ASTROLABE
              // ==========================================
              if (_viewMode == BirthdayViewMode.timeline)
                BirthdayMeridianTimeline(
                  todayBirthdays: todayBirthdays,
                  upcomingBirthdays: upcomingBirthdays,
                  monthCustomers: monthCustomers,
                  displayedMonth: _displayedMonth,
                  activeScope: _activeScope,
                  selectedDay: _selectedDay,
                  now: now,
                  onOpenCustomerDetail: _openCustomerDetail,
                  onOpenAddCustomer: _openAddBirthdayCustomer,
                )
              else
                BirthdayAstrolabeGrid(
                  totalDaysInMonth: totalDaysInMonth,
                  firstWeekday: firstWeekday,
                  isCurrentMonth: isCurrentMonth,
                  now: now,
                  displayedMonth: _displayedMonth,
                  monthCustomers: monthCustomers,
                  selectedDay: _selectedDay,
                  onSelectDay: (day) => setState(() => _selectedDay = day),
                  onOpenCustomerDetail: _openCustomerDetail,
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- View Mode Capsule Button ---
  Widget _buildCapsuleModeBtn({
    required BirthdayViewMode mode,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _viewMode == mode;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final showLabel = screenWidth >= 400;

    return Semantics(
      label: 'มุมมอง $label',
      button: true,
      selected: isSelected,
      child: Tooltip(
        message: label,
        child: AnimatedPressable(
          scaleDown: 0.90,
          onTap: () => setState(() => _viewMode = mode),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
            padding: EdgeInsets.symmetric(horizontal: showLabel ? 14 : 10, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.caramelBronze : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isSelected
                  ? const [
                      BoxShadow(
                        color: Color(0x22A87532),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 15,
                  color: isSelected ? Colors.white : context.mutedTextColor,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 5),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : context.subTextColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
