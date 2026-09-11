import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/login.dart';
import 'package:alpha_app/screens/onboarding/PageView/boarding_one.dart';
import 'package:alpha_app/screens/onboarding/PageView/boarding_three.dart';
import 'package:alpha_app/screens/onboarding/PageView/boarding_two.dart';
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
  });

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const Login(),
      ),
    );
  }

  void _goToNextPage() {
    _controller.nextPage(
      duration: const Duration(
        milliseconds: 300,
      ),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenW = Device.width(context);
    final double screenH = Device.height(context);

    final themeProvider =
        context.watch<Themeprovider>();

    final bool isDark = themeProvider.isDark;

    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final Color buttonTextColor = isDark
        ? AppColors.darkBackground
        : Colors.white;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * 0.05,
          ),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _controller,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  children: const [
                    BoardingOne(),
                    BoardingTwo(),
                    BoardingThree(),
                  ],
                ),
              ),

              SmoothPageIndicator(
                controller: _controller,
                count: 3,
                effect: ExpandingDotsEffect(
                  activeDotColor: isDark
                      ? AppColors.darkAccent
                      : AppColors.lightAccent,
                  dotColor: isDark
                      ? AppColors.darkBorder
                      : AppColors.lightBorder,
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3,
                  spacing: 6,
                ),
              ),

              SizedBox(
                height: screenH * 0.05,
              ),

              if (currentPage == 2)
                SizedBox(
                  width: screenW * 0.8,
                  height: screenH * 0.06,
                  child: ElevatedButton(
                    onPressed: _goToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: buttonTextColor,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'onboarding.get_started'.tr(),
                      style: TextStyle(
                        fontSize: screenW * 0.052,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    TextButton(
                      onPressed: _goToLogin,
                      child: Text(
                        'onboarding.skip'.tr(),
                        style: TextStyle(
                          color: isDark
                              ? AppColors.darkSubText
                              : AppColors.lightSubText,
                          fontWeight: FontWeight.w500,
                          fontSize: screenW * 0.042,
                        ),
                      ),
                    ),

                    SizedBox(
                      width: screenW * 0.025,
                    ),

                    Expanded(
                      child: SizedBox(
                        height: screenH * 0.065,
                        child: ElevatedButton(
                          onPressed: _goToNextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor:
                                buttonTextColor,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'onboarding.next'.tr(),
                            style: TextStyle(
                              fontSize: screenW * 0.052,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              SizedBox(
                height: screenH * 0.03,
              ),
            ],
          ),
        ),
      ),
    );
  }
}