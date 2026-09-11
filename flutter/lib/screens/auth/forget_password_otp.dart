import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/reset_password_screen.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class ForgetPasswordOtpScreen extends StatelessWidget {
  final String email;

  const ForgetPasswordOtpScreen({
    super.key,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final screenH = MediaQuery.of(context).size.height;

    final themeProvider = context.watch<Themeprovider>();
    final authProvider = context.watch<AuthProvider>();

    final isDark = themeProvider.isDark;

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

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle: GoogleFonts.ibmPlexSansArabic(
        fontSize: 22,
        color: textColor,
        fontWeight: FontWeight.bold,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            screenW * 0.06,
            screenH * 0.025,
            screenW * 0.06,
            MediaQuery.of(context).viewInsets.bottom +
                screenH * 0.035,
          ),
          child: Column(
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: InkWell(
                  onTap: authProvider.isLoading
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
              ),

              SizedBox(
                height: screenH * 0.035,
              ),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mark_email_read_outlined,
                  size: 48,
                  color: primaryColor,
                ),
              ),

              SizedBox(
                height: screenH * 0.035,
              ),

              Text(
                'forgot_password_otp.title'.tr(),
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: textColor,
                  fontSize: screenW * 0.07,
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(
                height: screenH * 0.012,
              ),

              Text(
                'forgot_password_otp.description'.tr(
  namedArgs: {
    'email': email,
  },
),
                textAlign: TextAlign.center,
                style: GoogleFonts.ibmPlexSansArabic(
                  color: subTextColor,
                  fontSize: screenW * 0.04,
                  height: 1.5,
                ),
              ),

              SizedBox(
                height: screenH * 0.04,
              ),

              Directionality(
                textDirection: Directionality.of(context),
                child: Pinput(
                  length: 6,

                  // نفس Controller الخاص بالباك.
                  controller: authProvider.otpController,

                  enabled: !authProvider.isLoading,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme:
                      defaultPinTheme.copyDecorationWith(
                    border: Border.all(
                      color: primaryColor,
                      width: 2,
                    ),
                  ),
                  submittedPinTheme: defaultPinTheme,
                  errorPinTheme:
                      defaultPinTheme.copyDecorationWith(
                    border: Border.all(
                      color: errorColor,
                      width: 2,
                    ),
                  ),
                  showCursor: true,

                  onCompleted: (pin) async {
                    if (authProvider.isLoading) {
                      return;
                    }

                    // نفس استدعاء الباك الأصلي.
                    final success =
                        await authProvider
                            .verifyPasswordResetOtp(
                      otpCode: pin,
                    );

                    if (success && context.mounted) {
                      // نفس الانتقال الأصلي.
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ResetPasswordScreen(
                            email: email,
                            otpCode: pin,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),

              if (authProvider.errorMessage != null) ...[
                SizedBox(
                  height: screenH * 0.025,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: errorColor.withOpacity(0.30),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 20,
                        color: errorColor,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Text(
                          authProvider.errorMessage!,
                          textAlign: TextAlign.start,
                          style:
                              GoogleFonts.ibmPlexSansArabic(
                            fontSize: 13,
                            color: errorColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(
                height: screenH * 0.05,
              ),

              AppButton(
               text: 'forgot_password_otp.verify'.tr(),
                isDark: isDark,
                isLoading: authProvider.isLoading,
                width: double.infinity,
                height: 56,
                onPressed: authProvider.isLoading
                    ? () {}
                    : () async {
                        // نفس قيمة الرمز الموجودة
                        // في Controller الخاص بالباك.
                        final otpCode =
                            authProvider.otpController.text;

                        // نفس استدعاء الباك الأصلي.
                        final success =
                            await authProvider
                                .verifyPasswordResetOtp(
                          otpCode: otpCode,
                        );

                        if (success &&
                            context.mounted) {
                          // نفس الانتقال الأصلي.
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ResetPasswordScreen(
                                email: email,
                                otpCode: otpCode,
                              ),
                            ),
                          );
                        }
                      },
              ),

              SizedBox(
                height: screenH * 0.035,
              ),
            ],
          ),
        ),
      ),
    );
  }
}