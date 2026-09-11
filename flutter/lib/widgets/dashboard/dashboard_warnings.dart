import 'package:flutter/material.dart';
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardWarningsWidget extends StatelessWidget {
  final List<String> warnings;
  final bool isDark;

  const DashboardWarningsWidget({
    super.key,
    required this.warnings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final filteredWarnings =
        warnings.where((w) => w != 'NO_ACTIVE_FINANCIAL_CYCLE').toList();

    if (filteredWarnings.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.orange.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: Colors.orange,
              ),
              const SizedBox(width: 8),
              Text(
                'dashboard_warnings.title'.tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...filteredWarnings.map(
            (warning) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "• ",
                    style: TextStyle(
                      color: Colors.orange,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      _getWarningMessage(warning),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getWarningMessage(String code) {
    switch (code) {
      case 'OVERDUE_COMMITMENTS':
        return 'dashboard_warnings.overdue_commitments'.tr();

      case 'NO_INCOME_RECORDED':
        return 'dashboard_warnings.no_income'.tr();

      case 'UNEXPECTED_EXPENSE_IMPACT':
        return 'dashboard_warnings.unexpected_expense'.tr();

      default:
        return 'dashboard_warnings.notice'.tr(
          namedArgs: {
            'code': code,
          },
        );
    }
  }
}