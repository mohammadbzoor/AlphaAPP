import 'dart:io';

import 'package:alpha_app/core/utils/onboarding_guard.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/cycle_provider.dart';
import 'package:alpha_app/providers/language_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/screens/ai_assistant/chat_screen.dart';
import 'package:alpha_app/screens/auth/otp_screen.dart';
import 'package:alpha_app/screens/expenses/expenses_screen.dart';
import 'package:alpha_app/screens/goals/goal_history.dart';
import 'package:alpha_app/screens/home/home_screen.dart';
import 'package:alpha_app/screens/profile/profile_screen.dart';
import 'package:alpha_app/screens/receipts/receipt_input_screen.dart';
import 'package:alpha_app/widgets/custom_nav_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class MainNavigationScreen extends StatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainNavigationScreen> createState() =>
      _MainNavigationScreenState();
}

class _MainNavigationScreenState
    extends State<MainNavigationScreen> {
  late int _currentIndex;

  bool _didCheckLostData = false;

  final List<Widget> _screens = const [
    HomeScreen(),
    ExpensesScreen(),
    ChatScreen(),
    MyGoalsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _currentIndex =
        widget.initialIndex.clamp(0, 4);

    WidgetsBinding.instance.addPostFrameCallback(
      (_) async {
        if (!mounted) {
          return;
        }

        final OnboardingProvider onboardingProvider =
            context.read<OnboardingProvider>();

        if (Platform.isAndroid &&
            !_didCheckLostData &&
            onboardingProvider.isOnboarded) {
          _didCheckLostData = true;

          try {
            final ImagePicker picker =
                ImagePicker();

            final LostDataResponse response =
                await picker.retrieveLostData();

            if (!mounted) {
              return;
            }

            if (response.exception != null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(
                      'main_navigation.image_recovery_failed'
                          .tr(
                        namedArgs: {
                          'message': response
                                  .exception
                                  ?.message ??
                              '',
                        },
                      ),
                    ),
                    behavior:
                        SnackBarBehavior.floating,
                  ),
                );

              return;
            }

            if (!response.isEmpty &&
                response.file != null) {
              final CycleProvider cycleProvider =
                  context.read<CycleProvider>();

              if (!cycleProvider.hasActiveCycle) {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(
                        'main_navigation.start_cycle_first'
                            .tr(),
                      ),
                      behavior:
                          SnackBarBehavior.floating,
                    ),
                  );

                return;
              }

              final File file =
                  File(response.file!.path);

              final bool fileExists =
                  await file.exists();

              if (!fileExists) {
                return;
              }

              final int fileLength =
                  await file.length();

              if (!mounted ||
                  fileLength <= 0) {
                return;
              }

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) =>
                      ReceiptInputScreen(
                    initialImage: file,
                  ),
                ),
              );
            }
          } catch (_) {
            // نتجاهل أخطاء استعادة الصورة حتى لا يتوقف التطبيق.
          }
        }
      },
    );
  }

  void _handleAccountNotVerified(
    BuildContext context,
  ) {
    final AuthProvider authProvider =
        context.read<AuthProvider>();

    final String phone =
        authProvider.currentUser?['phone']
                ?.toString() ??
            authProvider.localPhoneNumber;

    if (phone.isEmpty || !mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => OtpScreen(
          phoneNumber: phone,
          isRegistration: false,
        ),
      ),
    );
  }

  void _changePage(int index) {
    if (_currentIndex == index) {
      return;
    }

    final OnboardingProvider onboardingProvider =
        context.read<OnboardingProvider>();

    if (!onboardingProvider.isOnboarded &&
        (index == 1 ||
            index == 2 ||
            index == 3)) {
      requireOnboarding(context);
      return;
    }

    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
     final languageProvider = Provider.of<LanguageProvider>(context);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar:
          CustomBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _changePage,
      ),
    );
  }
}