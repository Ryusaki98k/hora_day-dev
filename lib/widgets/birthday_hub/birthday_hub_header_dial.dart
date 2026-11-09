import 'package:flutter/material.dart';
import '../../utils/animation_helper.dart';
import '../../utils/app_colors.dart';

class BirthdayHubHeaderDial extends StatelessWidget {
  final String monthTitle;
  final bool isCurrentMonth;
  final int todayCount;
  final int upcomingCount;
  final int monthCount;
  final String activeScope;
  final VoidCallback onPrevMonth;
  final VoidCallback onNextMonth;
  final VoidCallback onGoToCurrentMonth;
  final ValueChanged<String> onScopeChanged;

  const BirthdayHubHeaderDial({
    super.key,
    required this.monthTitle,
    required this.isCurrentMonth,
    required this.todayCount,
    required this.upcomingCount,
    required this.monthCount,
    required this.activeScope,
    required this.onPrevMonth,
    required this.onNextMonth,
    required this.onGoToCurrentMonth,
    required this.onScopeChanged,
  });

  Widget _buildScopePill(
    BuildContext context, {
    required String scopeKey,
    required String label,
    required String count,
    required Color color,
    bool highlightGlow = false,
  }) {
    final isSelected = activeScope == scopeKey;
    return AnimatedPressable(
      scaleDown: 0.94,
      onTap: () => onScopeChanged(scopeKey),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.champagne.withValues(alpha: 0.6)
              : (Theme.of(context).brightness == Brightness.dark ? const Color(0xFF131A29) : const Color(0xFFFBF9F5)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? context.goldColor : context.borderColor,
            width: isSelected ? 1.4 : 1.0,
          ),
          boxShadow: highlightGlow
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.18),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? context.textColor : context.subTextColor,
                ),
              ),
            ),
            const SizedBox(width: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                count,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
        boxShadow: const [
          BoxShadow(
            color: Color(0x06000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Month navigator row with astronomical styling
          LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 360;

              final navSection = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left_rounded, size: 22, color: context.goldColor),
                    onPressed: onPrevMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    tooltip: 'เดือนก่อนหน้า',
                  ),
                  Flexible(
                    child: Text(
                      monthTitle,
                      style: TextStyle(
                        fontSize: isCompact ? 14.5 : 15.5,
                        fontWeight: FontWeight.bold,
                        color: context.textColor,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right_rounded, size: 22, color: context.goldColor),
                    onPressed: onNextMonth,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                    tooltip: 'เดือนถัดไป',
                  ),
                ],
              );

              final rightWidget = !isCurrentMonth
                  ? InkWell(
                      onTap: onGoToCurrentMonth,
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                        decoration: BoxDecoration(
                          color: AppColors.champagne.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.amberGold.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.today_rounded, size: 13, color: context.goldColor),
                            const SizedBox(width: 4),
                            Text(
                              'เดือนปัจจุบัน',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.bold,
                                color: context.goldColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF282015)
                            : AppColors.warmSand,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'เดือนนี้ $monthCount ท่าน',
                        style: TextStyle(fontSize: 10.5, color: context.subTextColor, fontWeight: FontWeight.bold),
                      ),
                    );

              if (isCompact) {
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: navSection),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Align(alignment: Alignment.centerRight, child: rightWidget),
                  ],
                );
              }

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: navSection),
                  const SizedBox(width: 6),
                  rightWidget,
                ],
              );
            },
          ),

          const SizedBox(height: 10),

          // 3-Horizon Scope Filter Pills (ทั้งหมด, สัปดาห์นี้, วันนี้)
          Row(
            children: [
              Expanded(
                child: _buildScopePill(
                  context,
                  scopeKey: 'ทั้งหมด',
                  label: 'ตลอดเดือน',
                  count: '$monthCount',
                  color: AppColors.caramelBronze,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScopePill(
                  context,
                  scopeKey: 'สัปดาห์นี้',
                  label: '๗ วันนี้',
                  count: '$upcomingCount',
                  color: const Color(0xFFD97706),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildScopePill(
                  context,
                  scopeKey: 'วันนี้',
                  label: 'วันนี้',
                  count: '$todayCount',
                  color: todayCount > 0 ? const Color(0xFFDC2626) : AppColors.mutedText,
                  highlightGlow: todayCount > 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
