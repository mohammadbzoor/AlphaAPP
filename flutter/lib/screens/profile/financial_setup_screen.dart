import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/financial_setup_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/custom_textfield.dart';
import 'package:alpha_app/core/utils/step_resolver.dart';
import 'package:alpha_app/widgets/option_chip.dart';
import 'package:alpha_app/widgets/multi_select_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';


String _translatedFinancialItem(BuildContext context, String value) {
  if (context.locale.languageCode != "ar") {
    return value == "Temporary Job" ? "Recurring Side Income" : value;
  }

  const arabicByValue = <String, String>{
    "Temporary Job": "دخل جانبي متكرر",
    "Recurring Side Income": "دخل جانبي متكرر",
    "Family Support": "دعم عائلي",
    "External Support": "دعم خارجي",
    "Rent Income": "دخل إيجار",
    "Other": "أخرى",
    "Education": "التعليم",
    "House Rent": "إيجار المنزل",
    "Loan": "القروض",
    "Bills": "الفواتير",
    "Treatment": "العلاج",
    "Saving": "الادخار",
    "Food": "الطعام",
    "Transportation": "المواصلات",
    "Shopping": "التسوق",
    "Entertainment": "الترفيه",
    "Personal Care": "العناية الشخصية",
  };

  return arabicByValue[value] ?? value;
}

String _translatedMoneyRelationship(BuildContext context, String value) {
  const keyByValue = <String, String>{
    "Careful spending": "careful_spending",
    "Balanced spending": "balanced_spending",
    "Emotional spending": "emotional_spending",
  };
  return keyByValue[value]?.tr() ?? value;
}

String _moneyRelationshipFromDisplay(BuildContext context, String display) {
  const values = <String>[
    "Careful spending",
    "Balanced spending",
    "Emotional spending",
  ];
  return values.firstWhere(
    (value) => _translatedMoneyRelationship(context, value) == display,
    orElse: () => display,
  );
}

String _translatedMainGoal(BuildContext context, String value) {
  const keyByValue = <String, String>{
    "Saving": "saving",
    "Debt payment": "debt_payment",
    "Daily budget": "daily_budget",
    "Emergency fund": "emergency_fund",
    "Other": "other",
  };
  return keyByValue[value]?.tr() ?? value;
}

String _mainGoalFromDisplay(BuildContext context, String display) {
  const values = <String>[
    "Saving",
    "Debt payment",
    "Daily budget",
    "Emergency fund",
    "Other",
  ];
  return values.firstWhere(
    (value) => _translatedMainGoal(context, value) == display,
    orElse: () => display,
  );
}

class FinancialSetupScreen extends StatefulWidget {
  const FinancialSetupScreen({super.key});

  @override
  State<FinancialSetupScreen> createState() => _FinancialSetupScreenState();
}

class _FinancialSetupScreenState extends State<FinancialSetupScreen> {
  bool _isNavigating = false;

  final _decimalFormatter =
      FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'));

