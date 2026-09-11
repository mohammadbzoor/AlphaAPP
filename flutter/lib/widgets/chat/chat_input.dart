import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onSend;
  final VoidCallback onVoice;
  final bool isLoading;

  const ChatInput({
    super.key,
    required this.controller,
    required this.onSend,
    required this.onVoice,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider =
        context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBorder
            : AppColors.lightBorder,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              enabled: !isLoading,
              textInputAction: TextInputAction.send,
              onSubmitted: isLoading
                  ? null
                  : (value) {
                      onSend(value);
                    },
              style: TextStyle(
                color: isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
                fontWeight: FontWeight.w400,
              ),
              decoration: InputDecoration(
                hintText: context.tr(
                  'chat.input_hint',
                ),
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkSubText
                      : AppColors.lightSubText,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed:
                isLoading ? null : onVoice,
            icon: Icon(
              Icons.mic,
              color: isLoading
                  ? secondaryColor.withOpacity(0.4)
                  : secondaryColor,
            ),
          ),
          IconButton(
            onPressed: isLoading
                ? null
                : () {
                    onSend(controller.text);
                  },
            icon: isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child:
                        CircularProgressIndicator(
                      strokeWidth: 2,
                      color: secondaryColor,
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: secondaryColor,
                  ),
          ),
        ],
      ),
    );
  }
}