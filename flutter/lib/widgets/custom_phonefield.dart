import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class CustomPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;

  const CustomPhoneField({
    super.key,
    required this.controller,
    this.hint = "79XXXXXXX",
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final double screenW = Device.width(context);
    final double screenH = Device.height(context);

    final themeProvider = context.watch<Themeprovider>();

    final textColor = themeProvider.isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = themeProvider.isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final backgroundColor = themeProvider.isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final primaryColor = themeProvider.isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final errorColor = themeProvider.isDark
        ? AppColors.darkError
        : AppColors.lightError;

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.02,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: screenH * 0.08,
            padding: EdgeInsets.symmetric(
              horizontal: screenW * 0.02,
            ),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: enabled
                    ? subTextColor
                    : subTextColor.withOpacity(0.4),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "🇯🇴",
                  style: TextStyle(
                    fontSize: screenW * 0.055,
                  ),
                ),
                SizedBox(
                  width: screenW * 0.01,
                ),
                Text(
                  "+962",
                  style: TextStyle(
                    color: enabled
                        ? textColor
                        : textColor.withOpacity(0.5),
                    fontWeight: FontWeight.w600,
                    fontSize: screenW * 0.04,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(
            width: screenW * 0.02,
          ),

          Expanded(
            child: TextFormField(
              textDirection: TextDirection.ltr,
              controller: controller,
              enabled: enabled,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              inputFormatters: inputFormatters ??
                  [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
              onChanged: onChanged,
              validator: validator,
              style: TextStyle(
                color: textColor,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: subTextColor,
                ),
                prefixIcon: Icon(
                  Icons.phone,
                  color: subTextColor,
                  size: screenW * 0.06,
                ),
                filled: true,
                fillColor: backgroundColor,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: primaryColor,
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: subTextColor,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: errorColor,
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: errorColor,
                    width: 1.5,
                  ),
                ),
                disabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: subTextColor.withOpacity(0.4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}