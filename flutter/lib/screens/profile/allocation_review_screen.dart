import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/dashboard_action_result.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/core/utils/step_resolver.dart';
import 'package:alpha_app/providers/financial_profile_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

enum AllocationReviewMode {
  onboarding,
  financialProfileUpdate,
}

class AllocationReviewScreen extends StatefulWidget {
  final AllocationReviewMode mode;
  final Map<String, dynamic>? requestPayload;

  const AllocationReviewScreen({
    super.key,
    this.mode = AllocationReviewMode.onboarding,
    this.requestPayload,
  });

  @override
  State<AllocationReviewScreen> createState() =>
      _AllocationReviewScreenState();
}

class _AllocationReviewScreenState
    extends State<AllocationReviewScreen> {
  late int _needsBps;
  late int _wantsBps;
  late int _savingsBps;

  late int _originalNeedsBps;
  late int _originalWantsBps;
  late int _originalSavingsBps;

  bool _isInitialized = false;
  bool _isNavigating = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_isInitialized) {
      _initValues();
      _isInitialized = true;
    }
  }

  void _initValues() {
    Map<String, dynamic> alloc = {};

    if (widget.mode == AllocationReviewMode.onboarding) {
      final provider =
          Provider.of<OnboardingProvider>(
        context,
        listen: false,
      );

      alloc = provider.allocation ?? {};
    } else {
      final provider =
          Provider.of<FinancialProfileProvider>(
        context,
        listen: false,
      );

      alloc =
          provider.previewData?['allocation'] ?? {};
    }

    _needsBps = (alloc['needsBps'] ?? 5000).clamp(0, 10000);
    _wantsBps = (alloc['wantsBps'] ?? 3000).clamp(
      0,
      10000 - _needsBps,
    );

    _updateSavingsAutomatically();

    _originalNeedsBps = _needsBps;
    _originalWantsBps = _wantsBps;
    _originalSavingsBps = _savingsBps;
  }

  void _reset() {
    setState(() {
      _needsBps = _originalNeedsBps;
      _wantsBps = _originalWantsBps;
      _updateSavingsAutomatically();
    });
  }

  int get _totalBps =>
      _needsBps + _wantsBps + _savingsBps;

  void _updateSavingsAutomatically() {
    _savingsBps =
        (10000 - _needsBps - _wantsBps).clamp(0, 10000);
  }

  void _updateNeeds(double value) {
    final maxNeeds = 10000 - _wantsBps;

    setState(() {
      _needsBps = value.toInt().clamp(0, maxNeeds);
      _updateSavingsAutomatically();
    });
  }

  void _updateWants(double value) {
    final maxWants = 10000 - _needsBps;

    setState(() {
      _wantsBps = value.toInt().clamp(0, maxWants);
      _updateSavingsAutomatically();
    });
  }

  Future<void> _submit() async {
    if (_totalBps != 10000) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'allocation_total_must_equal_100'.tr(),
            ),
          ),
        );

      return;
    }

    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      if (widget.mode ==
          AllocationReviewMode.onboarding) {
        final provider =
            Provider.of<OnboardingProvider>(
          context,
          listen: false,
        );

        final data = {
          'needsBps': _needsBps,
          'wantsBps': _wantsBps,
          'savingsBps': _savingsBps,
        };

        final success =
            await provider.approveAllocation(data);

        if (!mounted) {
          return;
        }

        if (success) {
          replaceWithOnboardingStep(
            context,
            provider.nextStep,
          );
        } else if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage!,
                ),
              ),
            );
        }
      } else {
        final provider =
            Provider.of<FinancialProfileProvider>(
          context,
          listen: false,
        );

        final data = Map<String, dynamic>.from(
          widget.requestPayload ?? {},
        );

        data['needsBps'] = _needsBps;
        data['wantsBps'] = _wantsBps;
        data['savingsBps'] = _savingsBps;

        final success =
            await provider.approveAllocation(data);

        if (!mounted) {
          return;
        }

        if (success) {
          await Provider.of<OnboardingProvider>(
            context,
            listen: false,
          ).checkOnboardingStatus();

          if (mounted) {
            Navigator.pop(
              context,
              DashboardActionResult.updated,
            );
          }
        } else if (provider.errorMessage != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  provider.errorMessage!,
                ),
              ),
            );
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> alloc = {};
    double income = 0;
    String tier = 'not_available'.tr();
    String source = 'not_available'.tr();
    bool isCustomized = false;
    bool isLoading = false;

    if (widget.mode ==
        AllocationReviewMode.onboarding) {
      final provider =
          Provider.of<OnboardingProvider>(context);

      alloc = provider.allocation ?? {};
      income = (alloc['income'] ?? 0).toDouble();
      tier = alloc['tier'] ?? 'not_available'.tr();
      source = alloc['source'] ?? 'not_available'.tr();
      isCustomized =
          alloc['isCustomized'] ?? false;
      isLoading = provider.isLoading;
    } else {
      final provider =
          Provider.of<FinancialProfileProvider>(
        context,
      );

      final previewData =
          provider.previewData ?? {};

      alloc = previewData['allocation'] ?? {};
      income =
          (previewData['income'] ?? 0).toDouble();
      tier = previewData['tier'] ?? 'not_available'.tr();
      source = alloc['source'] ?? 'not_available'.tr();
      isCustomized =
          alloc['isCustomized'] ?? false;
      isLoading = provider.isLoading;
    }

    final double needsAmount =
        income * (_needsBps / 10000);

    final double wantsAmount =
        income * (_wantsBps / 10000);

    final double savingsAmount =
        income * (_savingsBps / 10000);

    final themeProvider =
        context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    final errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    final totalIsValid = _totalBps == 10000;
    final buttonLoading =
        isLoading || _isNavigating;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                screenW * 0.055,
                screenH * 0.02,
                screenW * 0.055,
                screenH * 0.01,
              ),
              child: Row(
                children: [
                  if (widget.mode ==
                      AllocationReviewMode
                          .financialProfileUpdate)
                    InkWell(
                      onTap: buttonLoading
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                false,
                              );
                            },
                      borderRadius:
                          BorderRadius.circular(13),
                      child: Container(
                        width: screenW * 0.12,
                        height: screenW * 0.12,
                        decoration: BoxDecoration(
                          color: primaryColor
                              .withOpacity(0.10),
                          borderRadius:
                              BorderRadius.circular(
                            13,
                          ),
                        ),
                        child: Icon(
                          Icons.arrow_back_rounded,
                          color: primaryColor,
                          size: screenW * 0.07,
                        ),
                      ),
                    ),
                  if (widget.mode ==
                      AllocationReviewMode
                          .financialProfileUpdate)
                    SizedBox(
                      width: screenW * 0.03,
                    ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'allocation_review'.tr(),
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            fontSize: screenW * 0.065,
                            fontWeight:
                                FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'allocation_review_subtitle'.tr(),
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            fontSize: screenW * 0.035,
                            color: subTextColor,
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
                physics:
                    const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  screenW * 0.055,
                  screenH * 0.02,
                  screenW * 0.055,
                  screenH * 0.03,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(18),
                        border: Border.all(
                          color: borderColor,
                        ),
                      ),
                      child: Column(
                        children: [
                          _InfoRow(
                            label: 'income'.tr(),
                            value:
                                "${income.toStringAsFixed(2)} ${'jod'.tr()}",
                            isDark: isDark,
                            isHighlight: true,
                          ),
                          Divider(
                            color: borderColor,
                            height: 24,
                          ),
                          _InfoRow(
                            label: 'tier'.tr(),
                            value: tier,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            label: 'source'.tr(),
                            value: source,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 10),
                          _InfoRow(
                            label: 'customized'.tr(),
                            value: isCustomized
                                ? 'yes'.tr()
                                : 'no'.tr(),
                            isDark: isDark,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.022,
                    ),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: primaryColor.withOpacity(0.25),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.tune_rounded,
                            color: primaryColor,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'allocation_adjust_hint'.tr(),
                              style: GoogleFonts.ibmPlexSansArabic(
                                fontSize: 13,
                                height: 1.5,
                                color: subTextColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.02,
                    ),

                    _AllocationSliderCard(
                      label: 'needs'.tr(),
                      description:
                          'needs_description'.tr(),
                      bpsValue: _needsBps,
                      amount: needsAmount,
                      color: primaryColor,
                      isDark: isDark,
                      onChanged: buttonLoading
                          ? null
                          : _updateNeeds,
                    ),

                    SizedBox(
                      height: screenH * 0.018,
                    ),

                    _AllocationSliderCard(
                      label: 'wants'.tr(),
                      description:
                          'wants_description'.tr(),
                      bpsValue: _wantsBps,
                      amount: wantsAmount,
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightAccent,
                      isDark: isDark,
                      onChanged: buttonLoading
                          ? null
                          : _updateWants,
                    ),

                    SizedBox(
                      height: screenH * 0.018,
                    ),

                    _AllocationSliderCard(
                      label: 'savings'.tr(),
                      description:
                          'savings_description'.tr(),
                      bpsValue: _savingsBps,
                      amount: savingsAmount,
                      color: isDark
                          ? AppColors.darkSecondary
                          : AppColors.lightSecondary,
                      isDark: isDark,
                      onChanged: null,
                      isAutomatic: true,
                    ),

                    SizedBox(
                      height: screenH * 0.022,
                    ),

                    Container(
                      padding:
                          const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: totalIsValid
                            ? primaryColor
                                .withOpacity(0.10)
                            : errorColor
                                .withOpacity(0.10),
                        borderRadius:
                            BorderRadius.circular(16),
                        border: Border.all(
                          color: totalIsValid
                              ? primaryColor
                              : errorColor,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            totalIsValid
                                ? Icons
                                    .check_circle_outline_rounded
                                : Icons
                                    .error_outline_rounded,
                            color: totalIsValid
                                ? primaryColor
                                : errorColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'total_allocation'.tr(),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(
                                fontSize: 15,
                                fontWeight:
                                    FontWeight.w600,
                                color: textColor,
                              ),
                            ),
                          ),
                          Text(
                            '${(_totalBps / 100).toStringAsFixed(1)}%',
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                              color: totalIsValid
                                  ? primaryColor
                                  : errorColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(
                      height: screenH * 0.03,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed:
                                buttonLoading
                                    ? null
                                    : _reset,
                            style: OutlinedButton
                                .styleFrom(
                              minimumSize:
                                  const Size(
                                0,
                                54,
                              ),
                              side: BorderSide(
                                color:
                                    primaryColor,
                              ),
                              foregroundColor:
                                  primaryColor,
                              shape:
                                  RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  12,
                                ),
                              ),
                            ),
                            child: Text(
                              'reset'.tr(),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(
                          width: screenW * 0.03,
                        ),

                        Expanded(
                          flex: 2,
                          child: AppButton(
                            text: 'approve'.tr(),
                            isDark: isDark,
                            isLoading: buttonLoading,
                            width: double.infinity,
                            height: 54,
                            borderRadius: 12,
                            onPressed:
                                buttonLoading
                                    ? null
                                    : _submit,
                          ),
                        ),
                      ],
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

class _AllocationSliderCard
    extends StatelessWidget {
  final String label;
  final String description;
  final int bpsValue;
  final double amount;
  final Color color;
  final bool isDark;
  final ValueChanged<double>? onChanged;
  final bool isAutomatic;

  const _AllocationSliderCard({
    required this.label,
    required this.description,
    required this.bpsValue,
    required this.amount,
    required this.color,
    required this.isDark,
    required this.onChanged,
    this.isAutomatic = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    return Container(
      padding: const EdgeInsets.fromLTRB(
        16,
        16,
        16,
        10,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 11,
                height: 11,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
              ),
              if (isAutomatic)
                Container(
                  margin: const EdgeInsetsDirectional.only(
                    end: 8,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'automatic'.tr(),
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              Text(
                '${(bpsValue / 100).toStringAsFixed(1)}%',
                style:
                    GoogleFonts.ibmPlexSansArabic(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(
            description,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 12,
              color: subTextColor,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            "${amount.toStringAsFixed(2)} ${'jod'.tr()}",
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),

          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              inactiveTrackColor:
                  borderColor.withOpacity(0.8),
              disabledActiveTrackColor: color,
              disabledInactiveTrackColor:
                  borderColor.withOpacity(0.8),
              thumbColor: color,
              disabledThumbColor: color,
              overlayColor:
                  color.withOpacity(0.12),
              trackHeight: 5,
              thumbShape:
                  const RoundSliderThumbShape(
                enabledThumbRadius: 8,
              ),
              overlayShape:
                  const RoundSliderOverlayShape(
                overlayRadius: 16,
              ),
            ),
            child: Slider(
              value: bpsValue.toDouble(),
              min: 0,
              max: 10000,
              divisions: 100,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final bool isHighlight;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.isDark,
    this.isHighlight = false,
  });

  @override
  Widget build(BuildContext context) {
    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Row(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              color: subTextColor,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: isHighlight ? 17 : 14,
              fontWeight: isHighlight
                  ? FontWeight.bold
                  : FontWeight.w600,
              color: isHighlight
                  ? primaryColor
                  : textColor,
            ),
          ),
        ),
      ],
    );
  }
}
