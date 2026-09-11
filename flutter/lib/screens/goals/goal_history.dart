
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/goal_provider.dart';
import 'package:alpha_app/providers/language_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/goals/new_goal_screen.dart';
import 'package:alpha_app/widgets/delete_dialog.dart';
import 'package:alpha_app/widgets/goals/goal_card.dart';
import 'package:alpha_app/widgets/empty_screen.dart';
import 'package:alpha_app/widgets/dashed_action_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class MyGoalsScreen extends StatelessWidget {
  const MyGoalsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
     final languageProvider = Provider.of<LanguageProvider>(context);
    final goalProvider = context.watch<GoalProvider>();
    final themeProvider = context.watch<Themeprovider>();

    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final goals = goalProvider.activeGoals;

    final String activeGoalsText = goals.length == 1
        ? 'goals.active_singular'.tr(
            namedArgs: {
              'count': goals.length.toString(),
            },
          )
        : 'goals.active_plural'.tr(
            namedArgs: {
              'count': goals.length.toString(),
            },
          );

    return Scaffold(
      backgroundColor: themeProvider.isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * 0.06,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenH * 0.025,
              ),

              // ================= HEADER =================

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'goals.title'.tr(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: themeProvider.isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                            fontSize: screenW * 0.07,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: screenH * 0.004,
                        ),
                        Text(
                          activeGoalsText,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: themeProvider.isDark
                                ? AppColors.darkSubText
                                : AppColors.lightSubText,
                            fontSize: screenW * 0.035,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewGoalScreen(),
                      ),
                    ),
                    borderRadius: BorderRadius.circular(13),
                    child: Container(
                      width: screenW * 0.12,
                      height: screenW * 0.12,
                      decoration: BoxDecoration(
                        color: themeProvider.isDark
                            ? const Color(0xFF203330)
                            : AppColors.lightSecondary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        Icons.add,
                        color: themeProvider.isDark
                            ? AppColors.darkSubText
                            : AppColors.lightPrimary,
                        size: screenW * 0.075,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: screenH * 0.025,
              ),

              // ================= LIST =================

              Expanded(
                child: goals.isEmpty
                    ? EmptyStateView(
                        isDark: themeProvider.isDark,
                        screenW: screenW,
                        title: 'goals.empty_title'.tr(),
                        description: 'goals.empty_description'.tr(),
                        buttonText: 'goals.add_first_goal'.tr(),
                        icon: Icons.flag_outlined,
                        color: themeProvider.isDark
                            ? AppColors.darkAccent
                            : AppColors.lightAccent,
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewGoalScreen(),
                            ),
                          );
                        },
                      )
                    : ListView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: screenH * 0.14,
                        ),
                        children: [
                          ...goals.map(
                            (goal) => GoalCard(
                              goal: goal,
                              onDelete: () {
                                DeleteDialog.show(
                                  context: context,
                                  title: 'goals.delete_title'.tr(),
                                  message: 'goals.delete_message'.tr(
                                    namedArgs: {
                                      'title': goal.title,
                                    },
                                  ),
                                  onDelete: () {
                                    context
                                        .read<GoalProvider>()
                                        .removeGoal(
                                          goal.id ?? '',
                                        );

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'goals.deleted_successfully'.tr(),
                                          style:
                                              GoogleFonts.ibmPlexSansArabic(),
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          DashedActionButton(
                            text: 'goals.add_new_goal'.tr(),
                            icon: Icons.flag_outlined,
                            isDark: themeProvider.isDark,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => NewGoalScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(
                            height: screenH * 0.02,
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

