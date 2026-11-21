import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Item representing a selectable calendar date.
class DateItem {
  final DateTime date;
  final String label; // "Today", "Tomorrow", "Fri", etc.
  final String dayNumber; // "20", "21"
  final String month; // "NOV"

  const DateItem({
    required this.date,
    required this.label,
    required this.dayNumber,
    required this.month,
  });

  String get fullDateLabel => '$label, $dayNumber $month';
}

/// Horizontally scrollable date selector highlighting Today, Tomorrow, and upcoming dates.
class DateSelectorStrip extends StatelessWidget {
  final List<DateItem> dates;
  final int selectedIndex;
  final ValueChanged<int> onDateSelected;

  const DateSelectorStrip({
    super.key,
    required this.dates,
    required this.selectedIndex,
    required this.onDateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final item = dates[index];
          final isSelected = index == selectedIndex;

          return GestureDetector(
            onTap: () => onDateSelected(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 66,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface, // #4ADE80 or #16161A
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? AppColors.primary : AppColors.surfaceBorder, // #26262C
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label.toUpperCase(),
                    style: TextStyle(
                      color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
                      fontSize: 9.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.dayNumber,
                    style: TextStyle(
                      color: isSelected ? AppColors.textInverse : Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    item.month,
                    style: TextStyle(
                      color: isSelected ? AppColors.textInverse.withValues(alpha: 0.85) : AppColors.textSecondary,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
