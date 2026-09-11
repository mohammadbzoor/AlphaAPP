import 'package:flutter/material.dart';
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/models/home_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class GoalsSummaryWidget extends StatelessWidget {
  final HomeGoalsSummary? goals;
  final bool isDark;
  final VoidCallback onViewGoals;

  const GoalsSummaryWidget({
    super.key,
    required this.goals,
    required this.isDark,
    required this.onViewGoals,
  });

  @override
  Widget build(BuildContext context) {
    if (goals == null) {
      return const SizedBox.shrink();
    }

    final shouldShow =
        goals!.activeCount > 0 || goals!.readyCount > 0;

    if (!shouldShow) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flag_outlined,
                color: isDark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
              ),
              const SizedBox(width: 8),
              Text(
                'goals_summary.title'.tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.lightText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: onViewGoals,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize:
                      MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'common.view'.tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: isDark
                        ? AppColors.darkPrimary
                        : AppColors.lightPrimary,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
            children: [
              _buildItem(
                'goals_summary.active_goals'.tr(),
                "${goals!.activeCount}",
              ),
              _buildItem(
                'goals_summary.ready_to_complete'.tr(),
                "${goals!.readyCount}",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItem(
    String label,
    String value,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.ibmPlexSansArabic(
            color: isDark
                ? AppColors.darkSubText
                : AppColors.lightSubText,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.ibmPlexSansArabic(
            color: isDark
                ? AppColors.darkText
                : AppColors.lightText,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}