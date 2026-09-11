import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OptionChip extends StatelessWidget {
  final List<String> items;
  final String? selected;
  final Function(String) onTap;

  const OptionChip({
    super.key,
    required this.items,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<Themeprovider>();
    final isDark = themeProvider.isDark;

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final cardColor =
        isDark ? AppColors.darkCard : AppColors.lightCard;

    return SizedBox(
      height: 50,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          final item = items[index];
          final isSelected = item == selected;

          return InkWell(
            onTap: () => onTap(item),
            borderRadius: BorderRadius.circular(14),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? primaryColor.withOpacity(0.12)
                    : cardColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  width: isSelected ? 1.6 : 1,
                  color: isSelected
                      ? primaryColor
                      : borderColor,
                ),
              ),
              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    color: isSelected
                        ? primaryColor
                        : textColor,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}