import 'dart:math';

import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/cycle_provider.dart';
import 'package:alpha_app/providers/home_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class SavingsAllocationScreen extends StatefulWidget {
  final String cycleId;

  const SavingsAllocationScreen({
    super.key,
    required this.cycleId,
  });

  @override
  State<SavingsAllocationScreen> createState() =>
      _SavingsAllocationScreenState();
}

class _SavingsAllocationScreenState extends State<SavingsAllocationScreen> {
  bool _isLoading = true;
  bool _isSaving = false;

  double _efPercentage = 10.0;

  double _plannedSavings = 0;
  double _efTarget = 0;
  double _efBalance = 0;
  double _plannedGoalAllocations = 0;
  bool _isUpdate = false;

  double toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0.0;
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cycleProvider = Provider.of<CycleProvider>(
      context,
      listen: false,
    );

    final summary = await cycleProvider.getCyclePlanningSummary(
      widget.cycleId,
    );

    if (!mounted) {
      return;
    }

    if (summary != null) {
      setState(() {
        _plannedSavings = toDouble(summary['plannedSavings']);
        _efTarget = toDouble(summary['emergencyFundTarget']);
        _efBalance = toDouble(summary['emergencyFundBalance']);

        final goalAllocationsList = summary['goalAllocations'] as List?;
        _plannedGoalAllocations = 0;

        if (goalAllocationsList != null) {
          for (final goal in goalAllocationsList) {
            if (goal['goal_type'] != 'emergency_fund' &&
                goal['is_system_managed'] != true) {
              _plannedGoalAllocations += toDouble(goal['planned_amount']);
            }
          }
        }

        final existingSavings = summary['savingsAllocation'];

        if (existingSavings != null) {
          _efPercentage = toDouble(
            existingSavings['emergency_fund_rate'] ?? 10.0,
          );
          _isUpdate = true;
        } else {
          _isUpdate = false;
        }

        _isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'savings_allocation.load_failed'.tr(),
            ),
          ),
        );

