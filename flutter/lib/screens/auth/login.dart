import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/core/utils/step_resolver.dart';
import 'package:alpha_app/media/images.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/create_account.dart';
import 'package:alpha_app/screens/auth/forget_password_screen.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:alpha_app/widgets/custom_phonefield.dart';
import 'package:alpha_app/widgets/custom_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class Login extends StatefulWidget {
  const Login({
    super.key,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final themeProvider = context.watch<Themeprovider>();
    final authProvider = context.watch<AuthProvider>();
    final onboardingProvider = context.watch<OnboardingProvider>();

    final isDark = themeProvider.isDark;

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor =
        isDark ? AppColors.darkSubText : AppColors.lightSubText;

    final primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final secondaryColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    final borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final isLoading =
        authProvider.isLoading || onboardingProvider.isLoading;

    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              screenW * 0.055,
              20,
              screenW * 0.055,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: screenH * 0.015,
                ),

                Center(
                  child: Container(
                    width: screenW * 0.22,
                    height: screenW * 0.22,
                    padding: EdgeInsets.all(
                      screenW * 0.032,
                    ),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: primaryColor.withOpacity(0.28),
                      ),
                    ),
                    child: Image.asset(
                      ImagesAssets.logo,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                SizedBox(
                  height: screenH * 0.028,
                ),

                Center(
                  child: Text(
                    "login.welcome_back".tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSansArabic(
                      fontSize: screenW * 0.078,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                      height: 1.15,
                    ),
                  ),
                ),

                SizedBox(
                  height: screenH * 0.01,
                ),

                Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: screenW * 0.82,
                    ),
                    child: Text(
                      "login.description".tr(),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.ibmPlexSansArabic(
                        fontSize: screenW * 0.038,
                        fontWeight: FontWeight.w500,
                        color: subTextColor,
                        height: 1.55,
                      ),
                    ),
                  ),
                ),

                SizedBox(
                  height: screenH * 0.035,
                ),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    screenW * 0.025,
                    screenH * 0.025,
                    screenW * 0.025,
                    screenH * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: primaryColor,
                    ),
                    boxShadow: isDark
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.035),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _FieldTitle(
                        title: "login.phone_number".tr(),
                        isDark: isDark,
                        screenW: screenW,
                      ),

                      SizedBox(
                        height: screenH * 0.01,
                      ),

                      CustomPhoneField(
                        controller: authProvider.phoneController,
                        validator: (value) {
                          final phone = value?.trim() ?? '';

                          if (phone.isEmpty) {
                            return "login.phone_required".tr();
                          }

                          if (phone.length != 9 ||
                              !phone.startsWith("7")) {
                            return "login.phone_invalid".tr();
                          }

                          return null;
                        },
                      ),

                      SizedBox(
                        height: screenH * 0.022,
                      ),

                      _FieldTitle(
                        title: "login.password".tr(),
                        isDark: isDark,
                        screenW: screenW,
                      ),

                      SizedBox(
                        height: screenH * 0.01,
                      ),

                      CustomTextfield(
                        controller: authProvider.passwordController,
                        hint: "login.password_hint".tr(),
                        icon: Icons.lock_outline_rounded,
                        type: TextFieldType.password,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "validation.password_required".tr();
                          }

                          if (value.length < 8) {
                            return "validation.password_short".tr();
                          }

                          return null;
                        },
                      ),

                      SizedBox(
                        height: screenH * 0.012,
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenW * 0.02,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: isLoading
                                    ? null
                                    : () {
                                        authProvider.toggleRemember();
                                      },
                                borderRadius: BorderRadius.circular(10),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        authProvider.rememberMe
                                            ? Icons.check_box_rounded
                                            : Icons
                                                .check_box_outline_blank_rounded,
                                        color: secondaryColor,
                                        size: screenW * 0.055,
                                      ),

                                      SizedBox(
                                        width: screenW * 0.02,
                                      ),

                                      Flexible(
                                        child: Text(
                                          "remember_me".tr(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style:
                                              GoogleFonts.ibmPlexSansArabic(
                                            fontSize: screenW * 0.036,
                                            fontWeight: FontWeight.w600,
                                            color: subTextColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                            TextButton(
                              onPressed: isLoading
                                  ? null
                                  : () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const ForgetPasswordScreen(),
                                        ),
                                      );
                                    },
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "forgot_password_title".tr(),
                                style: GoogleFonts.ibmPlexSansArabic(
                                  color: secondaryColor,
                                  fontSize: screenW * 0.035,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenH * 0.035,
                ),

                AppButton(
                  text: "login.login".tr(),
                  isDark: isDark,
                  isLoading: isLoading,
                  width: double.infinity,
                  height: screenH * 0.065,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (isLoading) {
                      return;
                    }

                    if (!(_formKey.currentState?.validate() ?? false)) {
                      return;
                    }

                    final success =
                        await context.read<AuthProvider>().loginUser();

                    if (!context.mounted) {
                      return;
                    }

                    if (!success) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              context
                                      .read<AuthProvider>()
                                      .errorMessage ??
                                  "login.invalid_credentials".tr(),
                              style:
                                  GoogleFonts.ibmPlexSansArabic(),
                            ),
                            backgroundColor: isDark
                                ? AppColors.darkError
                                : AppColors.lightError,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                      return;
                    }

                    final onboarding =
                        context.read<OnboardingProvider>();

                    final statusLoaded =
                        await onboarding.checkOnboardingStatus();

                    if (!context.mounted) {
                      return;
                    }

                    if (statusLoaded) {
                      replaceWithOnboardingStep(
                        context,
                        onboarding.nextStep,
                        allocation: onboarding.allocation,
                      );

                      return;
                    }

                    ScaffoldMessenger.of(context)
                      ..hideCurrentSnackBar()
                      ..showSnackBar(
                        SnackBar(
                          content: Text(
                            onboarding.errorMessage ??
                                "Could not load onboarding status",
                            style:
                                GoogleFonts.ibmPlexSansArabic(),
                          ),
                          backgroundColor: isDark
                              ? AppColors.darkError
                              : AppColors.lightError,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                  },
                ),

                SizedBox(
                  height: screenH * 0.04,
                ),

                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: borderColor,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenW * 0.035,
                      ),
                      child: Text(
                        "OR",
                        style: GoogleFonts.ibmPlexSansArabic(
                          color: subTextColor,
                          fontSize: screenW * 0.032,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: borderColor,
                      ),
                    ),
                  ],
                ),

                SizedBox(
                  height: screenH * 0.028,
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: primaryColor.withOpacity(0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "no_account".tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize: screenW * 0.038,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: screenW * 0.018,
                      ),

                      InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const CreateAccount(),
                                  ),
                                );
                              },
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            "sign_up".tr(),
                            style: GoogleFonts.ibmPlexSansArabic(
                              color: secondaryColor,
                              fontSize: screenW * 0.042,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenH * 0.03,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  final double screenW;

  const _FieldTitle({
    required this.title,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.02,
      ),
      child: Text(
        title,
        style: GoogleFonts.ibmPlexSansArabic(
          fontSize: screenW * 0.04,
          color: isDark
              ? AppColors.darkSubText
              : AppColors.lightSubText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}