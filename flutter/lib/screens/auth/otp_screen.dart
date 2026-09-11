import 'dart:async';

import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/step_resolver.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:provider/provider.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;
  final String? devOtpCode;
  final bool isRegistration;

  const OtpScreen({
    super.key,
    required this.phoneNumber,
    this.devOtpCode,
    this.isRegistration = false,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _pinController = TextEditingController();
  final _focusNode = FocusNode();

  int _secondsRemaining = 30;

  Timer? _timer;

  bool _isLoading = false;
  bool _isResending = false;
  bool _showDevCode = true;

  String? _errorMessage;
  String? _currentDevCode;

  String get _maskedPhone {
    final phone = widget.phoneNumber;

    if (phone.length <= 4) {
      return phone;
    }

    final lastFour = phone.substring(
      phone.length - 4,
    );

    return '${phone.substring(0, 3)}'
        '${'•' * (phone.length - 7)}'
        '$lastFour';
  }

  @override
  void initState() {
    super.initState();

    _currentDevCode = widget.devOtpCode;

    _startTimer();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _focusNode.requestFocus();
    });
  }

  void _startTimer() {
    setState(() {
      _secondsRemaining = 30;
    });

    _timer?.cancel();

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (!mounted) {
          return;
        }

        setState(() {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _timer?.cancel();
          }
        });
      },
    );
  }

  Future<void> _verifyOtp() async {
    final otpCode = _pinController.text.trim();

    if (otpCode.length != 6) {
      setState(() {
        _errorMessage =
            "otp.enter_full_code".tr();
      });

      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authProvider =
          context.read<AuthProvider>();

      final success =
          await authProvider.verifyPhoneOtp(
        otpCode: otpCode,
      );

      if (!mounted) {
        return;
      }

      if (!success) {
        setState(() {
          _errorMessage =
              authProvider.errorMessage ??
                  "otp.verification_failed".tr();
        });

        _pinController.clear();
        _focusNode.requestFocus();

        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              widget.isRegistration
                  ? "otp.account_verified".tr()
                  : "otp.verified".tr(),
              style:
                  GoogleFonts.ibmPlexSansArabic(),
            ),
            backgroundColor:
                const Color(0xFF0F766E),
            behavior:
                SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius:
                  BorderRadius.circular(10),
            ),
          ),
        );

      final onboardingProvider =
          context.read<OnboardingProvider>();

      final statusLoaded =
          await onboardingProvider
              .checkOnboardingStatus();

      if (!mounted) {
        return;
      }

      if (statusLoaded) {
        replaceWithOnboardingStep(
          context,
          onboardingProvider.nextStep,
          allocation:
              onboardingProvider.allocation,
        );
      } else {
        setState(() {
          _errorMessage =
              onboardingProvider.errorMessage ??
                  "otp.onboarding_failed".tr();
        });
      }
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _errorMessage = error
            .toString()
            .replaceFirst(
              'Exception: ',
              '',
            );
      });

      _pinController.clear();
      _focusNode.requestFocus();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_secondsRemaining > 0 ||
        _isResending) {
      return;
    }

    setState(() {
      _errorMessage =
          "otp.resend_unavailable".tr();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    _focusNode.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    final screenW =
        MediaQuery.of(context).size.width;

    final screenH =
        MediaQuery.of(context).size.height;

    final bgColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final accentColor = isDark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    final errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final pinTheme = PinTheme(
      width: 52,
      height: 60,
      textStyle:
          GoogleFonts.ibmPlexSansArabic(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius:
            BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
        ),
      ),
    );

    

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics:
              const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenW * 0.06,
            ),
            child: Column(
              children: [
                SizedBox(
                  height: screenH * 0.06,
                ),

               Align(
  alignment: AlignmentDirectional.centerStart,
  child: InkWell(
    onTap: _isLoading
        ? null
        : () {
            Navigator.pop(context);
          },
    borderRadius: BorderRadius.circular(13),
    child: Container(
      width: screenW * 0.12,
      height: screenW * 0.12,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkPrimary.withOpacity(0.10)
            : AppColors.lightPrimary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(13),
      ),
      child: Icon(
        Icons.arrow_back_rounded,
        color: isDark
            ? AppColors.darkPrimary
            : AppColors.lightPrimary,
        size: screenW * 0.07,
      ),
    ),
  ),
),

                const SizedBox(
                  height: 20,
                ),

                Container(
                  padding:
                      const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: primaryColor
                        .withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.mark_email_read_outlined,
                    size: 48,
                    color: primaryColor,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                Text(
                  "otp.title".tr(),
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.ibmPlexSansArabic(
                    fontSize: screenW * 0.07,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(
                  height: 12,
                ),

                Text(
                  "otp.description".tr(),
                  textAlign: TextAlign.center,
                  style:
                      GoogleFonts.ibmPlexSansArabic(
                    fontSize: screenW * 0.04,
                    color: subTextColor,
                    height: 1.5,
                  ),
                ),

                const SizedBox(
                  height: 32,
                ),

                if (_currentDevCode != null &&
                    _showDevCode) ...[
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor
                          .withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor
                            .withOpacity(0.30),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment
                                  .center,
                          children: [
                            Icon(
                              Icons.code,
                              size: 18,
                              color: accentColor,
                            ),

                            const SizedBox(
                              width: 8,
                            ),

                            Text(
                              "otp.dev_mode".tr(),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(
                                fontSize: 13,
                                fontWeight:
                                    FontWeight.w600,
                                color: accentColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(
                          height: 10,
                        ),

                        GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
                                  _pinController
                                          .text =
                                      _currentDevCode!;

                                  _focusNode
                                      .requestFocus();
                                },
                          child: Container(
                            padding:
                                const EdgeInsets
                                    .symmetric(
                              vertical: 10,
                              horizontal: 24,
                            ),
                            decoration:
                                BoxDecoration(
                              color: accentColor
                                  .withOpacity(0.15),
                              borderRadius:
                                  BorderRadius
                                      .circular(8),
                            ),
                            child: Text(
                              _currentDevCode!,
                              textDirection: Directionality.of(context),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                                color: accentColor,
                                letterSpacing: 6,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 8,
                        ),

                        Text(
                          "otp.tap_to_fill".tr(),
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            fontSize: 11,
                            color: subTextColor,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 24,
                  ),
                ],

                if (_errorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          errorColor.withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(10),
                      border: Border.all(
                        color: errorColor
                            .withOpacity(0.30),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 20,
                          color: errorColor,
                        ),

                        const SizedBox(
                          width: 10,
                        ),

                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              fontSize: 13,
                              color: errorColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),
                ],

                Directionality(
                  textDirection: Directionality.of(context),
                  child: Pinput(
                    controller: _pinController,
                    focusNode: _focusNode,
                    length: 6,
                    enabled: !_isLoading,
                    defaultPinTheme: pinTheme,
                    focusedPinTheme:
                        pinTheme.copyWith(
                      decoration:
                          pinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    errorPinTheme:
                        pinTheme.copyWith(
                      decoration:
                          pinTheme.decoration!.copyWith(
                        border: Border.all(
                          color: errorColor,
                          width: 2,
                        ),
                      ),
                    ),
                    onCompleted: (_) {
                      _verifyOtp();
                    },
                    onChanged: (_) {
                      if (_errorMessage != null) {
                        setState(() {
                          _errorMessage = null;
                        });
                      }
                    },
                  ),
                ),

                const SizedBox(
                  height: 24,
                ),

                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment:
                      WrapCrossAlignment.center,
                  children: [
                    Text(
                      "${"otp.didnt_receive".tr()} ",
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: subTextColor,
                        fontSize: 14,
                      ),
                    ),

                    GestureDetector(
                      onTap: _secondsRemaining == 0 &&
                              !_isResending &&
                              !_isLoading
                          ? _resendOtp
                          : null,
                      child: Text(
                        _isResending
                            ? "otp.sending".tr()
                            : _secondsRemaining > 0
                                ? "${"otp.resend_in".tr()} "
                                    "0:${_secondsRemaining.toString().padLeft(2, '0')}"
                                : "otp.resend".tr(),
                      textDirection: Directionality.of(context),
                        style: GoogleFonts
                            .ibmPlexSansArabic(
                          color:
                              _secondsRemaining ==
                                          0 &&
                                      !_isResending
                                  ? primaryColor
                                  : subTextColor,
                          fontWeight:
                              FontWeight.w600,
                          fontSize: 14,
                          decoration:
                              TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(
                  height: 48,
                ),

                AppButton(
                  text: "otp.verify".tr(),
                  isDark: isDark,
                  isLoading: _isLoading,
                  width: double.infinity,
                  height: 56,
                  onPressed: _verifyOtp,
                ),

                const SizedBox(
                  height: 32,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}