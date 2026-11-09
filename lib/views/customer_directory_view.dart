import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';
import '../utils/animation_helper.dart';
import '../utils/app_colors.dart';
import 'widgets/customer_sort_modal.dart';
import 'widgets/customer_filter_bar.dart';
import 'widgets/customer_ledger_item.dart';
import 'widgets/customer_empty_state.dart';

export 'widgets/customer_sort_modal.dart' show CustomerSortOption;

/// หน้ารายชื่อลูกดวง / สารบบโหราจารย์ (Astrological Roster & Ledger Hub)
/// ดีไซน์ใหม่หมดจด: โครงสร้างไม่เหมือนเดิม ด้วยโหมดสำรับดวง + ทำเนียบปูมโหร และแถบจตุรธาตุ ๔ สัมพันธ์
class CustomerDirectoryView extends StatefulWidget {
  final CustomerService customerService;
  final VoidCallback onAddNewCustomer;
  final Function(Customer customer) onEditCustomer;
  final Function(Customer customer) onCustomerDetail;
  final Function(Customer customer) onDeleteCustomer;

  const CustomerDirectoryView({
    super.key,
    required this.customerService,
    required this.onAddNewCustomer,
    required this.onEditCustomer,
    required this.onCustomerDetail,
    required this.onDeleteCustomer,
  });

  @override
  State<CustomerDirectoryView> createState() => _CustomerDirectoryViewState();
}

class _CustomerDirectoryViewState extends State<CustomerDirectoryView> {
  String _searchQuery = '';
  String _selectedFilterTag = 'ทั้งหมด';
  CustomerSortOption _sortOption = CustomerSortOption.soonestBirthday;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Customer> _getFilteredAndSortedCustomers() {
    var list = List<Customer>.from(widget.customerService.customers);

    // 1. Tag Filtering
    if (_selectedFilterTag == 'ใกล้วันเกิด') {
      final threshold = widget.customerService.nearBirthdayThreshold;
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      list = list.where((c) {
        final days = c.daysUntilBirthdayOn(today);
        return days >= 0 && days <= threshold;
      }).toList();
    } else if (_selectedFilterTag == 'มีบันทึก') {
      list = list.where((c) => c.notes.trim().isNotEmpty).toList();
    } else if (_selectedFilterTag.startsWith('วัน')) {
      list = list.where((c) => c.thaiDayOfWeek == _selectedFilterTag).toList();
    }

    // 2. Search Query Filtering
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.trim().toLowerCase();
      list = list.where((c) {
        return c.fullName.toLowerCase().contains(q) ||
            c.nickname.toLowerCase().contains(q) ||
            c.phone.contains(q) ||
            c.lineId.toLowerCase().contains(q) ||
            c.province.toLowerCase().contains(q) ||
            c.thaiDayOfWeek.toLowerCase().contains(q);
      }).toList();
    }

    // 3. Sorting
    switch (_sortOption) {
      case CustomerSortOption.soonestBirthday:
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        list.sort((a, b) => a.daysUntilBirthdayOn(today).compareTo(b.daysUntilBirthdayOn(today)));
        break;
      case CustomerSortOption.nameAsc:
        list.sort((a, b) => a.displayName.compareTo(b.displayName));
        break;
      case CustomerSortOption.newest:
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }

    return list;
  }

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'คัดลอก$label: $text เรียบร้อยแล้ว',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        backgroundColor: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF1E293B)
            : AppColors.darkText,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _clearFilter() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _selectedFilterTag = 'ทั้งหมด';
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredCustomers = _getFilteredAndSortedCustomers();
    final allCustomers = widget.customerService.customers;
    final totalCount = allCustomers.length;
    final upcomingCount = widget.customerService.upcomingBirthdayCustomers.length;
    final notesCount = widget.customerService.customersWithNotes.length;
    final hasActiveFilter = _searchQuery.isNotEmpty || _selectedFilterTag != 'ทั้งหมด';

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.champagne.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.7)),
              ),
              child: const AnimatedSparkleIcon(icon: Icons.menu_book_rounded, color: AppColors.caramelBronze, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'สารบบลูกดวง',
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
                    'รายชื่อทั้งหมด $totalCount ท่าน',
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
          const AppThemeToggleButton(compact: true),
          const SizedBox(width: 8),
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Material(
              color: context.cardColor,
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                onTap: () => CustomerSortModal.show(
                  context: context,
                  currentOption: _sortOption,
                  onOptionSelected: (opt) => setState(() => _sortOption = opt),
                ),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: context.borderColor),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.sort_rounded, size: 16, color: context.goldColor),
                      const SizedBox(width: 4),
                      Text(
                        getSortOptionLabel(_sortOption),
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.bold,
                          color: context.goldColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),

      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: FloatingActionButton.extended(
          heroTag: 'fab_add_customer',
          onPressed: widget.onAddNewCustomer,
          backgroundColor: AppColors.caramelBronze,
          foregroundColor: Colors.white,
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: const Icon(Icons.person_add_rounded, size: 20),
          label: const Text(
            'บันทึกดวงใหม่',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: Column(
        children: [
          // Search bar + filter carousel
          CustomerFilterBar(
            searchController: _searchController,
            searchQuery: _searchQuery,
            selectedFilterTag: _selectedFilterTag,
            upcomingCount: upcomingCount,
            notesCount: notesCount,
            onSearchChanged: (val) => setState(() => _searchQuery = val),
            onFilterTagChanged: (tag) => setState(() => _selectedFilterTag = tag),
            onClearSearch: () {
              _searchController.clear();
              setState(() => _searchQuery = '');
            },
          ),

          // Status bar (shown only when filtering/searching)
          if (hasActiveFilter)
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'พบ ${filteredCustomers.length} ท่าน (จากทั้งหมด $totalCount ท่าน)',
                    style: TextStyle(
                      fontSize: 11.5,
                      color: context.subTextColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  InkWell(
                    onTap: _clearFilter,
                    borderRadius: BorderRadius.circular(6),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      child: Row(
                        children: [
                          Icon(Icons.refresh_rounded, size: 13, color: context.goldColor),
                          const SizedBox(width: 3),
                          Text(
                            'ล้างตัวกรอง',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: context.goldColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main list or empty state
          Expanded(
            child: filteredCustomers.isEmpty
                ? CustomerEmptyState(
                    hasActiveFilter: hasActiveFilter,
                    searchQuery: _searchQuery,
                    onClearFilter: _clearFilter,
                    onAddNewCustomer: widget.onAddNewCustomer,
                  )
                : CustomerAstrologicalLedger(
                    customers: filteredCustomers,
                    onCustomerDetail: widget.onCustomerDetail,
                    onEditCustomer: widget.onEditCustomer,
                    onDeleteCustomer: widget.onDeleteCustomer,
                    onCopyToClipboard: _copyToClipboard,
                  ),
          ),
        ],
      ),
    );
  }
}

