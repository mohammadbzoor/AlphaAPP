
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/chatbot_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/chat_model.dart';

class ChatBubble extends StatelessWidget {
  final ChatModel message;

  const ChatBubble({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);

    final themeProvider =
        context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Align(
      alignment: message.isUser
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 11,
        ),
        constraints: BoxConstraints(
          maxWidth: screenW * 0.78,
        ),
        decoration: BoxDecoration(
          color: message.isUser
              ? primaryColor.withOpacity(
                  isDark ? 0.18 : 0.12,
                )
              : cardColor,
          borderRadius: BorderRadiusDirectional.only(
            topStart: const Radius.circular(17),
            topEnd: const Radius.circular(17),
            bottomStart: message.isUser
                ? const Radius.circular(17)
                : Radius.zero,
            bottomEnd: message.isUser
                ? Radius.zero
                : const Radius.circular(17),
          ),
          border: Border.all(
            color: message.isUser
                ? primaryColor.withOpacity(0.35)
                : borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              _getDisplayMessage(message.message),
              textAlign: TextAlign.start,
              style: TextStyle(
                color: message.isUser
                    ? primaryColor
                    : textColor,
                fontSize: screenW * 0.04,
                fontWeight: FontWeight.w500,
                height: 1.45,
              ),
            ),

            const SizedBox(height: 8),

            Align(
              alignment:
                  AlignmentDirectional.centerEnd,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${message.time.hour.toString().padLeft(2, '0')}:'
                    '${message.time.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      color: subTextColor,
                      fontSize: screenW * 0.028,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  if (message.isUser &&
                      message.isPending) ...[
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: primaryColor,
                      ),
                    ),
                  ],

                  if (message.isUser &&
                      message.isFailed) ...[
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        final chatbotProvider =
                            context.read<
                                ChatbotProvider>();

                        chatbotProvider
                            .retryMessage(message);
                      },
                      child: Icon(
                        Icons.refresh_rounded,
                        color: isDark
                            ? AppColors.darkError
                            : AppColors.lightError,
                        size: 17,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDisplayMessage(String rawMessage) {
    if (rawMessage.isEmpty) return '';
    if (rawMessage.contains(' ') || rawMessage.contains('\n')) {
      return rawMessage;
    }
    try {
      final String trValue = rawMessage.tr();
      return trValue;
    } catch (_) {
      return rawMessage;
    }
  }
}

