import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/forget_password_otp.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:alpha_app/widgets/custom_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({
    super.key,
  });

  @override
  State<ForgetPasswordScreen> createState() =>
      _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState
    extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final themeProvider =
        context.watch<Themeprovider>();

    final authProvider =
        context.watch<AuthProvider>();

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

    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

    return Form(
      key: _formKey,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .onDrag,
                padding: EdgeInsets.fromLTRB(
                  screenW * 0.055,
                  screenH * 0.025,
                  screenW * 0.055,
                  screenH * 0.035 +
                      keyboardHeight,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight -
                            screenH * 0.06,
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment:
                            AlignmentDirectional
                                .centerStart,
                        child: InkWell(
                          onTap:
                              authProvider.isLoading
                                  ? null
                                  : () {
                                      Navigator.pop(
                                        context,
                                      );
                                    },
                          borderRadius:
                              BorderRadius.circular(
                            13,
                          ),
                          child: Container(
                            width: screenW * 0.12,
                            height: screenW * 0.12,
                            decoration:
                                BoxDecoration(
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
                      ),

                      SizedBox(
                        height: screenH * 0.045,
                      ),

                      Center(
                        child: Container(
                          width: screenW * 0.22,
                          height: screenW * 0.22,
                          decoration:
                              BoxDecoration(
                            color: primaryColor
                                .withOpacity(0.10),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: primaryColor
                                  .withOpacity(0.25),
                            ),
                          ),
                          child: Icon(
                            Icons.lock_reset_rounded,
                            color: primaryColor,
                            size: screenW * 0.105,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenH * 0.035,
                      ),

                      Center(
                        child: Text(
                          "forgot_password.title"
                              .tr(),
                          textAlign:
                              TextAlign.center,
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            color: textColor,
                            fontSize:
                                screenW * 0.075,
                            fontWeight:
                                FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenH * 0.012,
                      ),

                      Center(
                        child: ConstrainedBox(
                          constraints:
                              BoxConstraints(
                            maxWidth:
                                screenW * 0.85,
                          ),
                          child: Text(
                            "forgot_password.description"
                                .tr(),
                            textAlign:
                                TextAlign.center,
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              color: subTextColor,
                              fontSize:
                                  screenW * 0.039,
                              fontWeight:
                                  FontWeight.w500,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenH * 0.04,
                      ),

                      Container(
                        width: double.infinity,
                        padding:
                            EdgeInsets.symmetric(
                          horizontal:
                              screenW * 0.025,
                          vertical:
                              screenH * 0.024,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor
                              .withOpacity(0.04),
                          borderRadius:
                              BorderRadius.circular(
                            26,
                          ),
                          border: Border.all(
                            color: primaryColor,
                          ),
                          boxShadow: isDark
                              ? null
                              : [
                                  BoxShadow(
                                    color: Colors.black
                                        .withOpacity(
                                      0.035,
                                    ),
                                    blurRadius: 20,
                                    offset:
                                        const Offset(
                                      0,
                                      8,
                                    ),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Padding(
                              padding:
                                  EdgeInsets.symmetric(
                                horizontal:
                                    screenW * 0.02,
                              ),
                              child: Text(
                                "forgot_password.email"
                                    .tr(),
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color:
                                      subTextColor,
                                  fontSize:
                                      screenW * 0.04,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            SizedBox(
                              height:
                                  screenH * 0.01,
                            ),

                            CustomTextfield(
                              controller:
                                  authProvider
                                      .emailController,
                              hint:
                                  "forgot_password.email_hint"
                                      .tr(),
                              type:
                                  TextFieldType.email,
                              icon: Icons
                                  .email_outlined,
                              enabled:
                                  !authProvider
                                      .isLoading,
                              validator: (value) {
                                final email =
                                    value?.trim() ??
                                        "";

                                if (email.isEmpty) {
                                  return "forgot_password.email_required"
                                      .tr();
                                }

                                final emailRegex =
                                    RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                );

                                if (!emailRegex
                                    .hasMatch(email)) {
                                  return "forgot_password.email_invalid"
                                      .tr();
                                }

                                return null;
                              },
                            ),

                            if (authProvider
                                    .errorMessage !=
                                null) ...[
                              SizedBox(
                                height:
                                    screenH *
                                        0.014,
                              ),
                              Padding(
                                padding: EdgeInsets
                                    .symmetric(
                                  horizontal:
                                      screenW * 0.02,
                                ),
                                child: Container(
                                  width:
                                      double.infinity,
                                  padding:
                                      const EdgeInsets
                                          .symmetric(
                                    horizontal: 14,
                                    vertical: 11,
                                  ),
                                  decoration:
                                      BoxDecoration(
                                    color: errorColor
                                        .withOpacity(
                                      0.10,
                                    ),
                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                      12,
                                    ),
                                    border:
                                        Border.all(
                                      color: errorColor
                                          .withOpacity(
                                        0.30,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Icon(
                                        Icons
                                            .error_outline_rounded,
                                        color:
                                            errorColor,
                                        size:
                                            screenW *
                                                0.05,
                                      ),

                                      SizedBox(
                                        width:
                                            screenW *
                                                0.02,
                                      ),

                                      Expanded(
                                        child: Text(
                                          authProvider
                                              .errorMessage!,
                                          style: GoogleFonts
                                              .ibmPlexSansArabic(
                                            color:
                                                errorColor,
                                            fontSize:
                                                screenW *
                                                    0.033,
                                            fontWeight:
                                                FontWeight
                                                    .w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      SizedBox(
                        height: screenH * 0.035,
                      ),

                      AppButton(
                        text:
                            "forgot_password.send_code"
                                .tr(),
                        isDark: isDark,
                        isLoading:
                            authProvider.isLoading,
                        width: double.infinity,
                        height: screenH * 0.065,
                        onPressed: () async {
                          FocusScope.of(context)
                              .unfocus();

                          if (authProvider
                              .isLoading) {
                            return;
                          }

                          final isValid =
                              _formKey.currentState
                                      ?.validate() ??
                                  false;

                          if (!isValid) {
                            return;
                          }

                          // نفس استدعاء الباك.
                          final success =
                              await authProvider
                                  .sendPasswordResetOtp();

                          if (!context.mounted) {
                            return;
                          }

                          if (!success) {
                            return;
                          }

                          ScaffoldMessenger.of(
                            context,
                          )
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  "forgot_password.code_sent"
                                      .tr(),
                                  style: GoogleFonts
                                      .ibmPlexSansArabic(),
                                ),
                                backgroundColor:
                                    secondaryColor,
                                behavior:
                                    SnackBarBehavior
                                        .floating,
                              ),
                            );

                          // نفس الانتقال ونفس قيمة
                          // الإيميل المعتمدة في الباك.
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  ForgetPasswordOtpScreen(
                                email:
                                    authProvider.email,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(
                        height: screenH * 0.025,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}