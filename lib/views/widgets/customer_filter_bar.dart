import 'package:flutter/material.dart';
import '../../utils/animation_helper.dart';
import '../../utils/app_colors.dart';

/// แถบค้นหา + ตัวกรองแนวนอน สำหรับสารบบลูกดวง
class CustomerFilterBar extends StatelessWidget {
  final TextEditingController searchController;
  final String searchQuery;
  final String selectedFilterTag;
  final int upcomingCount;
  final int notesCount;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onFilterTagChanged;
  final VoidCallback onClearSearch;

  static const List<String> filterOptions = [
    'ทั้งหมด',
    'ใกล้วันเกิด',
    'มีบันทึก',
    'วันจันทร์',
    'วันอังคาร',
    'วันพุธ',
    'วันพฤหัสบดี',
    'วันศุกร์',
    'วันเสาร์',
    'วันอาทิตย์',
  ];

  const CustomerFilterBar({
    super.key,
    required this.searchController,
    required this.searchQuery,
    required this.selectedFilterTag,
    required this.upcomingCount,
    required this.notesCount,
    required this.onSearchChanged,
    required this.onFilterTagChanged,
    required this.onClearSearch,
  });

  Color _getWeekdayColor(int weekday) => AppColors.getDayColor(weekday);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildSearchBar(context),
        _buildFilterCarousel(context),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: context.cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: context.borderColor),
          boxShadow: const [
            BoxShadow(
              color: Color(0x05000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: onSearchChanged,
          textInputAction: TextInputAction.search,
          style: TextStyle(fontSize: 13.5, color: context.textColor),
          decoration: InputDecoration(
            hintText: 'ค้นหาชื่อ, เบอร์โทร, LINE, วันเกิด, ธาตุ...',
            hintStyle: TextStyle(fontSize: 13, color: context.mutedTextColor),
            prefixIcon: Icon(Icons.search_rounded, color: context.goldColor, size: 20),
            suffixIcon: searchQuery.isNotEmpty
                ? IconButton(
                    icon: Icon(Icons.clear_rounded, size: 18, color: context.mutedTextColor),
                    onPressed: onClearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCarousel(BuildContext context) {
    return Container(
      height: 36,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filterOptions.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final tag = filterOptions[idx];
          final isSelected = selectedFilterTag == tag;

          String? countBadge;
          if (tag == 'ใกล้วันเกิด' && upcomingCount > 0) {
            countBadge = '$upcomingCount';
          } else if (tag == 'มีบันทึก' && notesCount > 0) {
            countBadge = '$notesCount';
          }

          final isDayTag = tag.startsWith('วัน');
          final dotColor = isDayTag ? _getWeekdayColor(idx - 2) : null;

          return AnimatedPressable(
            onTap: () => onFilterTagChanged(tag),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
              decoration: BoxDecoration(
                gradient: isSelected
                    ? const LinearGradient(
                        colors: [AppColors.caramelBronze, AppColors.amberGold],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isSelected ? null : context.cardColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? context.goldColor : context.borderColor,
                ),
                boxShadow: isSelected
                    ? const [
                        BoxShadow(
                          color: AppColors.goldGlow,
                          blurRadius: 6,
                          offset: Offset(0, 2),
                        ),
                      ]
                    : const [
                        BoxShadow(
                          color: Color(0x04000000),
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
              ),
              alignment: Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (dotColor != null) ...[
                    Container(
                      width: 7,
                      height: 7,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  Text(
                    tag,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected ? Colors.white : context.goldColor,
                    ),
                  ),
                  if (countBadge != null) ...[
                    const SizedBox(width: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 1),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.28)
                            : AppColors.caramelBronze.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        countBadge,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : context.goldColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
