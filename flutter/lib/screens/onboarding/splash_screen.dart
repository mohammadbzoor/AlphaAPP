import 'package:alpha_app/media/images.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/login.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/screens/main_screen.dart';
import 'package:alpha_app/screens/onboarding/onboarding_screen.dart';
import 'package:alpha_app/screens/home/home_screen.dart';
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    final double screenW =
        Device.width(context);

    final double screenH =
        Device.height(context);

    final Themeprovider themeProvider =
        context.watch<Themeprovider>();

    final bool isDark =
        themeProvider.isDark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment:
                  MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImagesAssets.logo,
                  width: screenW * 0.5,
                  height: screenH * 0.18,
                  fit: BoxFit.contain,
                ),

                SizedBox(
                  height: screenH * 0.03,
                ),

                Text(
                  'Alpha',
                  style:
                      GoogleFonts.ibmPlexSansArabic(
                    fontSize: screenW * 0.1,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? AppColors.darkText
                        : AppColors.lightText,
                  ),
                ),

                SizedBox(
                  height: screenH * 0.02,
                ),

                Text(
                  'onboarding.smart_financial_advisor'
                      .tr(),
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.ibmPlexSansArabic(
                    fontSize: screenW * 0.042,
                    color: isDark
                        ? AppColors.darkSubText
                        : AppColors.lightSubText,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: EdgeInsets.only(
              bottom: screenH * 0.1,
            ),
            child: Align(
              alignment:
                  Alignment.bottomCenter,
              child: CircularProgressIndicator(
                color: isDark
                    ? AppColors.darkPrimary
                    : AppColors.lightPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _checkAuthStatus() async {
    final AuthProvider authProvider =
        context.read<AuthProvider>();

    await Future.delayed(
      const Duration(seconds: 3),
    );

    if (!mounted) {
      return;
    }

    final bool hasSession =
        await authProvider.hasSavedSession();

    if (!mounted) {
      return;
    }

    // المستخدم مسجل دخول
    if (hasSession) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              MainNavigationScreen(),
        ),
      );

      return;
    }

    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    final bool hasSeenOnboarding =
        preferences.getBool(
              'has_seen_onboarding',
            ) ??
            false;

    if (!mounted) {
      return;
    }

    // شاهد الـOnboarding سابقًا ولكنه غير مسجل
    if (hasSeenOnboarding) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              const Login(),
        ),
      );

      return;
    }

    // أول مرة يستخدم التطبيق
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const OnboardingScreen(),
      ),
    );
  }

  Future<void> _clearSavedSession() async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();

    await preferences.remove(
      'access_token',
    );

    await preferences.remove(
      'refresh_token',
    );

    await preferences.remove(
      'token',
    );

    await preferences.remove(
      'remember_me',
    );

    await preferences.remove(
      'saved_phone',
    );
  }
}