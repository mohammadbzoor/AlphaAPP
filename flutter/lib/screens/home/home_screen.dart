import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/models/home_model.dart';
import 'package:alpha_app/providers/home_provider.dart';
import 'package:alpha_app/providers/language_provider.dart';
import 'package:alpha_app/providers/profile_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/providers/expense_provider.dart';
import 'package:alpha_app/screens/analysis/financial_analysis_center_screen.dart';
import 'package:alpha_app/screens/challenges/chanllenges_screen.dart';
import 'package:alpha_app/screens/expenses/new_expense_screen.dart';
import 'package:alpha_app/screens/goals/goal_history.dart';
import 'package:alpha_app/screens/receipts/receipt_input_screen.dart';
import 'package:alpha_app/screens/notifications/notifications_screen.dart';
import 'package:alpha_app/providers/notification_provider.dart';
import 'package:alpha_app/providers/challenge_provider.dart';
import 'package:alpha_app/widgets/Home/birthday_dialog.dart';
import 'package:alpha_app/widgets/Home/progress_card.dart';
import 'package:alpha_app/widgets/Home/quick_actions_grid.dart';
import 'package:alpha_app/providers/cycle_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:alpha_app/widgets/complete_profile_card.dart';
import 'package:alpha_app/screens/profile/financial_profile_screen.dart';
import 'package:alpha_app/core/utils/onboarding_guard.dart';
import 'package:alpha_app/screens/planning/savings_allocation_screen.dart';
import 'package:alpha_app/core/utils/dashboard_action_result.dart';
import 'package:alpha_app/widgets/dashboard/cycle_header.dart';
import 'package:alpha_app/widgets/dashboard/income_overview.dart';
import 'package:alpha_app/widgets/dashboard/safe_daily_spending.dart';
import 'package:alpha_app/widgets/dashboard/bucket_cards.dart';
import 'package:alpha_app/widgets/dashboard/commitments_summary.dart';
import 'package:alpha_app/widgets/dashboard/goals_summary.dart';
import 'package:alpha_app/widgets/dashboard/dashboard_warnings.dart';
import 'package:alpha_app/widgets/dashboard/section_title.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _didLoadDashboard = false;
  bool _hasShownBirthdayDialog = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_didLoadDashboard && mounted) {
        _didLoadDashboard = true;
        _initializeDashboard();
      }
    });
  }

  Future<void> _initializeDashboard() async {
    if (!mounted) return;

    final onboardingProvider = context.read<OnboardingProvider>();
    final cycleProvider = context.read<CycleProvider>();
    final homeProvider = context.read<HomeProvider>();
    final profileProvider = context.read<ProfileProvider>();

    // 1. Load Onboarding status
    await onboardingProvider.checkOnboardingStatus();
    if (!mounted) return;

    if (!onboardingProvider.isOnboarded) {
      // Not onboarded -> CompleteProfileCard only, do NOT load financial data
      return;
    }

    // Load profile summary safely in background
    if (!profileProvider.hasProfile && !profileProvider.isLoading) {
      profileProvider.loadProfileSummary().catchError((_) {});
    }

    // 2. Load Current Cycle
    await cycleProvider.loadCurrentCycle();
    if (!mounted) return;

    if (!cycleProvider.hasActiveCycle) {
      // No active cycle -> StartCycleCard only, do NOT load dashboard data
      return;
    }

    // 3. Load Dashboard Data (which internally handles expenses, etc.)
    if (!homeProvider.hasData && !homeProvider.isLoading) {
      await homeProvider.loadHomeData();
    }
    
    // 4. Fetch Notifications Unread Count
    if (mounted) {
      context.read<NotificationProvider>().fetchUnreadCount();
      context.read<ChallengeProvider>().loadChallenges();
    }
  }

  @override
  Widget build(BuildContext context) {
    
     final languageProvider = Provider.of<LanguageProvider>(context);
    final homeProvider = context.watch<HomeProvider>();

    final themeProvider = context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    final homeData = homeProvider.homeData;

    final screenW = Device.width(context);
    final screenH = Device.height(context);

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: SafeArea(
        child: _buildBody(
            context: context,
            homeProvider: homeProvider,
            homeData: homeData,
            isDark: isDark,
            screenWidth: screenW,
            screenHeight: screenH),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required HomeProvider homeProvider,
    required HomeModel? homeData,
    required bool isDark,
    required double screenWidth,
    required double screenHeight,
  }) {
    final cycleProvider = context.watch<CycleProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();
    final profileProvider = context.watch<ProfileProvider>();

    if (profileProvider.hasProfile && profileProvider.isBirthdayToday && !_hasShownBirthdayDialog) {
      _hasShownBirthdayDialog = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          builder: (_) => BirthdayDialog(
            name: profileProvider.firstName.isEmpty ? 'صديقنا' : profileProvider.firstName,
            isDark: isDark,
          ),
        );
      });
    }

    // 1. Onboarding Loading
    if (onboardingProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
      );
    }

    // 2. Onboarding Error
    if (onboardingProvider.errorMessage != null) {
      return _HomeErrorView(
        message:
            onboardingProvider.errorMessage ?? "home_extra.financial_profile_load_failed".tr(),
        isDark: isDark,
        onRetry: () => onboardingProvider.checkOnboardingStatus(),
      );
    }

    // 3. Not Onboarded
    if (!onboardingProvider.isOnboarded) {
      return _buildScrollableContent(
        context: context,
        isDark: isDark,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(
                userName: profileProvider.displayName,
                isDark: isDark,
                onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _BirthdayGreetingCard(
              isDark: isDark,
              profileProvider: profileProvider,
            ),
            SizedBox(height: screenHeight * 0.03),
            CompleteProfileCard(isDark: isDark),
          ],
        ),
      );
    }

    // 3.5. Onboarded but Financial Profile Incomplete
    if (!onboardingProvider.financialProfileComplete) {
      return _buildScrollableContent(
        context: context,
        isDark: isDark,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(
                userName: profileProvider.displayName,
                isDark: isDark,
                onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _BirthdayGreetingCard(
              isDark: isDark,
              profileProvider: profileProvider,
            ),
            SizedBox(height: screenHeight * 0.03),
            _FinancialProfileNeedsAttentionCard(
              isDark: isDark,
              missingFields: onboardingProvider.missingFinancialFields,
              onCompleteTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const FinancialProfileScreen()));
              },
            ),
          ],
        ),
      );
    }

    // 4. Cycle Loading
    if (cycleProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
      );
    }

    // 5. Cycle Error
    if (cycleProvider.error != null) {
      return _HomeErrorView(
        message: cycleProvider.error!,
        isDark: isDark,
        onRetry: () => cycleProvider.loadCurrentCycle(),
      );
    }

    // 6. No Active Cycle
    if (!cycleProvider.hasActiveCycle) {
      return _buildScrollableContent(
        context: context,
        isDark: isDark,
        screenWidth: screenWidth,
        screenHeight: screenHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HomeHeader(
                userName: profileProvider.displayName,
                isDark: isDark,
                onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
            _BirthdayGreetingCard(
              isDark: isDark,
              profileProvider: profileProvider,
            ),
            SizedBox(height: screenHeight * 0.03),
            _StartCycleCard(
              isDark: isDark,
              isLoading: cycleProvider.isCreatingCycle,
              onStart: () async {
                final success = await context
                    .read<CycleProvider>()
                    .createCycle({}, context.read<OnboardingProvider>());
                if (success && context.mounted) {
                  final cycleId = context.read<CycleProvider>().currentCycle['id']?.toString();
                  if (cycleId != null) {
                    final approved = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => SavingsAllocationScreen(cycleId: cycleId),
                      ),
                    );
                    if (approved == true && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("home_extra.cycle_started_successfully".tr(),
                              style: GoogleFonts.ibmPlexSansArabic()),
                          backgroundColor: isDark
                              ? AppColors.darkPrimary
                              : AppColors.lightPrimary,
                        ),
                      );
                    }
                  }
                } else if (context.mounted &&
                    context.read<CycleProvider>().error != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(context.read<CycleProvider>().error!,
                          style: GoogleFonts.ibmPlexSansArabic()),
                      backgroundColor:
                          isDark ? AppColors.darkError : AppColors.lightError,
                    ),
                  );
                  context.read<CycleProvider>().clearError();
                }
              },
            ),
          ],
        ),
      );
    }

    // 7. Home Loading
    if (homeProvider.isLoading) {
      return Center(
        child: CircularProgressIndicator(
            color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary),
      );
    }

    // 8. Home Error
    if (homeProvider.hasError) {
      return _HomeErrorView(
        message: homeProvider.errorMessage ?? "home_extra.dashboard_load_failed".tr(),
        isDark: isDark,
        onRetry: () => context.read<HomeProvider>().loadHomeData(),
      );
    }

    // 9. Dashboard data is ready
    if (homeData == null) {
      return _HomeErrorView(
        message: "common.something_went_wrong".tr(),
        isDark: isDark,
        onRetry: () => context.read<HomeProvider>().loadHomeData(),
      );
    }

    return _buildScrollableContent(
      context: context,
      isDark: isDark,
      screenWidth: screenWidth,
      screenHeight: screenHeight,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HomeHeader(
              userName: profileProvider.displayName,
              isDark: isDark,
              onNotificationTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()))),
          _BirthdayGreetingCard(
            isDark: isDark,
            profileProvider: profileProvider,
          ),
          SizedBox(height: screenHeight * 0.03),
          // 1. Warnings
          DashboardWarningsWidget(warnings: homeData.warnings, isDark: isDark),
          if (homeData.warnings.isNotEmpty &&
              !homeData.warnings.every((w) => w == 'NO_ACTIVE_FINANCIAL_CYCLE'))
            SizedBox(height: screenHeight * 0.02),

          // 2. Cycle Header
          CycleHeader(cycle: homeData.cycle, isDark: isDark),
          SizedBox(height: screenHeight * 0.03),

          // 3. Income Overview
          IncomeOverview(income: homeData.income, isDark: isDark),
          SizedBox(height: screenHeight * 0.03),



          // 5. Buckets (Needs, Wants, Savings)
          SectionTitle(title: "home_extra.budgets_savings".tr(), isDark: isDark),
          SizedBox(height: screenHeight * 0.015),
          BucketCardsSection(
            buckets: homeData.buckets,
            isDark: isDark,
          
          ),
          SizedBox(height: screenHeight * 0.03),

          // 6. Commitments Summary
          CommitmentsSummaryWidget(
            commitments: homeData.commitments,
            isDark: isDark,
            onViewCommitments: () {
              // Navigate to commitments list
            },
          ),
          if ((homeData.commitments?.totalReserved ?? 0) > 0 ||
              (homeData.commitments?.upcomingCount ?? 0) > 0 ||
              (homeData.commitments?.overdueCount ?? 0) > 0)
            SizedBox(height: screenHeight * 0.03),

          // 7. Goals Summary
          GoalsSummaryWidget(
            goals: homeData.goals,
            isDark: isDark,
            onViewGoals: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyGoalsScreen()),
              );
            },
          ),
          if ((homeData.goals?.activeCount ?? 0) > 0 ||
              (homeData.goals?.readyCount ?? 0) > 0)
            SizedBox(height: screenHeight * 0.03),

          // 8. Quick Actions Grid
          SectionTitle(title: "home.quick_actions".tr(), isDark: isDark),
          SizedBox(height: screenHeight * 0.015),
          Consumer<ChallengeProvider>(
            builder: (context, challengeProvider, child) {
              final activeChallenge = challengeProvider.firstActiveChallenge;
              if (activeChallenge == null) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProgressCard(
                    title: activeChallenge.title,
                    subtitle: activeChallenge.description,
                    progress: activeChallenge.progress,
                    color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                    icon: Icons.star,
                    isDark: isDark,
                  ),
                  SizedBox(height: screenHeight * 0.03),
                ],
              );
            },
          ),
          QuickActionsGrid(
            isDark: isDark,
            onAddExpense: () async {
              if (!requireOnboarding(context)) return;
              if (!cycleProvider.hasActiveCycle) {
                _showNoCycleMessage(context, isDark);
                return;
              }
              final result = await Navigator.push<DashboardActionResult>(
                context,
                MaterialPageRoute(
                  builder: (_) => const NewExpenseScreen(),
                ),
              );
              if (result == DashboardActionResult.created && context.mounted) {
                context.read<ExpenseProvider>().loadExpenses();
                context.read<HomeProvider>().refreshHomeData();
              }
            },
            onAnalytics: () {
              if (!requireOnboarding(context)) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const FinancialAnalysisCenterScreen(),
                ),
              );
            },
            onScanReceipt: () async {
              if (!requireOnboarding(context)) return;
              if (!cycleProvider.hasActiveCycle) {
                _showNoCycleMessage(context, isDark);
                return;
              }
              final result = await Navigator.push<DashboardActionResult>(
                context,
                MaterialPageRoute(
                  builder: (_) => const ReceiptInputScreen(),
                ),
              );
              if (result == DashboardActionResult.created && context.mounted) {
                context.read<ExpenseProvider>().loadExpenses();
                context.read<HomeProvider>().refreshHomeData();
              }
            },
            onChallenges: () {
              if (!requireOnboarding(context)) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ChallengesScreen(),
                ),
              );
            },
            onEmergencyFund: () {
              if (!requireOnboarding(context)) return;
              final activeCycleId = context.read<CycleProvider>().currentCycle['id']?.toString() ?? homeData.cycle?.id;
              if (!cycleProvider.hasActiveCycle || activeCycleId == null) {
                _promptStartCycleForEmergencyFund(context, isDark);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SavingsAllocationScreen(
                    cycleId: activeCycleId,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableContent({
    required BuildContext context,
    required bool isDark,
    required double screenWidth,
    required double screenHeight,
    required Widget child,
  }) {
    return RefreshIndicator(
      color: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
      onRefresh: () async {
        await context.read<CycleProvider>().loadCurrentCycle();
        if (context.read<CycleProvider>().hasActiveCycle) {
          await context.read<HomeProvider>().refreshHomeData();
          await context.read<ExpenseProvider>().loadExpenses();
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          screenWidth * 0.05,
          16,
          screenWidth * 0.05,
          132,
        ),
        child: child,
      ),
    );
  }

  void _showNoCycleMessage(BuildContext context, bool isDark) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "home_extra.start_cycle_first".tr(),
          style: GoogleFonts.ibmPlexSansArabic(),
        ),
        backgroundColor: isDark ? AppColors.darkError : AppColors.lightError,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _promptStartCycleForEmergencyFund(BuildContext context, bool isDark) async {
    final cycleProvider = context.read<CycleProvider>();
    final onboardingProvider = context.read<OnboardingProvider>();

    final shouldStart = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              Icons.health_and_safety_outlined,
              color: isDark ? AppColors.darkSecondary : AppColors.lightSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              "home_extra.start_cycle_title".tr(),
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
        content: Text(
          "لتخصيص نسبة صندوق الطوارئ، يجب أولًا بدء دورة مالية. هل ترغب في بدء الدورة المالية الآن؟",
          style: GoogleFonts.ibmPlexSansArabic(
            fontSize: 14,
            color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: Text(
              "common.cancel".tr(),
              style: GoogleFonts.ibmPlexSansArabic(
                color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
              ),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: Text(
              "home_extra.start_cycle_now".tr(),
              style: GoogleFonts.ibmPlexSansArabic(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    if (shouldStart == true && context.mounted) {
      final success = await cycleProvider.createCycle({}, onboardingProvider);
      if (success && context.mounted) {
        final cycleId = cycleProvider.currentCycle['id']?.toString();
        if (cycleId != null) {
          final approved = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SavingsAllocationScreen(cycleId: cycleId),
            ),
          );
          if (approved == true && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "home_extra.cycle_started_successfully".tr(),
                  style: GoogleFonts.ibmPlexSansArabic(),
                ),
                backgroundColor:
                    isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
              ),
            );
            await context.read<HomeProvider>().refreshHomeData();
          }
        }
      } else if (context.mounted && cycleProvider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              cycleProvider.error!,
              style: GoogleFonts.ibmPlexSansArabic(),
            ),
            backgroundColor: isDark ? AppColors.darkError : AppColors.lightError,
          ),
        );
        cycleProvider.clearError();
      }
    }
  }
}

