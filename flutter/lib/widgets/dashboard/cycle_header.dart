import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/models/home_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CycleHeader extends StatelessWidget {
  final HomeCycle? cycle;
  final bool isDark;

  const CycleHeader({
    super.key,
    required this.cycle,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (cycle == null) {
      return const SizedBox.shrink();
    }

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor =
        isDark ? AppColors.darkSubText : AppColors.lightSubText;

    final daysRemainingText = cycle!.daysRemaining == null
        ? 'cycle.unavailable'.tr()
        : cycle!.daysRemaining == 0
            ? 'cycle.ends_today'.tr()
            : 'cycle.days_left'.tr(
                namedArgs: {
                  'days': cycle!.daysRemaining.toString(),
                },
              );

    final startDateStr = cycle!.startDate != null
        ? "${cycle!.startDate!.day}/${cycle!.startDate!.month}"
        : "";

    final endDateStr = cycle!.endDate != null
        ? "${cycle!.endDate!.day}/${cycle!.endDate!.month}"
        : "";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: primaryColor.withOpacity(
          isDark ? 0.07 : 0.045,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: primaryColor.withOpacity(0.50),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.calendar_month_outlined,
              color: primaryColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'cycle.current_cycle'.tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.date_range_outlined,
                      color: subTextColor,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Flexible(
                      child: Text(
                        "$startDateStr - $endDateStr",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: subTextColor,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 11,
              vertical: 7,
            ),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.11),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              daysRemainingText,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                color: primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}