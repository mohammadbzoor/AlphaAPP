import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/media/images.dart';
import 'package:alpha_app/providers/chatbot_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/ai_assistant/voice_chat_screen.dart';
import 'package:alpha_app/widgets/chat/chat_bubble.dart';
import 'package:alpha_app/widgets/chat/chat_input.dart';
import 'package:alpha_app/widgets/chat/suggestion_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    super.key,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController =
      ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    Future.delayed(
      const Duration(milliseconds: 150),
      () {
        if (scrollController.hasClients) {
          scrollController.animateTo(
            scrollController
                .position
                .maxScrollExtent,
            duration:
                const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      },
    );
  }

  String _translateSuggestion(
    String suggestion,
  ) {
    switch (suggestion) {
      case 'How can I save money?':
        return 'suggestions.save_money'.tr();

      case 'Analyze my expenses':
        return 'suggestions.analyze_expenses'.tr();

      case 'Create saving plan':
        return 'suggestions.create_plan'.tr();

      case 'Reduce my spending':
        return 'suggestions.reduce_spending'.tr();

      default:
        return suggestion;
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatbotProvider =
        context.watch<ChatbotProvider>();

    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final themeProvider =
        context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    WidgetsBinding.instance
        .addPostFrameCallback((_) {
      scrollToBottom();
    });

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenW * 0.05,
          ),
          child: Column(
            children: [
              SizedBox(
                height: screenH * 0.03,
              ),

              Row(
                children: [
                  Image.asset(
                    ImagesAssets.logo,
                    height: screenH * 0.05,
                    width: screenW * 0.1,
                  ),

                  SizedBox(
                    width: screenW * 0.02,
                  ),

                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alpha',
                        style: GoogleFonts
                            .ibmPlexSansArabic(
                          color: isDark
                              ? AppColors.darkText
                              : AppColors.lightText,
                          fontSize:
                              screenW * 0.055,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      Text(
                        'chat.online_now'.tr(),
                        style: TextStyle(
                          color: isDark
                              ? AppColors
                                  .darkSecondary
                              : AppColors
                                  .lightSecondary,
                          fontSize:
                              screenW * 0.035,
                          fontWeight:
                              FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(
                height: screenH * 0.03,
              ),

              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior
                          .onDrag,
                  itemCount:
                      chatbotProvider.messages.length,
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    return ChatBubble(
                      message: chatbotProvider
                          .messages[index],
                    );
                  },
                ),
              ),

              SizedBox(
                height: screenH * 0.02,
              ),

              SizedBox(
                height: screenH * 0.06,
                child: ListView.separated(
                  scrollDirection:
                      Axis.horizontal,
                  physics:
                      const BouncingScrollPhysics(),
                  itemCount: chatbotProvider
                      .suggestions.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(width: 10),
                  itemBuilder: (
                    context,
                    index,
                  ) {
                    final String originalSuggestion =
                        chatbotProvider
                            .suggestions[index];

                    final String displayedSuggestion =
                        _translateSuggestion(
                      originalSuggestion,
                    );

                    return SuggestionChipWidget(
                      text: displayedSuggestion,
                      onTap: () {
                        chatbotProvider
                            .sendSuggestion(
                          originalSuggestion,
                        );

                        scrollToBottom();
                      },
                    );
                  },
                ),
              ),

              SizedBox(
                height: screenH * 0.02,
              ),

              Padding(
                padding: EdgeInsets.only(
                  bottom: screenH * 0.02,
                ),
                child: ChatInput(
                  controller: chatbotProvider
                      .messageController,

                  isLoading:
                      chatbotProvider.isLoading,

                  onSend: (value) {
                    chatbotProvider
                        .sendMessage(value);

                    scrollToBottom();
                  },

                  onVoice: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const VoiceChatScreen(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
