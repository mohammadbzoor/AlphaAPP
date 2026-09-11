import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/models/home_model.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/percent_indicator.dart';

class BucketCardsSection extends StatelessWidget {
  final HomeBuckets? buckets;
  final bool isDark;

  const BucketCardsSection({
    super.key,
    required this.buckets,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    if (buckets == null) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildBucketCard(
          title: "dashboard_buckets.needs".tr(),
          bucket: buckets!.needs,
          icon: Icons.shopping_bag_outlined,
          accentColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
          context: context,
        ),
        const SizedBox(height: 14),
        _buildBucketCard(
          title: "dashboard_buckets.wants".tr(),
          bucket: buckets!.wants,
          icon: Icons.favorite_border_rounded,
          accentColor: isDark ? AppColors.darkAccent : AppColors.lightAccent,
          context: context,
        ),
        const SizedBox(height: 14),
        _buildBucketCard(
          title: "dashboard_buckets.savings".tr(),
          bucket: buckets!.savings,
          icon: Icons.savings_outlined,
          accentColor:
              isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
          context: context,
          isSavings: true,
        ),
      ],
    );
  }

  Widget _buildBucketCard({
    required String title,
    required HomeBucket? bucket,
    required IconData icon,
    required Color accentColor,
    required BuildContext context,
    bool isSavings = false,
  }) {
    if (bucket == null) {
      return const SizedBox.shrink();
    }

    final statusColor = _getStatusColor(bucket.status, isDark);

    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor =
        isDark ? AppColors.darkSubText : AppColors.lightSubText;

    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    final targetText = bucket.target != null
        ? "${bucket.target!.toStringAsFixed(2)} JOD"
        : "Unavailable";

    final actualText = bucket.actual != null
        ? "${bucket.actual!.toStringAsFixed(2)} JOD"
        : "Unavailable";

    double progress = 0.0;
    double totalAllocated = 0.0;
    double unallocatedSavings = 0.0;

    if (isSavings) {
      final plannedEf = bucket.plannedEmergencyFund ??
          (bucket.target != null ? bucket.target! * 0.10 : 0.0);
      final plannedGoals = bucket.plannedGoalAllocations ?? 0.0;
      totalAllocated = plannedEf + plannedGoals;
      if (bucket.target != null && bucket.target! > 0) {
        progress = (totalAllocated / bucket.target!).clamp(0.0, 1.0);
      }
      unallocatedSavings = (bucket.unallocatedSavings ??
              (bucket.target != null ? bucket.target! - totalAllocated : 0.0))
          .clamp(0.0, double.infinity);
    } else {
      if (bucket.usagePercent != null) {
        progress = bucket.usagePercent! / 100.0;
      } else if (bucket.actual != null &&
          bucket.target != null &&
          bucket.target! > 0) {
        progress = bucket.actual! / bucket.target!;
      }
      progress = progress.clamp(0.0, 1.0);
    }

    final remainingText = isSavings
        ? "${unallocatedSavings.toStringAsFixed(2)} JOD"
        : (bucket.remaining != null
            ? "${bucket.remaining!.toStringAsFixed(2)} JOD"
            : "Unavailable");

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [
                  cardColor,
                  accentColor.withOpacity(0.08),
                ]
              : [
                  cardColor,
                  accentColor.withOpacity(0.055),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: accentColor.withOpacity(0.30),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.035),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.13),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withOpacity(0.22),
                  ),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ),
              if (bucket.status != null && bucket.status != 'unavailable')
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.11),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: statusColor.withOpacity(0.28),
                    ),
                  ),
                  child: Text(
                    bucket.status!.toUpperCase(),
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: statusColor,
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _buildAmountCard(
                  label: isSavings
                      ? "dashboard_buckets.allocated".tr()
                      : "dashboard_buckets.actual".tr(),
                  value: isSavings
                      ? "${totalAllocated.toStringAsFixed(2)} JOD"
                      : actualText,
                  icon: isSavings
                      ? Icons.pie_chart_outline_rounded
                      : Icons.payments_outlined,
                  color: accentColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildAmountCard(
                  label: "dashboard_buckets.target".tr(),
                  value: targetText,
                  icon: Icons.flag_outlined,
                  color: statusColor,
                  textColor: textColor,
                  subTextColor: subTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                isSavings
                    ? "dashboard_buckets.allocated".tr()
                    : "dashboard_buckets.usage".tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  color: subTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: GoogleFonts.ibmPlexSansArabic(
                  color: isSavings ? accentColor : statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: progress,
            backgroundColor: borderColor,
            progressColor: isSavings ? accentColor : statusColor,
            barRadius: const Radius.circular(10),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 800,
          ),
          const SizedBox(height: 16),
          if (!isSavings && bucket.reserved != null && bucket.reserved! > 0)
            _buildSmallDetail(
              label: "dashboard_buckets.reserved_commitments".tr(),
              value: "${bucket.reserved!.toStringAsFixed(2)} JOD",
              icon: Icons.lock_outline_rounded,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
            ),
          if (!isSavings && bucket.availableVariable != null)
            _buildSmallDetail(
              label: "dashboard_buckets.available_variable".tr(),
              value: "${bucket.availableVariable!.toStringAsFixed(2)} JOD",
              icon: Icons.account_balance_wallet_outlined,
              color: accentColor,
            ),
          if (isSavings &&
              bucket.target != null &&
              bucket.target! > 0) ...[
            _buildSmallDetail(
              label: "dashboard_buckets.emergency_fund".tr(),
              value: "${(bucket.plannedEmergencyFund ?? (bucket.target! * 0.10)).toStringAsFixed(2)} JOD",
              icon: Icons.shield_outlined,
              color:
                  isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            if ((bucket.plannedGoalAllocations ?? 0) > 0)
              _buildSmallDetail(
                label: "dashboard_buckets.goal_allocations".tr(),
                value: "${bucket.plannedGoalAllocations!.toStringAsFixed(2)} JOD",
                icon: Icons.track_changes_outlined,
                color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              ),
            _buildSmallDetail(
              label: "dashboard_buckets.unallocated_savings".tr(),
              value: "${unallocatedSavings.toStringAsFixed(2)} JOD",
              icon: Icons.savings_outlined,
              color: accentColor,
            ),
          ],
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: 13,
              vertical: 11,
            ),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: accentColor.withOpacity(0.18),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isSavings
                      ? Icons.savings_outlined
                      : Icons.account_balance_wallet_outlined,
                  color: accentColor,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    isSavings
                        ? "dashboard_buckets.unallocated_savings".tr()
                        : "dashboard_buckets.remaining".tr(),
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: subTextColor,
                      fontSize: 12,
                    ),
                  ),
                ),
                Text(
                  remainingText,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: accentColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color textColor,
    required Color subTextColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 17,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: subTextColor,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.ibmPlexSansArabic(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSmallDetail({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final subTextColor =
        isDark ? AppColors.darkSubText : AppColors.lightSubText;

    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Row(
        children: [
          Container(
            width: 29,
            height: 29,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.ibmPlexSansArabic(
                color: subTextColor,
                fontSize: 11.5,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.ibmPlexSansArabic(
              color: textColor,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(
    String? status,
    bool isDark,
  ) {
    switch (status) {
      case 'healthy':
        return isDark ? AppColors.darkPrimary : AppColors.lightPrimary;
      case 'moderate':
      case 'warning':
        return isDark ? AppColors.darkAccent : AppColors.lightAccent;
      case 'critical':
      case 'exceeded':
        return isDark ? AppColors.darkError : AppColors.lightError;
      case 'unavailable':
      default:
        return isDark ? AppColors.darkSubText : AppColors.lightSubText;
    }
  }
}
