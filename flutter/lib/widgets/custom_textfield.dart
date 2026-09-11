import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

enum TextFieldType {
  name,
  email,
  phone,
  password,
  date,
  number,
}

class CustomTextfield extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final IconData? icon;
  final TextFieldType type;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  final bool enabled;
  final VoidCallback? onTap;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;

  const CustomTextfield({
    super.key,
    required this.controller,
    required this.hint,
    required this.type,
    this.icon,
    this.suffix,
    this.validator,
    this.onChanged,
    this.enabled = true,
    this.onTap,
    this.readOnly = false,
    this.inputFormatters,
  });

  @override
  State<CustomTextfield> createState() =>
      _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield> {
  bool isSecure = true;

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final themeProvider = context.watch<Themeprovider>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenW * 0.02,
      ),
      child: TextFormField(
        controller: widget.controller,
        onTap: widget.onTap,
        readOnly: widget.readOnly,
        enabled: widget.enabled,
        validator: widget.validator,
        onChanged: widget.onChanged,
        keyboardType: _keyboardType(),
        inputFormatters: widget.inputFormatters,
        textInputAction: widget.readOnly
            ? TextInputAction.done
            : TextInputAction.next,
        obscureText:
            widget.type == TextFieldType.password
                ? isSecure
                : false,
        style: TextStyle(
          color: themeProvider.isDark
              ? AppColors.darkText
              : AppColors.lightText,
        ),
        decoration: InputDecoration(
          hintText: widget.hint,
          hintStyle: TextStyle(
            color: themeProvider.isDark
                ? AppColors.darkSubText
                : AppColors.lightSubText,
          ),
          prefixIcon: widget.icon != null
              ? Icon(
                  widget.icon,
                  size: screenW * 0.06,
                  color: themeProvider.isDark
                      ? AppColors.darkSubText
                      : AppColors.lightSubText,
                )
              : null,
          suffixIcon:
              widget.type == TextFieldType.password
                  ? IconButton(
                      onPressed: () {
                        setState(() {
                          isSecure = !isSecure;
                        });
                      },
                      icon: Icon(
                        isSecure
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: themeProvider.isDark
                            ? AppColors.darkSubText
                            : AppColors.lightSubText,
                      ),
                    )
                  : widget.suffix,
          filled: true,
          fillColor: themeProvider.isDark
              ? AppColors.darkBackground
              : AppColors.lightBackground,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.isDark
                  ? AppColors.darkSubText
                  : AppColors.lightSubText,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.isDark
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              width: 1.5,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.isDark
                  ? AppColors.darkError
                  : AppColors.lightError,
              width: 1.5,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.isDark
                  ? AppColors.darkError
                  : AppColors.lightError,
              width: 1.5,
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: themeProvider.isDark
                  ? AppColors.darkSubText.withOpacity(0.4)
                  : AppColors.lightSubText.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }

  TextInputType _keyboardType() {
    switch (widget.type) {
      case TextFieldType.email:
        return TextInputType.emailAddress;

      case TextFieldType.phone:
        return TextInputType.phone;

      case TextFieldType.date:
        return TextInputType.datetime;

      case TextFieldType.name:
        return TextInputType.name;

      case TextFieldType.password:
        return TextInputType.visiblePassword;

      case TextFieldType.number:
        return TextInputType.number;
    }
  }
}