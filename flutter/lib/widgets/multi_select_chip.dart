import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MultiSelectChip extends StatelessWidget {
  final List<String> items;
  final List<String> selectedItems;
  final Function(String) onTap;

  const MultiSelectChip({
    super.key,
    required this.items,
    required this.selectedItems,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final themeprovider = Provider.of<Themeprovider>(context);

    final isDark = themeprovider.isDark;

    return SizedBox(
      height: 52,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,

        separatorBuilder: (_, __) =>
            const SizedBox(width: 14),

        itemBuilder: (context, index) {
          final item = items[index];

          final selected =
              selectedItems.contains(item);

          return InkWell(
            borderRadius:
                BorderRadius.circular(14),

            onTap: () {
              onTap(item);
            },

            child: AnimatedContainer(
              duration:
                  const Duration(milliseconds: 180),

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: selected
                    ? (isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary)
                        .withOpacity(0.12)
                    : (isDark
                        ? AppColors.darkCard
                        : AppColors.lightCard),

                borderRadius:
                    BorderRadius.circular(14),

                border: Border.all(
                  width: selected ? 1.6 : 1,
                  color: selected
                      ? (isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary)
                      : (isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
              ),

              child: Center(
                child: Text(
                  item,
                  style: TextStyle(
                    color: selected
                        ? (isDark
                            ? AppColors.darkPrimary
                            : AppColors.lightPrimary)
                        : (isDark
                            ? AppColors.darkText
                            : AppColors.lightText),

                    fontWeight:
                        FontWeight.w600,
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