      Navigator.pop(context);
    }
  }

  double get _calculatedEfAmount =>
      (_plannedSavings * (_efPercentage / 100)).roundToDouble();

  double get _remainingCapacity =>
      _efTarget > 0 ? max(0.0, _efTarget - _efBalance) : double.infinity;

  double get _effectiveEfAmount => _calculatedEfAmount;

  double get _unallocatedSavings =>
      _plannedSavings - _effectiveEfAmount - _plannedGoalAllocations;

  Future<void> _saveAndContinue() async {
    if (_isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final cycleProvider = Provider.of<CycleProvider>(
        context,
        listen: false,
      );

      final bool success;
      if (_isUpdate) {
        success = await cycleProvider.updateSavingsAllocation(
          widget.cycleId,
          _efPercentage,
        );
      } else {
        success = await cycleProvider.linkSavingsAllocation(
          widget.cycleId,
          _efPercentage,
        );
      }

      if (!mounted) return;

      if (success) {
        await cycleProvider.loadCurrentCycle();

        if (mounted && cycleProvider.hasActiveCycle) {
          await Provider.of<HomeProvider>(
            context,
            listen: false,
          ).loadHomeData();
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (cycleProvider.error != null) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                cycleProvider.error!,
              ),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final accentColor = isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor =
        isDark ? AppColors.darkSubText : AppColors.lightSubText;

    final borderColor = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Center(
            child: CircularProgressIndicator(
              color: primaryColor,
            ),
          ),
        ),
      );
    }

    final hasInvalidAllocation = _unallocatedSavings < 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenW * 0.055,
                screenH * 0.02,
                screenW * 0.055,
                screenH * 0.012,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: _isSaving
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: screenW * 0.12,
                      height: screenW * 0.12,
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: primaryColor,
                        size: screenW * 0.07,
                      ),
                    ),
                  ),
                  SizedBox(width: screenW * 0.03),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'savings_allocation.title'.tr(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: screenW * 0.062,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'savings_allocation.description'.tr(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: screenW * 0.033,
                            color: subTextColor,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  screenW * 0.055,
                  screenH * 0.015,
                  screenW * 0.055,
                  screenH * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(
                                    0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    14,
                                  ),
                                ),
                                child: Icon(
                                  Icons.shield_outlined,
                                  color: primaryColor,
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'savings_allocation.emergency_fund_rate'
                                          .tr(),
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        fontSize: 17,
                                        fontWeight: FontWeight.bold,
                                        color: textColor,
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 4,
                                    ),
                                    Text(
                                      'savings_allocation.emergency_fund_description'
                                          .tr(),
                                      style: GoogleFonts.ibmPlexSansArabic(
                                        fontSize: 12.5,
                                        color: subTextColor,
                                        height: 1.45,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: screenH * 0.025,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'savings_allocation.selected_rate'.tr(),
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 14,
                                  color: subTextColor,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: primaryColor.withOpacity(
                                    0.12,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    12,
                                  ),
                                ),
                                child: Text(
                                  '${_efPercentage.toInt()}%',
                                  style: GoogleFonts.ibmPlexSansArabic(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SliderTheme(
                            data: SliderTheme.of(
                              context,
                            ).copyWith(
                              activeTrackColor: primaryColor,
                              inactiveTrackColor: borderColor,
                              thumbColor: primaryColor,
                              overlayColor: primaryColor.withOpacity(
                                0.12,
                              ),
                              trackHeight: 5,
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 8,
                              ),
                              overlayShape: const RoundSliderOverlayShape(
                                overlayRadius: 16,
                              ),
                            ),
                            child: Slider(
                              value: _efPercentage,
                              min: 0,
                              max: 100,
                              divisions: 100,
                              label: '${_efPercentage.toInt()}%',
                              onChanged: _isSaving
                                  ? null
                                  : (value) {
                                      setState(() {
                                        _efPercentage = value;
                                      });
                                    },
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: screenH * 0.022,
                    ),
                    Text(
                      'savings_allocation.allocation_summary'.tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    SizedBox(
                      height: screenH * 0.012,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'savings_allocation.planned_savings'.tr(),
                            amount: _plannedSavings,
                            isDark: isDark,
                          ),
                          Divider(
                            color: borderColor,
                            height: 25,
                          ),
                          _SummaryRow(
                            label: 'savings_allocation.emergency_fund'.tr(),
                            amount: _effectiveEfAmount,
                            isDark: isDark,
                            highlightColor: primaryColor,
                          ),
                          const SizedBox(height: 14),
                          _SummaryRow(
                            label: 'savings_allocation.other_goals'.tr(),
                            amount: _plannedGoalAllocations,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 14),
                          _SummaryRow(
                            label: 'savings_allocation.unallocated'.tr(),
                            amount: _unallocatedSavings,
                            isDark: isDark,
                            highlightColor: hasInvalidAllocation
                                ? (isDark
                                    ? AppColors.darkError
                                    : AppColors.lightError)
                                : accentColor,
                          ),
                        ],
                      ),
                    ),
                    if (_efTarget > 0 && _efBalance >= _efTarget) ...[
                      SizedBox(
                        height: screenH * 0.018,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: accentColor.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: accentColor,
                              size: 21,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'savings_allocation.fund_limit'.tr(),
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 12.5,
                                  color: subTextColor,
                                  height: 1.45,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (hasInvalidAllocation) ...[
                      SizedBox(
                        height: screenH * 0.018,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: (isDark
                                  ? AppColors.darkError
                                  : AppColors.lightError)
                              .withOpacity(0.10),
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                        ),
                        child: Text(
                          'savings_allocation.invalid_allocation'.tr(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: isDark
                                ? AppColors.darkError
                                : AppColors.lightError,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    if (_plannedSavings <= 0) ...[
                      SizedBox(
                        height: screenH * 0.018,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(
                            14,
                          ),
                          border: Border.all(
                            color: accentColor.withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.warning_amber_rounded,
                              color: accentColor,
                              size: 21,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                'savings_allocation.zero_savings_hint'.tr(),
                                style: GoogleFonts.ibmPlexSansArabic(
                                  fontSize: 12.5,
                                  color: textColor,
                                  height: 1.45,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    SizedBox(
                      height: screenH * 0.025,
                    ),
                    AppButton(
                      text: 'savings_allocation.confirm'.tr(),
                      isDark: isDark,
                      isLoading: _isSaving,
                      width: double.infinity,
                      height: 54,
                      borderRadius: 14,
                      onPressed: hasInvalidAllocation ? null : _saveAndContinue,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDark;
  final Color? highlightColor;

  const _SummaryRow({
    required this.label,
    required this.amount,
    required this.isDark,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    final displayAmount = amount;

    final textColor = isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor =
        isDark ? AppColors.darkSubText : AppColors.lightSubText;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 13.5,
              color: subTextColor,
            ),
          ),
        ),
        const SizedBox(width: 14),
        Flexible(
          child: Text(
            "${displayAmount.toStringAsFixed(2)} ${'common.jod'.tr()}",
            textAlign: TextAlign.end,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 15,
              fontWeight:
                  highlightColor != null ? FontWeight.bold : FontWeight.w600,
              color: highlightColor ?? textColor,
            ),
          ),
        ),
      ],
    );
  }
}
