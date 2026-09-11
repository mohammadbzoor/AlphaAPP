import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/goal_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/goals/goal_date.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:alpha_app/widgets/custom_textfield.dart';
import 'package:alpha_app/widgets/goals/priority_card.dart';
import 'package:alpha_app/widgets/multi_select_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class NewGoalScreen extends StatefulWidget {
  const NewGoalScreen({
    super.key,
  });

  @override
  State<NewGoalScreen> createState() =>
      _NewGoalScreenState();
}

class _NewGoalScreenState extends State<NewGoalScreen> {
  bool _formPrepared = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _formPrepared) {
        return;
      }

      _formPrepared = true;
      context.read<GoalProvider>().clearForm();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<GoalProvider>();
    final themeProvider = context.watch<Themeprovider>();

    final bool isDark = themeProvider.isDark;
    final double screenW = Device.width(context);
    final double screenH = Device.height(context);

    final Color backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final Color textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final Color subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final Color borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) {
        if (!didPop) {
          _closeScreen();
        }
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenW * 0.05,
                      screenH * 0.022,
                      screenW * 0.05,
                      0,
                    ),
                    child: _buildHeader(
                      isDark: isDark,
                      screenW: screenW,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        screenW * 0.05,
                        screenH * 0.012,
                        screenW * 0.05,
                        screenH * 0.03,
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            'new_goal.description'.tr(),
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              color: subTextColor,
                              fontSize:
                                  screenW * 0.034,
                              fontWeight:
                                  FontWeight.w500,
                              height: 1.5,
                            ),
                          ),
                          SizedBox(
                            height: screenH * 0.026,
                          ),

                          _GoalFormSection(
                            title:
                                'new_goal.choose_goal'.tr(),
                            icon:
                                Icons.flag_outlined,
                            color: primaryColor,
                            isDark: isDark,
                            child: MultiSelectChip(
                              items: provider
                                  .goalCategories
                                  .map(
                                    (category) =>
                                        _translatedGoalCategory(
                                      context,
                                      category,
                                    ),
                                  )
                                  .toList(),
                              selectedItems:
                                  provider.selectedCategory ==
                                          null
                                      ? []
                                      : [
                                          _translatedGoalCategory(
                                            context,
                                            provider
                                                .selectedCategory!,
                                          ),
                                        ],
                              onTap:
                                  (translatedCategory) {
                                provider.setCategory(
                                  _originalGoalCategory(
                                    context,
                                    translatedCategory,
                                    provider
                                        .goalCategories,
                                  ),
                                );
                              },
                            ),
                          ),

                          if (provider.selectedCategory ==
                              'Other') ...[
                            SizedBox(
                              height: screenH * 0.018,
                            ),
                            _GoalFormSection(
                              title:
                                  'new_goal.goal_name'.tr(),
                              icon: Icons
                                  .edit_outlined,
                              color: isDark
                                  ? AppColors.darkAccent
                                  : AppColors
                                      .lightAccent,
                              isDark: isDark,
                              child: CustomTextfield(
                                controller: provider
                                    .customNameController,
                                hint:
                                    'new_goal.enter_goal_name'
                                        .tr(),
                                type:
                                    TextFieldType.name,
                                icon:
                                    Icons.flag_outlined,
                                onChanged: (_) {
                                  provider.refresh();
                                },
                              ),
                            ),
                          ],

                          SizedBox(
                            height: screenH * 0.018,
                          ),

                          _GoalFormSection(
                            title:
                                'new_goal.total_target_cost'
                                    .tr(),
                            icon:
                                Icons.payments_outlined,
                            color: isDark
                                ? AppColors.darkSecondary
                                : AppColors
                                    .lightSecondary,
                            isDark: isDark,
                            child: CustomTextfield(
                              controller:
                                  provider.amountController,
                              hint:
                                  'new_goal.target_cost_total'
                                      .tr(),
                              type:
                                  TextFieldType.number,
                              icon:
                                  Icons.payments_outlined,
                              suffix: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  12,
                                ),
                                child: Text(
                                  'common.jod'.tr(),
                                  style: TextStyle(
                                    color:
                                        subTextColor,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                              onChanged: (_) {
                                provider.refresh();
                              },
                            ),
                          ),

                          SizedBox(
                            height: screenH * 0.018,
                          ),

                          _GoalFormSection(
                            title:
                                'new_goal.priority'.tr(),
                            icon: Icons
                                .priority_high_rounded,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.lightAccent,
                            isDark: isDark,
                            child: PriorityCard(
                              priority:
                                  provider.priority,
                              isDark: isDark,
                              screenW: screenW,
                              onChanged: (value) {
                                provider.setPriority(
                                  value.toInt(),
                                );
                              },
                            ),
                          ),

                          SizedBox(
                            height: screenH * 0.018,
                          ),

                          _GoalFormSection(
                            title:
                                'new_goal.target_date'.tr(),
                            icon: Icons
                                .calendar_month_outlined,
                            color: primaryColor,
                            isDark: isDark,
                            child: CustomTextfield(
                              controller: provider
                                  .targetDateController,
                              hint:
                                  'new_goal.select_target_date'
                                      .tr(),
                              icon: Icons
                                  .calendar_month_outlined,
                              type:
                                  TextFieldType.date,
                              readOnly: true,
                              onTap: () {
                                _selectGoalDate(
                                  provider,
                                );
                              },
                            ),
                          ),

                          SizedBox(
                            height: screenH * 0.018,
                          ),

                          _GoalFormSection(
                            title:
                                'new_goal.planned_monthly_contribution'
                                    .tr(),
                            icon: Icons
                                .auto_graph_rounded,
                            color: isDark
                                ? AppColors.darkSecondary
                                : AppColors
                                    .lightSecondary,
                            isDark: isDark,
                            trailing: provider
                                    .isContributionManuallyEdited
                                ? InkWell(
                                    onTap: provider
                                        .resetContributionToSuggestion,
                                    borderRadius:
                                        BorderRadius.circular(
                                      12,
                                    ),
                                    child: Container(
                                      width: 38,
                                      height: 38,
                                      decoration:
                                          BoxDecoration(
                                        color: primaryColor
                                            .withOpacity(
                                          0.10,
                                        ),
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          12,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons
                                            .refresh_rounded,
                                        color:
                                            primaryColor,
                                        size: 20,
                                      ),
                                    ),
                                  )
                                : null,
                            child: CustomTextfield(
                              controller: provider
                                  .contributionController,
                              hint:
                                  'new_goal.monthly_contribution'
                                      .tr(),
                              type:
                                  TextFieldType.number,
                              icon: Icons
                                  .auto_graph_rounded,
                              suffix: Padding(
                                padding:
                                    const EdgeInsets.all(
                                  12,
                                ),
                                child: Text(
                                  'common.jod'.tr(),
                                  style: TextStyle(
                                    color:
                                        subTextColor,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),
                              ),
                              onChanged: (_) {
                                provider
                                    .onContributionEdited();
                              },
                            ),
                          ),

                          SizedBox(
                            height: screenH * 0.02,
                          ),

                          _AlphaGoalPreviewCard(
                            provider: provider,
                            isDark: isDark,
                            screenW: screenW,
                          ),

                          if (provider.errorMessage !=
                              null) ...[
                            SizedBox(
                              height:
                                  screenH * 0.018,
                            ),
                            _ErrorCard(
                              message: provider
                                  .errorMessage!,
                              onClose:
                                  provider.clearError,
                            ),
                          ],

                          SizedBox(
                            height: screenH * 0.03,
                          ),

                          AppButton(
                            text:
                                'new_goal.add_goal'.tr(),
                            isDark: isDark,
                            isLoading:
                                provider.isSaving,
                            width: double.infinity,
                            height:
                                screenH * 0.065,
                            borderRadius: 14,
                            onPressed: () async {
                              if (!provider.isValid) {
                                ScaffoldMessenger.of(
                                  context,
                                )
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          isDark
                                              ? AppColors
                                                  .darkError
                                              : AppColors
                                                  .lightError,
                                      content: Text(
                                        'common.complete_required_fields'
                                            .tr(),
                                        style: GoogleFonts
                                            .ibmPlexSansArabic(
                                          fontSize:
                                              screenW *
                                                  0.04,
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),
                                      behavior:
                                          SnackBarBehavior
                                              .floating,
                                    ),
                                  );

                                return;
                              }

                              final bool saved =
                                  await provider
                                      .saveCurrentGoal();

                              if (!context.mounted) {
                                return;
                              }

                              if (!saved) {
                                ScaffoldMessenger.of(
                                  context,
                                )
                                  ..hideCurrentSnackBar()
                                  ..showSnackBar(
                                    SnackBar(
                                      backgroundColor:
                                          isDark
                                              ? AppColors
                                                  .darkError
                                              : AppColors
                                                  .lightError,
                                      content: Text(
                                        provider.errorMessage ??
                                            'new_goal.could_not_save'
                                                .tr(),
                                        style: GoogleFonts
                                            .ibmPlexSansArabic(
                                          fontSize:
                                              screenW *
                                                  0.04,
                                          fontWeight:
                                              FontWeight
                                                  .w500,
                                        ),
                                      ),
                                      behavior:
                                          SnackBarBehavior
                                              .floating,
                                    ),
                                  );

                                return;
                              }

                              ScaffoldMessenger.of(
                                context,
                              )
                                ..hideCurrentSnackBar()
                                ..showSnackBar(
                                  SnackBar(
                                    backgroundColor:
                                        isDark
                                            ? AppColors
                                                .darkSecondary
                                            : AppColors
                                                .lightSecondary,
                                    content: Text(
                                      'new_goal.added_successfully'
                                          .tr(),
                                      style: GoogleFonts
                                          .ibmPlexSansArabic(
                                        fontSize:
                                            screenW *
                                                0.04,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                      ),
                                    ),
                                    behavior:
                                        SnackBarBehavior
                                            .floating,
                                  ),
                                );

                              Navigator.pop(
                                context,
                                true,
                              );
                            },
                          ),

                          SizedBox(
                            height: screenH * 0.02,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (provider.isSaving)
                Positioned.fill(
                  child: AbsorbPointer(
                    child: Container(
                      color: Colors.black
                          .withOpacity(0.15),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader({
    required bool isDark,
    required double screenW,
  }) {
    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Row(
      children: [
        Expanded(
          child: Text(
            'new_goal.title'.tr(),
            style: GoogleFonts.ibmPlexSansArabic(
              color: isDark
                  ? AppColors.darkText
                  : AppColors.lightText,
              fontSize: screenW * 0.065,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        InkWell(
          onTap: _closeScreen,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: screenW * 0.11,
            height: screenW * 0.11,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(
                isDark ? 0.10 : 0.07,
              ),
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color:
                    primaryColor.withOpacity(0.22),
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: primaryColor,
              size: screenW * 0.055,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectGoalDate(
    GoalProvider provider,
  ) async {
    final dynamic selectedDate =
        await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GoalDateScreen(
          initialDate: provider.targetDate,
        ),
      ),
    );

    if (!mounted ||
        selectedDate == null ||
        selectedDate is! DateTime) {
      return;
    }

    provider.setDate(selectedDate);
  }

  void _closeScreen() {
    context.read<GoalProvider>().clearForm();
    Navigator.pop(context);
  }
}

class _GoalFormSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final bool isDark;
  final Widget child;
  final Widget? trailing;

  const _GoalFormSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.child,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.10),
                  borderRadius:
                      BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style:
                      GoogleFonts.ibmPlexSansArabic(
                    color: textColor,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 13),
          child,
        ],
      ),
    );
  }
}

String _translatedGoalCategory(
  BuildContext context,
  String category,
) {
  final Map<String, String> keys = {
    'Emergency Fund':
        'goal_categories.emergency_fund',
    'Laptop': 'goal_categories.laptop',
    'Travel': 'goal_categories.travel',
    'Car': 'goal_categories.car',
    'Education': 'goal_categories.education',
    'House': 'goal_categories.house',
    'Business': 'goal_categories.business',
    'Furniture':
        'goal_categories.furniture',
    'Other': 'goal_categories.other',
  };

  final key = keys[category];

  return key == null
      ? category
      : context.tr(key);
}

String _originalGoalCategory(
  BuildContext context,
  String translatedCategory,
  List<String> sourceCategories,
) {
  for (final originalCategory
      in sourceCategories) {
    if (_translatedGoalCategory(
          context,
          originalCategory,
        ) ==
        translatedCategory) {
      return originalCategory;
    }
  }

  return translatedCategory;
}

class _AlphaGoalPreviewCard extends StatelessWidget {
  final GoalProvider provider;
  final bool isDark;
  final double screenW;

  const _AlphaGoalPreviewCard({
    required this.provider,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final Color secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryColor.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: secondaryColor.withOpacity(0.24),
        ),
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.12),
              borderRadius:
                  BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  'new_goal.alpha_preview'.tr(),
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    color: primaryColor,
                    fontSize: screenW * 0.036,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _buildMessage(context),
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    color: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                    fontSize: screenW * 0.032,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _buildMessage(
    BuildContext context,
  ) {
    if (provider.selectedCategory == null) {
      return 'new_goal.preview.choose_goal'
          .tr();
    }

    if (provider.targetAmountValue <= 0) {
      return 'new_goal.preview.enter_target_cost'
          .tr();
    }

    if (provider.plannedContributionValue <=
        0) {
      return 'new_goal.preview.enter_contribution'
          .tr();
    }

    if (provider.targetDate == null) {
      return 'new_goal.preview.select_date'
          .tr();
    }

    if (provider.priority >= 8) {
      return 'new_goal.preview.high_priority'
          .tr();
    }

    if (provider.plannedContributionValue <
        20) {
      return 'new_goal.preview.low_contribution'
          .tr();
    }

    return 'new_goal.preview.realistic'.tr();
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;

  const _ErrorCard({
    required this.message,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark =
        context.watch<Themeprovider>().isDark;

    final Color errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(
        left: 13,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: errorColor.withOpacity(0.10),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: errorColor.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: errorColor,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style:
                  GoogleFonts.ibmPlexSansArabic(
                color: errorColor,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: errorColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}