class _StartCycleCard extends StatelessWidget {
  final bool isDark;
  final bool isLoading;
  final VoidCallback onStart;

  const _StartCycleCard({
    super.key,
    required this.isDark,
    required this.isLoading,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final accentColor =
        isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [
                  AppColors.darkCard,
                  primaryColor.withOpacity(0.11),
                  accentColor.withOpacity(0.06),
                ]
              : [
                  Colors.white,
                  secondaryColor.withOpacity(0.08),
                  accentColor.withOpacity(0.09),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: secondaryColor.withOpacity(0.34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryColor,
                      secondaryColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "home_extra.start_cycle_title".tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "home_extra.start_cycle_description".tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: subTextColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              _MiniFeature(
                icon: Icons.account_balance_wallet_outlined,
                label: "home_extra.clearer_budget".tr(),
                color: primaryColor,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _MiniFeature(
                icon: Icons.insights_outlined,
                label: "home_extra.smart_tracking".tr(),
                color: secondaryColor,
                isDark: isDark,
              ),
              const SizedBox(width: 10),
              _MiniFeature(
                icon: Icons.emoji_events_outlined,
                label: "home_extra.continuous_progress".tr(),
                color: accentColor,
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 20),
          AppButton(
            text: "home_extra.start_cycle_now".tr(),
            onPressed: onStart,
            isLoading: isLoading,
            isDark: isDark,
            height: 54,
            borderRadius: 14,
          ),
        ],
      ),
    );
  }
}

class _MiniFeature extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  const _MiniFeature({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(13),
          border: Border.all(
            color: color.withOpacity(0.24),
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(height: 5),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.ibmPlexSansArabic(
                color: isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// HEADER
// =====================================================

class _BirthdayGreetingCard extends StatelessWidget {
  final bool isDark;
  final ProfileProvider profileProvider;

  const _BirthdayGreetingCard({
    required this.isDark,
    required this.profileProvider,
  });

  @override
  Widget build(BuildContext context) {
    if (!profileProvider.isBirthdayToday) {
      return const SizedBox.shrink();
    }

    final name = profileProvider.firstName.isEmpty
        ? 'home_extra.friend'.tr()
        : profileProvider.firstName;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 18),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? const [
                  Color(0xFF243424),
                  Color(0xFF493A18),
                ]
              : const [
                  Color(0xFFFFFBEB),
                  Color(0xFFEFFDF5),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isDark
              ? AppColors.darkAccent.withOpacity(0.5)
              : AppColors.lightAccent.withOpacity(0.45),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkAccent.withOpacity(0.16)
                  : AppColors.lightAccent.withOpacity(0.14),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.cake_rounded,
              color: isDark ? AppColors.darkAccent : AppColors.lightAccent,
              size: 27,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'home_extra.happy_birthday'.tr(namedArgs: {'name': name}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'home_extra.birthday_message'.tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    color:
                        isDark ? AppColors.darkSubText : AppColors.lightSubText,
                    fontSize: 12.5,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  final String userName;
  final bool isDark;
  final VoidCallback onNotificationTap;

  const _HomeHeader({
    required this.userName,
    required this.isDark,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayName =
        userName.trim().isEmpty ? "common.user".tr() : userName.trim();

    final firstLetter = displayName[0].toUpperCase();

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final accentColor =
        isDark ? AppColors.darkAccent : AppColors.lightAccent;

    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [
                  AppColors.darkCard,
                  secondaryColor.withOpacity(0.13),
                  accentColor.withOpacity(0.07),
                ]
              : [
                  Colors.white,
                  secondaryColor.withOpacity(0.08),
                  accentColor.withOpacity(0.08),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: secondaryColor.withOpacity(0.30),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.045),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primaryColor,
                  secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: secondaryColor.withOpacity(0.22),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              firstLetter,
              style: GoogleFonts.ibmPlexSansArabic(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "home.hello_user".tr(namedArgs: {'name': displayName}),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "home.improve_finances_today".tr(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: subTextColor,
                    fontSize: 11.5,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Consumer<NotificationProvider>(
            builder: (context, notificationProvider, _) {
              final unreadCount =
                  notificationProvider.unreadCount;

              return InkWell(
                onTap: onNotificationTap,
                borderRadius: BorderRadius.circular(15),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(
                          color: accentColor.withOpacity(0.34),
                        ),
                      ),
                      child: Icon(
                        Icons.notifications_none_rounded,
                        color: accentColor,
                        size: 25,
                      ),
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Container(
                          constraints: const BoxConstraints(
                            minWidth: 20,
                            minHeight: 20,
                          ),
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkError
                                : AppColors.lightError,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isDark
                                  ? AppColors.darkCard
                                  : Colors.white,
                              width: 2,
                            ),
                          ),
                          child: Text(
                            unreadCount > 9
                                ? '9+'
                                : unreadCount.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// =====================================================
// FINANCIAL SCORE
// =====================================================

// =====================================================
// ERROR VIEW
// =====================================================

class _HomeErrorView extends StatelessWidget {
  final String message;
  final bool isDark;
  final VoidCallback onRetry;

  const _HomeErrorView({
    required this.message,
    required this.isDark,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkError.withOpacity(0.12)
                    : AppColors.lightError.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off_outlined,
                color: Color(0xFFFF6B6B),
                size: 35,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              "home.unable_to_load".tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                color: isDark ? AppColors.darkText : AppColors.lightText,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                color: isDark ? AppColors.darkSubText : AppColors.lightSubText,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: 190,
              child: AppButton(
                text: "common.try_again".tr(),
                onPressed: onRetry,
                isDark: isDark,
                height: 50,
                borderRadius: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FinancialProfileNeedsAttentionCard
    extends StatelessWidget {
  final bool isDark;
  final List<String> missingFields;
  final VoidCallback onCompleteTap;

  const _FinancialProfileNeedsAttentionCard({
    super.key,
    required this.isDark,
    required this.missingFields,
    required this.onCompleteTap,
  });

  String _formatMissingFields() {
    if (missingFields.isEmpty) {
      return "home_extra.review_financial_profile".tr();
    }

    final map = {
      'expectedMonthlyIncome': 'home_extra.missing_expected_income'.tr(),
      'paymentDay': 'home_extra.missing_payment_day'.tr(),
      'currency': 'home_extra.missing_currency'.tr(),
      'allocation_preferences':
          'home_extra.missing_allocation_preferences'.tr(),
      'valid_allocation_bps':
          'home_extra.missing_valid_allocation'.tr(),
      'financial_profiles': 'home_extra.missing_financial_profile'.tr(),
    };

    final names =
        missingFields.map((f) => map[f] ?? f).join('، ');

    return "home_extra.missing_or_invalid_fields".tr(namedArgs: {'fields': names});
  }

  @override
  Widget build(BuildContext context) {
    final warningColor = isDark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: isDark
              ? [
                  AppColors.darkCard,
                  warningColor.withOpacity(0.09),
                ]
              : [
                  Colors.white,
                  warningColor.withOpacity(0.10),
                ],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: warningColor.withOpacity(0.40),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: warningColor.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  color: warningColor,
                  size: 29,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "home_extra.financial_profile_incomplete".tr(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: textColor,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _formatMissingFields(),
                      style: GoogleFonts.ibmPlexSansArabic(
                        color: subTextColor,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.07),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline_rounded,
                  color: primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    "home_extra.complete_data_benefit".tr(),
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: subTextColor,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          AppButton(
            text: "complete_profile".tr(),
            onPressed: onCompleteTap,
            isLoading: false,
            isDark: isDark,
            height: 54,
            borderRadius: 14,
          ),
        ],
      ),
    );
  }
}