  void _showSalaryDayPicker(
      BuildContext context, FinancialProvider provider, bool isDark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "select_salary_payment_day".tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color:
                            isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "salary_payment_day_description".tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 14,
                    color:
                        isDark ? AppColors.darkSubText : AppColors.lightSubText,
                  ),
                ),
                const SizedBox(height: 20),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 7,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1,
                  ),
                  itemCount: 31,
                  itemBuilder: (context, index) {
                    final day = index + 1;
                    final isSelected = provider.paymentDay == day;
                    return InkWell(
                      onTap: () {
                        provider.setPaymentDay(day);
                        Navigator.pop(ctx);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Semantics(
                        label: "${"salary_payment_day_semantics".tr()} $day",
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary)
                                : (isDark
                                    ? AppColors.darkCard
                                    : AppColors.lightCard),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? (isDark
                                      ? AppColors.darkPrimary
                                      : AppColors.lightPrimary)
                                  : (isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder),
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            day.toString(),
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? AppColors.darkText
                                      : AppColors.lightText),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);
    final themeProvider = Provider.of<Themeprovider>(context);
    final isDark = themeProvider.isDark;
    final financialProvider = context.watch<FinancialProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            screenW * 0.055,
            screenH * 0.025,
            screenW * 0.055,
            screenH * 0.035,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Title and Progress
              Text(
                "financial_step".tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: screenW * 0.04,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
                ),
              ),
              SizedBox(height: screenH * 0.02),
              Text(
                "financial_information".tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: screenW * 0.075,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              SizedBox(height: screenH * 0.01),
              Text(
                "financial_information_subtitle".tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: screenW * 0.035,
                  fontWeight: FontWeight.w500,
                  color:
                      isDark ? AppColors.darkSubText : AppColors.lightSubText,
                ),
              ),
              SizedBox(height: screenH * 0.02),
              LinearPercentIndicator(
                lineHeight: screenH * 0.015,
                percent: financialProvider.pageProgress.clamp(0.0, 1.0),
                padding: EdgeInsets.zero,
                backgroundColor:
                    isDark ? AppColors.darkBorder : AppColors.lightBorder,
                progressColor:
                    isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
                barRadius: const Radius.circular(10),
              ),
              SizedBox(height: screenH * 0.03),

              // 2. Relationship with money
              _SectionTitle("relationship_with_money".tr(),
                  isDark: isDark, screenW: screenW),
              SizedBox(height: screenH * 0.01),
              OptionChip(
                items: const [
                  "Careful spending",
                  "Balanced spending",
                  "Emotional spending",
                ]
                    .map((value) =>
                        _translatedMoneyRelationship(context, value))
                    .toList(),
                selected: financialProvider.moneyRelationshipDisplay == null
                    ? null
                    : _translatedMoneyRelationship(
                        context,
                        financialProvider.moneyRelationshipDisplay!,
                      ),
                onTap: (displayValue) {
                  financialProvider.setMoneyRelationship(
                    _moneyRelationshipFromDisplay(context, displayValue),
                  );
                },
              ),
              SizedBox(height: screenH * 0.03),

              // 3. Regular Monthly Salary
              _SectionTitle("regular_monthly_salary".tr(),
                  isDark: isDark, screenW: screenW),
              const SizedBox(height: 4),
              Text(
                "regular_salary_description".tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkSubText
                        : AppColors.lightSubText),
              ),
              SizedBox(height: screenH * 0.01),
              CustomTextfield(
                controller: financialProvider.regularSalaryController,
                hint: "enter_monthly_salary".tr(),
                type: TextFieldType.number,
                inputFormatters: [_decimalFormatter],
                suffix: const Padding(
                    padding: EdgeInsets.all(12), child: Text("JOD")),
                onChanged: financialProvider.setRegularSalary,
              ),
              SizedBox(height: screenH * 0.03),

              // 4. Additional Expected Monthly Income
              _SectionTitle("additional_monthly_income".tr(),
                  isDark: isDark, screenW: screenW),
              const SizedBox(height: 4),
              Text(
                "additional_income_description".tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkSubText
                        : AppColors.lightSubText),
              ),
              SizedBox(height: screenH * 0.01),
              MultiSelectChip(
                items: financialProvider.incomeSources
                    .map((item) => _translatedFinancialItem(context, item.name))
                    .toList(),
                selectedItems: financialProvider.incomeSources
                    .where((item) => item.selected)
                    .map((item) => _translatedFinancialItem(context, item.name))
                    .toList(),
                onTap: (displayName) {
                  final displayedItems = financialProvider.incomeSources
                      .map(
                        (source) => _translatedFinancialItem(
                          context,
                          source.name,
                        ),
                      )
                      .toList();

                  final selectedIndex =
                      displayedItems.indexOf(displayName);

                  if (selectedIndex == -1) {
                    return;
                  }

                  financialProvider.toggleIncome(
                    financialProvider.incomeSources[selectedIndex],
                  );
                },
              ),
              SizedBox(height: screenH * 0.01),
              ...financialProvider.incomeSources
                  .where((e) => e.selected)
                  .map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: CustomTextfield(
                    controller: item.controller,
                    hint: "additional_monthly_amount".tr(),
                    type: TextFieldType.number,
                    inputFormatters: [_decimalFormatter],
                    suffix: const Padding(
                        padding: EdgeInsets.all(12), child: Text("JOD")),
                    onChanged: (val) =>
                        financialProvider.updateIncomeAmount(item, val),
                  ),
                );
              }),
              SizedBox(height: screenH * 0.03),

              // 5. Expected Monthly Income Total
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (isDark
                          ? AppColors.darkAccent.withOpacity(0.4)
                          : AppColors.lightAccent.withOpacity(0.4))
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkAccent
                          : AppColors.lightAccent),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${"expected_monthly_income".tr()}:",
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 16,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${financialProvider.totalIncome.toStringAsFixed(2)} JOD",
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "expected_income_note".tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText),
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenH * 0.03),

              // 6. Salary Payment Day
              _SectionTitle("salary_payment_day".tr(),
                  isDark: isDark, screenW: screenW),
              SizedBox(height: screenH * 0.01),
              InkWell(
                onTap: () =>
                    _showSalaryDayPicker(context, financialProvider, isDark),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        financialProvider.paymentDay != null
                            ? "${"day".tr()} ${financialProvider.paymentDay}"
                            : "select_salary_day".tr(),
                        style: GoogleFonts.ibmPlexSansArabic(
                          fontSize: 16,
                          color: financialProvider.paymentDay != null
                              ? (isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText)
                              : (isDark
                                  ? AppColors.darkSubText
                                  : AppColors.lightSubText),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down,
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText),
                    ],
                  ),
                ),
              ),
              SizedBox(height: screenH * 0.03),

              // 7. Fixed Monthly Expenses
              _SectionTitle("fixed_monthly_expenses".tr(),
                  isDark: isDark, screenW: screenW),
              SizedBox(height: screenH * 0.01),
              MultiSelectChip(
                items: financialProvider.fixedExpenses
                    .map((item) => _translatedFinancialItem(context, item.name))
                    .toList(),
                selectedItems: financialProvider.fixedExpenses
                    .where((item) => item.selected)
                    .map((item) => _translatedFinancialItem(context, item.name))
                    .toList(),
                onTap: (displayName) {
                  final displayedItems = financialProvider.fixedExpenses
                      .map(
                        (expense) => _translatedFinancialItem(
                          context,
                          expense.name,
                        ),
                      )
                      .toList();

                  final selectedIndex =
                      displayedItems.indexOf(displayName);

                  if (selectedIndex == -1) {
                    return;
                  }

                  financialProvider.toggleExpense(
                    financialProvider.fixedExpenses[selectedIndex],
                  );
                },
              ),
              SizedBox(height: screenH * 0.01),
              ...financialProvider.fixedExpenses
                  .where((e) => e.selected)
                  .map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: CustomTextfield(
                    controller: item.controller,
                    hint: "enter_monthly_amount_for".tr(args: [_translatedFinancialItem(context, item.name)]),
                    type: TextFieldType.number,
                    inputFormatters: [_decimalFormatter],
                    suffix: const Padding(
                        padding: EdgeInsets.all(12), child: Text("JOD")),
                    onChanged: (val) =>
                        financialProvider.updateExpenseAmount(item, val),
                  ),
                );
              }),
              SizedBox(height: screenH * 0.03),

              // 8. Flexible Monthly Expenses
              _SectionTitle("flexible_monthly_expenses".tr(),
                  isDark: isDark, screenW: screenW),
              SizedBox(height: screenH * 0.01),
              MultiSelectChip(
                items: financialProvider.flexibleExpenses
                    .map((item) => _translatedFinancialItem(context, item.name))
                    .toList(),
                selectedItems: financialProvider.flexibleExpenses
                    .where((item) => item.selected)
                    .map((item) => _translatedFinancialItem(context, item.name))
                    .toList(),
                onTap: (displayName) {
                  final displayedItems = financialProvider.flexibleExpenses
                      .map(
                        (expense) => _translatedFinancialItem(
                          context,
                          expense.name,
                        ),
                      )
                      .toList();

                  final selectedIndex =
                      displayedItems.indexOf(displayName);

                  if (selectedIndex == -1) {
                    return;
                  }

                  financialProvider.toggleExpense(
                    financialProvider.flexibleExpenses[selectedIndex],
                    isFixed: false,
                  );
                },
              ),
              SizedBox(height: screenH * 0.01),
              ...financialProvider.flexibleExpenses
                  .where((e) => e.selected)
                  .map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: CustomTextfield(
                    controller: item.controller,
                    hint: "enter_monthly_amount_for".tr(args: [_translatedFinancialItem(context, item.name)]),
                    type: TextFieldType.number,
                    inputFormatters: [_decimalFormatter],
                    suffix: const Padding(
                        padding: EdgeInsets.all(12), child: Text("JOD")),
                    onChanged: (val) =>
                        financialProvider.updateExpenseAmount(item, val),
                  ),
                );
              }),
              SizedBox(height: screenH * 0.03),

              // 9. Estimated Financial Summary
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkCard : AppColors.lightCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: isDark
                          ? AppColors.darkBorder
                          : AppColors.lightBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("estimated_financial_summary".tr(),
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText)),
                    const SizedBox(height: 8),
                    Text(
                        "estimated_summary_note".tr(),
                        style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkSubText
                                : AppColors.lightSubText)),
                    Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        height: 24),
                    _SummaryRow("expected_monthly_income".tr(),
                        financialProvider.totalIncome,
                        isDark: isDark),
                    _SummaryRow(
                        "fixed_expenses".tr(), financialProvider.totalFixedExpenses,
                        isDark: isDark),
                    _SummaryRow("flexible_expenses".tr(),
                        financialProvider.totalVariableExpenses,
                        isDark: isDark),
                    Divider(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                        height: 24),
                    _SummaryRow("total_estimated_expenses".tr(),
                        financialProvider.totalExpenses,
                        isDark: isDark, isBold: true),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          financialProvider.estimatedBalance >= 0
                              ? "estimated_surplus".tr()
                              : "estimated_deficit".tr(),
                          style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText),
                        ),
                        Text(
                          "${financialProvider.estimatedBalance >= 0 ? financialProvider.surplus.toStringAsFixed(2) : financialProvider.deficit.toStringAsFixed(2)} JOD",
                          style: GoogleFonts.ibmPlexSansArabic(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: financialProvider.estimatedBalance >= 0
                                ? (isDark
                                    ? AppColors.darkPrimary
                                    : AppColors.lightPrimary)
                                : (isDark
                                    ? AppColors.darkError
                                    : AppColors.lightError),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenH * 0.04),

              // 10. Main Financial Goal
              _SectionTitle("main_financial_goal".tr(),
                  isDark: isDark, screenW: screenW),
              SizedBox(height: screenH * 0.01),
              OptionChip(
                items: const [
                  "Saving",
                  "Debt payment",
                  "Daily budget",
                  "Emergency fund",
                  "Other",
                ]
                    .map((value) => _translatedMainGoal(context, value))
                    .toList(),
                selected: financialProvider.mainGoalDisplay == null
                    ? null
                    : _translatedMainGoal(
                        context,
                        financialProvider.mainGoalDisplay!,
                      ),
                onTap: (displayValue) {
                  financialProvider.setMainGoal(
                    _mainGoalFromDisplay(context, displayValue),
                  );
                },
              ),
              SizedBox(height: screenH * 0.03),

              // 11. Optional Extra Monthly Saving Target
              _SectionTitle("optional_saving_target".tr(),
                  isDark: isDark, screenW: screenW),
              const SizedBox(height: 4),
              Text(
                "saving_target_description".tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: 13,
                    color: isDark
                        ? AppColors.darkSubText
                        : AppColors.lightSubText),
              ),
              SizedBox(height: screenH * 0.01),
              CustomTextfield(
                controller: financialProvider.savingTargetController,
                hint: "enter_optional_saving".tr(),
                type: TextFieldType.number,
                inputFormatters: [_decimalFormatter],
                suffix: const Padding(
                    padding: EdgeInsets.all(12), child: Text("JOD")),
                onChanged: financialProvider.setSavingTarget,
              ),
              SizedBox(height: screenH * 0.04),

              // 12. Disabled Reason
              if (financialProvider.disabledReason != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    financialProvider.disabledReason!,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color:
                          isDark ? AppColors.darkError : AppColors.lightError,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // 13. Next Button
              Padding(
                padding: EdgeInsets.only(bottom: screenH * 0.02),
                child: SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: (financialProvider.isValid &&
                            !onboardingProvider.isLoading)
                        ? () async {
                            if (_isNavigating) return;
                            setState(() => _isNavigating = true);

                            try {
                              final successPersonal =
                                  await onboardingProvider.savePersonalInfo(
                                financialProvider.personalInfoData,
                              );
                              if (!mounted) return;

                              if (successPersonal) {
                                final successFinancial =
                                    await onboardingProvider.saveFinancialSetup(
                                  monthlyIncome: financialProvider.totalIncome,
                                  paymentDay: financialProvider.paymentDay,
                                );
                                if (!mounted) return;

                                if (successFinancial) {
                                  replaceWithOnboardingStep(
                                    context,
                                    onboardingProvider.nextStep,
                                    allocation: onboardingProvider.allocation,
                                  );
                                } else if (onboardingProvider.errorMessage !=
                                    null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            onboardingProvider.errorMessage!)),
                                  );
                                }
                              } else if (onboardingProvider.errorMessage !=
                                  null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          onboardingProvider.errorMessage!)),
                                );
                              }
                            } finally {
                              if (mounted) {
                                setState(() => _isNavigating = false);
                              }
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? AppColors.darkPrimary
                          : AppColors.lightPrimary,
                      disabledBackgroundColor:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    child: (onboardingProvider.isLoading || _isNavigating)
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "next".tr(),
                            style: GoogleFonts.ibmPlexSansArabic(
                              fontSize: 18,
                              color: financialProvider.isValid
                                  ? (isDark
                                      ? AppColors.darkBackground
                                      : AppColors.lightCard)
                                  : (isDark
                                      ? AppColors.darkSubText
                                      : AppColors.lightSubText),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  final double screenW;

  const _SectionTitle(this.title,
      {required this.isDark, required this.screenW});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexSansArabic(
        fontSize: screenW * 0.04,
        fontWeight: FontWeight.bold,
        color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final double amount;
  final bool isDark;
  final bool isBold;

  const _SummaryRow(this.label, this.amount,
      {required this.isDark, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
          Text(
            "${amount.toStringAsFixed(2)} JOD",
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}