import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/login.dart';
import 'package:alpha_app/screens/auth/otp_screen.dart';
import 'package:alpha_app/screens/auth/terms_screen.dart';
import 'package:alpha_app/screens/profile/birth_date_screen.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:alpha_app/widgets/custom_phonefield.dart';
import 'package:alpha_app/widgets/custom_textfield.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({
    super.key,
  });

  @override
  State<CreateAccount> createState() =>
      _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _formKey = GlobalKey<FormState>();

  bool _acceptedTerms = false;
  bool _showTermsError = false;

  // يمنع إرسال أكثر من طلب إنشاء حساب عند الضغط المتكرر.
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      context.read<AuthProvider>().clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);

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

    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    final isLoading =
        authProvider.isLoading || _isNavigating;

    return Form(
      key: _formKey,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              screenW * 0.055,
              24,
              screenW * 0.055,
              30,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "create_account.welcome".tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: screenW * 0.038,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? AppColors.darkAccent
                        : AppColors.lightAccent,
                  ),
                ),

                SizedBox(
                  height: screenH * 0.012,
                ),

                Text(
                  "create_account.title".tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: screenW * 0.078,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    height: 1.15,
                  ),
                ),

                SizedBox(
                  height: screenH * 0.01,
                ),

                Text(
                  "create_account.description".tr(),
                  style: GoogleFonts.ibmPlexSansArabic(
                    fontSize: screenW * 0.038,
                    fontWeight: FontWeight.w500,
                    color: subTextColor,
                    height: 1.55,
                  ),
                ),

                SizedBox(
                  height: screenH * 0.028,
                ),

                Container(
                  width: double.infinity,
                  padding: EdgeInsets.fromLTRB(
                    screenW * 0.025,
                    screenH * 0.025,
                    screenW * 0.025,
                    screenH * 0.022,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(
                      color: primaryColor,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      _FieldTitle(
                        title:
                            "create_account.full_name".tr(),
                        isDark: isDark,
                        screenW: screenW,
                      ),

                      SizedBox(
                        height: screenH * 0.009,
                      ),

                      CustomTextfield(
                        controller:
                            authProvider.nameController,
                        hint:
                            "create_account.enter_full_name"
                                .tr(),
                        type: TextFieldType.name,
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          final name =
                              value?.trim() ?? "";

                          if (name.isEmpty) {
                            return "create_account.name_required"
                                .tr();
                          }

                          if (name.length < 2) {
                            return "create_account.name_invalid"
                                .tr();
                          }

                          return null;
                        },
                      ),

                      SizedBox(
                        height: screenH * 0.018,
                      ),

                      _FieldTitle(
                        title:
                            "create_account.phone_number"
                                .tr(),
                        isDark: isDark,
                        screenW: screenW,
                      ),

                      SizedBox(
                        height: screenH * 0.009,
                      ),

                      CustomPhoneField(
                        controller:
                            authProvider.phoneController,
                        validator: (value) {
                          final phone =
                              value?.trim() ?? "";

                          if (phone.isEmpty) {
                            return "create_account.phone_required"
                                .tr();
                          }

                          if (phone.length != 9 ||
                              !phone.startsWith("7")) {
                            return "create_account.phone_invalid"
                                .tr();
                          }

                          return null;
                        },
                      ),

                      SizedBox(
                        height: screenH * 0.018,
                      ),

                      _FieldTitle(
                        title:
                            "create_account.email".tr(),
                        isDark: isDark,
                        screenW: screenW,
                      ),

                      SizedBox(
                        height: screenH * 0.009,
                      ),

                      CustomTextfield(
                        controller:
                            authProvider.emailController,
                        hint:
                            "create_account.enter_email"
                                .tr(),
                        type: TextFieldType.email,
                        icon: Icons.email_outlined,
                        validator: (value) {
                          final email =
                              value?.trim() ?? "";

                          if (email.isEmpty) {
                            return "create_account.email_required"
                                .tr();
                          }

                          final emailRegex = RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          );

                          if (!emailRegex.hasMatch(email)) {
                            return "create_account.email_invalid"
                                .tr();
                          }

                          return null;
                        },
                      ),

                      SizedBox(
                        height: screenH * 0.018,
                      ),

                      _FieldTitle(
                        title:
                            "create_account.birth_date".tr(),
                        isDark: isDark,
                        screenW: screenW,
                      ),

                      SizedBox(
                        height: screenH * 0.009,
                      ),

                      CustomTextfield(
                        controller:
                            authProvider.birthDateController,
                        hint:
                            "create_account.select_birth_date"
                                .tr(),
                        icon:
                            Icons.calendar_month_outlined,
                        type: TextFieldType.date,
                        readOnly: true,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return "create_account.birth_date_required"
                                .tr();
                          }

                          return null;
                        },
                        onTap: isLoading
                            ? null
                            : () async {
                                final date =
                                    await Navigator.push<
                                        DateTime>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        BirthDateScreen(
                                      initialDate:
                                          authProvider
                                              .birthDate,
                                    ),
                                  ),
                                );

                                if (!mounted) {
                                  return;
                                }

                                if (date != null) {
                                  authProvider.setBirthDate(
                                    date,
                                  );
                                }
                              },
                      ),

                      SizedBox(
                        height: screenH * 0.018,
                      ),

                      _FieldTitle(
                        title:
                            "create_account.password".tr(),
                        isDark: isDark,
                        screenW: screenW,
                      ),

                      SizedBox(
                        height: screenH * 0.009,
                      ),

                      CustomTextfield(
                        controller:
                            authProvider.passwordController,
                        hint:
                            "create_account.password_hint"
                                .tr(),
                        icon: Icons.lock_outline_rounded,
                        type: TextFieldType.password,
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty) {
                            return "validation.password_required"
                                .tr();
                          }

                          if (value.length < 8) {
                            return "create_account.password_length"
                                .tr();
                          }

                          if (!RegExp(
                            r'(?=.*[a-z])',
                          ).hasMatch(value)) {
                            return "create_account.password_lower"
                                .tr();
                          }

                          if (!RegExp(
                            r'(?=.*[A-Z])',
                          ).hasMatch(value)) {
                            return "create_account.password_upper"
                                .tr();
                          }

                          if (!RegExp(
                            r'(?=.*\d)',
                          ).hasMatch(value)) {
                            return "create_account.password_number"
                                .tr();
                          }

                          return null;
                        },
                      ),

                      SizedBox(
                        height: screenH * 0.016,
                      ),

                      Divider(
                        color: borderColor,
                        height: 1,
                      ),

                      SizedBox(
                        height: screenH * 0.012,
                      ),

                      InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                authProvider
                                    .toggleRemember();
                              },
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                authProvider.rememberMe
                                    ? Icons
                                        .check_box_rounded
                                    : Icons
                                        .check_box_outline_blank_rounded,
                                color: secondaryColor,
                                size: screenW * 0.056,
                              ),

                              SizedBox(
                                width: screenW * 0.02,
                              ),

                              Expanded(
                                child: Text(
                                  "remember_me".tr(),
                                  style: GoogleFonts
                                      .ibmPlexSansArabic(
                                    fontSize:
                                        screenW * 0.037,
                                    fontWeight:
                                        FontWeight.w600,
                                    color: subTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height: screenH * 0.008,
                      ),

                      Divider(
                        color: borderColor,
                        height: 1,
                      ),

                      SizedBox(
                        height: screenH * 0.012,
                      ),

                      InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _acceptedTerms =
                                      !_acceptedTerms;

                                  if (_acceptedTerms) {
                                    _showTermsError =
                                        false;
                                  }
                                });
                              },
                        borderRadius:
                            BorderRadius.circular(12),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            vertical: 6,
                          ),
                          child: Row(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Icon(
                                _acceptedTerms
                                    ? Icons
                                        .check_box_rounded
                                    : Icons
                                        .check_box_outline_blank_rounded,
                                color: _showTermsError
                                    ? errorColor
                                    : secondaryColor,
                                size: screenW * 0.056,
                              ),

                              SizedBox(
                                width: screenW * 0.02,
                              ),

                              Expanded(
                                child: Wrap(
                                  crossAxisAlignment:
                                      WrapCrossAlignment
                                          .center,
                                  children: [
                                    Text(
                                      "create_account.agree"
                                          .tr(),
                                      style: GoogleFonts
                                          .ibmPlexSansArabic(
                                        color:
                                            subTextColor,
                                        fontSize:
                                            screenW *
                                                0.034,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              Navigator
                                                  .push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const TermsScreen(),
                                                ),
                                              );
                                            },
                                      child: Text(
                                        "create_account.terms"
                                            .tr(),
                                        style: GoogleFonts
                                            .ibmPlexSansArabic(
                                          color:
                                              secondaryColor,
                                          fontSize:
                                              screenW *
                                                  0.034,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          decoration:
                                              TextDecoration
                                                  .underline,
                                          decorationColor:
                                              secondaryColor,
                                        ),
                                      ),
                                    ),

                                    Text(
                                      "create_account.and"
                                          .tr(),
                                      style: GoogleFonts
                                          .ibmPlexSansArabic(
                                        color:
                                            subTextColor,
                                        fontSize:
                                            screenW *
                                                0.034,
                                        fontWeight:
                                            FontWeight
                                                .w500,
                                      ),
                                    ),

                                    GestureDetector(
                                      onTap: isLoading
                                          ? null
                                          : () {
                                              Navigator
                                                  .push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      const TermsScreen(),
                                                ),
                                              );
                                            },
                                      child: Text(
                                        "create_account.privacy"
                                            .tr(),
                                        style: GoogleFonts
                                            .ibmPlexSansArabic(
                                          color:
                                              secondaryColor,
                                          fontSize:
                                              screenW *
                                                  0.034,
                                          fontWeight:
                                              FontWeight
                                                  .bold,
                                          decoration:
                                              TextDecoration
                                                  .underline,
                                          decorationColor:
                                              secondaryColor,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      if (_showTermsError)
                        Padding(
                          padding: EdgeInsets.only(
                            left: screenW * 0.075,
                            top: 5,
                          ),
                          child: Text(
                            "create_account.terms_required"
                                .tr(),
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              color: errorColor,
                              fontSize:
                                  screenW * 0.031,
                              fontWeight:
                                  FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenH * 0.028,
                ),

                AppButton(
                  text:
                      "create_account.create_account"
                          .tr(),
                  isDark: isDark,
                  isLoading: isLoading,
                  width: double.infinity,
                  height: screenH * 0.065,
                  onPressed: () async {
                    FocusScope.of(context).unfocus();

                    if (isLoading) {
                      return;
                    }

                    final isFormValid =
                        _formKey.currentState
                                ?.validate() ??
                            false;

                    if (!isFormValid) {
                      return;
                    }

                    // فحص إضافي مهم لأن الباك يعتمد
                    // على قيمة birthDate وليس النص فقط.
                    if (authProvider.birthDate == null) {
                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              "create_account.birth_date_required"
                                  .tr(),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(),
                            ),
                            backgroundColor:
                                errorColor,
                            behavior:
                                SnackBarBehavior.floating,
                          ),
                        );

                      return;
                    }

                    if (!_acceptedTerms) {
                      setState(() {
                        _showTermsError = true;
                      });

                      return;
                    }

                    setState(() {
                      _isNavigating = true;
                    });

                    try {
                      // منطق الباك الأساسي لإنشاء الحساب
                      // وإرسال رمز التحقق.
                      final success =
                          await authProvider
                              .createAccountAndSendOtp();

                      if (!mounted) {
                        return;
                      }

                      if (!success) {
                        ScaffoldMessenger.of(context)
                          ..hideCurrentSnackBar()
                          ..showSnackBar(
                            SnackBar(
                              content: Text(
                                authProvider
                                        .errorMessage ??
                                    "create_account.account_failed"
                                        .tr(),
                                style: GoogleFonts
                                    .ibmPlexSansArabic(),
                              ),
                              backgroundColor:
                                  errorColor,
                              behavior:
                                  SnackBarBehavior
                                      .floating,
                            ),
                          );

                        return;
                      }

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          SnackBar(
                            content: Text(
                              "create_account.verification_sent"
                                  .tr(),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(),
                            ),
                            backgroundColor:
                                secondaryColor,
                            behavior:
                                SnackBarBehavior.floating,
                          ),
                        );

                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => OtpScreen(
                            phoneNumber: authProvider
                                .fullPhoneNumber,
                            isRegistration: true,
                          ),
                        ),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isNavigating = false;
                        });
                      }
                    }
                  },
                ),

                SizedBox(
                  height: screenH * 0.016,
                ),

                // زر سند تجريبي فقط، لا يستدعي الباك.
                OutlinedButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          ScaffoldMessenger.of(context)
                            ..hideCurrentSnackBar()
                            ..showSnackBar(
                              SnackBar(
                                content: Text(
                                  "تسجيل الدخول بواسطة سند سيكون متاحًا قريبًا",
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
                        },
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size(
                      double.infinity,
                      screenH * 0.065,
                    ),
                    foregroundColor: secondaryColor,
                    backgroundColor: backgroundColor,
                    disabledForegroundColor:
                        subTextColor.withOpacity(0.5),
                    side: BorderSide(
                      color: isLoading
                          ? borderColor
                          : secondaryColor,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.verified_user_outlined,
                        size: screenW * 0.055,
                      ),

                      SizedBox(
                        width: screenW * 0.025,
                      ),

                      Text(
                        "تسجيل الدخول بواسطة سند",
                        style: GoogleFonts
                            .ibmPlexSansArabic(
                          fontSize:
                              screenW * 0.041,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenH * 0.026,
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.06),
                    borderRadius:
                        BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          primaryColor.withOpacity(0.22),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          "create_account.already_have_account"
                              .tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            color: subTextColor,
                            fontSize:
                                screenW * 0.038,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),

                      SizedBox(
                        width: screenW * 0.015,
                      ),

                      InkWell(
                        onTap: isLoading
                            ? null
                            : () {
                                Navigator
                                    .pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const Login(),
                                  ),
                                );
                              },
                        borderRadius:
                            BorderRadius.circular(8),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            "create_account.sign_in"
                                .tr(),
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              color: secondaryColor,
                              fontSize:
                                  screenW * 0.042,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(
                  height: screenH * 0.02,
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