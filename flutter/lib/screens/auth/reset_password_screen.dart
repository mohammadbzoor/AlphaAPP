import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/login.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otpCode;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otpCode,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  bool _obscureText = true;
  bool _obscureConfirmText = true;

  @override
  void dispose() {
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit(
    AuthProvider authProvider,
    BuildContext context,
  ) async {
    if (authProvider.isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();

    final String newPass = authProvider.newPasswordController.text.trim();

    final String confirmPass = _confirmPasswordController.text.trim();

    if (newPass.isEmpty || confirmPass.isEmpty) {
      _showMessage(
        context,
        message: 'reset_password.both_required'.tr(),
        isError: true,
      );

      return;
    }

    if (newPass != confirmPass) {
      _showMessage(
        context,
        message: 'reset_password.passwords_not_match'.tr(),
        isError: true,
      );

      return;
    }

    if (newPass.length < 8 ||
        !RegExp(r'[A-Z]').hasMatch(newPass) ||
        !RegExp(r'[a-z]').hasMatch(newPass) ||
        !RegExp(r'\d').hasMatch(newPass)) {
      _showMessage(
        context,
        message: 'reset_password.password_invalid'.tr(),
        isError: true,
      );

      return;
    }

    final bool success = await authProvider.resetPassword(
      otpCode: widget.otpCode,
      newPassword: newPass,
    );

    if (!context.mounted) {
      return;
    }

    if (success) {
      _showMessage(
        context,
        message: 'reset_password.reset_success'.tr(),
        isError: false,
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const Login(),
        ),
        (route) => false,
      );
    }
  }

  void _showMessage(
    BuildContext context, {
    required String message,
    required bool isError,
  }) {
    final Themeprovider themeProvider = context.read<Themeprovider>();

    final bool isDark = themeProvider.isDark;

    final Color errorColor =
        isDark ? AppColors.darkError : AppColors.lightError;

    final Color successColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: GoogleFonts.ibmPlexSansArabic(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: isError ? errorColor : successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.sizeOf(context);

    final double screenW = screenSize.width;

    final double screenH = screenSize.height;

    final Themeprovider themeProvider = context.watch<Themeprovider>();

    final AuthProvider authProvider = context.watch<AuthProvider>();

    final bool isDark = themeProvider.isDark;

    final Color backgroundColor =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;

    final Color textColor = isDark ? AppColors.darkText : AppColors.lightText;

    final Color subTextColor =
        isDark ? AppColors.darkSubText : AppColors.lightSubText;

    final Color primaryColor =
        isDark ? AppColors.darkPrimary : AppColors.lightPrimary;

    final Color secondaryColor =
        isDark ? AppColors.darkSecondary : AppColors.lightSecondary;

    final Color cardColor = isDark ? AppColors.darkCard : AppColors.lightCard;

    final Color borderColor =
        isDark ? AppColors.darkBorder : AppColors.lightBorder;

    final Color errorColor =
        isDark ? AppColors.darkError : AppColors.lightError;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            screenW * 0.06,
            screenH * 0.025,
            screenW * 0.06,
            MediaQuery.of(context).viewInsets.bottom + screenH * 0.04,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: InkWell(
                  onTap: authProvider.isLoading
                      ? null
                      : () {
                          Navigator.pop(context);
                        },
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: screenW * 0.12,
                    height: screenW * 0.12,
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(
                        isDark ? 0.12 : 0.08,
                      ),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: primaryColor.withOpacity(
                          0.22,
                        ),
                      ),
                    ),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: primaryColor,
                      size: screenW * 0.065,
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: screenH * 0.035,
              ),
              Center(
                child: Container(
                  width: screenW * 0.24,
                  height: screenW * 0.24,
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(
                      0.10,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(
                        0.25,
                      ),
                    ),
                  ),
                  child: Icon(
                    Icons.lock_reset_rounded,
                    color: primaryColor,
                    size: screenW * 0.12,
                  ),
                ),
              ),
              SizedBox(
                height: screenH * 0.032,
              ),
              Center(
                child: Text(
                  'reset_password.title'.tr(),
                  textAlign: TextAlign.center,
                  style: GoogleFonts.ibmPlexSansArabic(
                    color: textColor,
                    fontSize: screenW * 0.072,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ),
              SizedBox(
                height: screenH * 0.012,
              ),
              Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: screenW * 0.82,
                  ),
                  child: Text(
                    'reset_password.description'.tr(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.ibmPlexSansArabic(
                      color: subTextColor,
                      fontSize: screenW * 0.04,
                      fontWeight: FontWeight.w500,
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
                padding: EdgeInsets.fromLTRB(
                  screenW * 0.04,
                  screenH * 0.026,
                  screenW * 0.04,
                  screenH * 0.026,
                ),
                decoration: BoxDecoration(
                  color: primaryColor.withOpacity(
                    0.04,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: primaryColor.withOpacity(
                      0.55,
                    ),
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
                      title: 'reset_password.new_password'.tr(),
                      textColor: subTextColor,
                      screenW: screenW,
                    ),
                    SizedBox(
                      height: screenH * 0.01,
                    ),
                    _PasswordField(
                      controller: authProvider.newPasswordController,
                      hint: 'reset_password.enter_new_password'.tr(),
                      obscureText: _obscureText,
                      isLoading: authProvider.isLoading,
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                      onVisibilityPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    SizedBox(
                      height: screenH * 0.022,
                    ),
                    _FieldTitle(
                      title: 'reset_password.confirm_password'.tr(),
                      textColor: subTextColor,
                      screenW: screenW,
                    ),
                    SizedBox(
                      height: screenH * 0.01,
                    ),
                    _PasswordField(
                      controller: _confirmPasswordController,
                      hint: 'reset_password.confirm_new_password'.tr(),
                      obscureText: _obscureConfirmText,
                      isLoading: authProvider.isLoading,
                      cardColor: cardColor,
                      textColor: textColor,
                      subTextColor: subTextColor,
                      primaryColor: primaryColor,
                      secondaryColor: secondaryColor,
                      borderColor: borderColor,
                      onSubmitted: (_) {
                        _submit(
                          authProvider,
                          context,
                        );
                      },
                      onVisibilityPressed: () {
                        setState(() {
                          _obscureConfirmText = !_obscureConfirmText;
                        });
                      },
                    ),
                    SizedBox(
                      height: screenH * 0.02,
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(
                        14,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkAccent.withOpacity(
                                0.06,
                              )
                            : AppColors.lightAccent.withOpacity(
                                0.06,
                              ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkAccent
                              : AppColors.lightAccent,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: isDark
                                ? AppColors.darkAccent
                                : AppColors.lightAccent,
                            size: 20,
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child: Text(
                              'reset_password.password_hint'.tr(),
                              style: GoogleFonts.ibmPlexSansArabic(
                                color: isDark
                                    ? AppColors.darkAccent
                                    : AppColors.lightAccent,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (authProvider.errorMessage != null) ...[
                      SizedBox(
                        height: screenH * 0.018,
                      ),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 12,
                          horizontal: 14,
                        ),
                        decoration: BoxDecoration(
                          color: errorColor.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          border: Border.all(
                            color: errorColor.withOpacity(0.30),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                                style: GoogleFonts.ibmPlexSansArabic(
                                  color: errorColor,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              SizedBox(
                height: screenH * 0.04,
              ),
              AppButton(
                text: 'reset_password.button'.tr(),
                isDark: isDark,
                isLoading: authProvider.isLoading,
                width: double.infinity,
                height: 56,
                onPressed: () {
                  _submit(
                    authProvider,
                    context,
                  );
                },
              ),
              SizedBox(
                height: screenH * 0.025,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldTitle extends StatelessWidget {
  final String title;
  final Color textColor;
  final double screenW;

  const _FieldTitle({
    required this.title,
    required this.textColor,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsDirectional.only(
        start: screenW * 0.01,
      ),
      child: Text(
        title,
        style: GoogleFonts.ibmPlexSansArabic(
          color: textColor,
          fontSize: screenW * 0.038,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final bool isLoading;

  final Color cardColor;
  final Color textColor;
  final Color subTextColor;
  final Color primaryColor;
  final Color secondaryColor;
  final Color borderColor;

  final VoidCallback onVisibilityPressed;
  final ValueChanged<String>? onSubmitted;

  const _PasswordField({
    required this.controller,
    required this.hint,
    required this.obscureText,
    required this.isLoading,
    required this.cardColor,
    required this.textColor,
    required this.subTextColor,
    required this.primaryColor,
    required this.secondaryColor,
    required this.borderColor,
    required this.onVisibilityPressed,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      enabled: !isLoading,
      keyboardType: TextInputType.visiblePassword,
      textInputAction:
          onSubmitted == null ? TextInputAction.next : TextInputAction.done,
      onSubmitted: onSubmitted,
      style: GoogleFonts.ibmPlexSansArabic(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        filled: true,
        fillColor: cardColor,
        hintText: hint,
        hintStyle: GoogleFonts.ibmPlexSansArabic(
          color: subTextColor,
          fontSize: 14,
        ),
        prefixIcon: Icon(
          Icons.lock_outline_rounded,
          color: secondaryColor,
        ),
        suffixIcon: IconButton(
          onPressed: isLoading ? null : onVisibilityPressed,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: secondaryColor,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 18,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: borderColor,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: borderColor.withOpacity(0.6),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: primaryColor,
            width: 2,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}
