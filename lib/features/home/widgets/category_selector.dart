import 'package:flutter/material.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../shared/widgets/status_chip.dart';

/// Horizontal scrollable category / filter chip bar.
class CategorySelector extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategorySelector({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = cat == selectedCategory;
          return StatusChip(
            label: cat,
            isSelected: isSelected,
            onTap: () => onSelected(cat),
          );
        },
      ),
    );
  }
}
