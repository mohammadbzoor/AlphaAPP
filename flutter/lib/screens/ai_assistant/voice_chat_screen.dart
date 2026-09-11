import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/chatbot_provider.dart';

class VoiceChatScreen extends StatefulWidget {
  const VoiceChatScreen({
    super.key,
  });

  @override
  State<VoiceChatScreen> createState() =>
      _VoiceChatScreenState();
}

class _VoiceChatScreenState extends State<VoiceChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ChatbotProvider chatbotProvider =
        context.watch<ChatbotProvider>();

    final double screenW =
        Device.width(context);

    final double screenH =
        Device.height(context);

    final Themeprovider themeProvider =
        context.watch<Themeprovider>();

    final bool isDark =
        themeProvider.isDark;

    return PopScope(
      onPopInvokedWithResult: (
        didPop,
        result,
      ) {
        if (didPop) {
          chatbotProvider.stopListening();
        }
      },
      child: Scaffold(
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

                Align(
                  alignment:
                      AlignmentDirectional.topStart,
                  child: IconButton(
                    onPressed: () {
                      chatbotProvider.stopListening();

                      Navigator.pop(context);
                    },
                    icon: Icon(
                      Icons.close,
                      color: isDark
                          ? AppColors.darkSubText
                          : AppColors.lightSubText,
                    ),
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics:
                        const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        SizedBox(
                          height: screenH * 0.03,
                        ),

                        Text(
                          'voice.title'.tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                            fontSize:
                                screenW * 0.08,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(
                          height: screenH * 0.05,
                        ),

                        Stack(
                          alignment: Alignment.center,
                          children: [
                            if (chatbotProvider
                                .isListening)
                              AnimatedBuilder(
                                animation:
                                    animationController,
                                builder: (
                                  context,
                                  child,
                                ) {
                                  return Container(
                                    width: 220 +
                                        animationController
                                                .value *
                                            30,
                                    height: 220 +
                                        animationController
                                                .value *
                                            30,
                                    decoration:
                                        BoxDecoration(
                                      shape:
                                          BoxShape.circle,
                                      color: isDark
                                          ? AppColors
                                              .darkPrimary
                                              .withOpacity(
                                                0.3,
                                              )
                                          : AppColors
                                              .lightPrimary
                                              .withOpacity(
                                                0.3,
                                              ),
                                    ),
                                  );
                                },
                              ),

                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isDark
                                    ? AppColors.darkPrimary
                                    : AppColors
                                        .lightPrimary,
                              ),
                              child: IconButton(
                                onPressed: () {
                                  chatbotProvider
                                          .isListening
                                      ? chatbotProvider
                                          .stopListening()
                                      : chatbotProvider
                                          .startListening();
                                },
                                icon: Icon(
                                  chatbotProvider
                                          .isListening
                                      ? Icons.graphic_eq
                                      : Icons.mic,
                                  color: Colors.white,
                                  size: 60,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: screenH * 0.05,
                        ),

                        Text(
                          chatbotProvider.isListening
                              ? 'voice.listening'.tr()
                              : 'voice.tap_microphone'
                                  .tr(),
                          textAlign: TextAlign.center,
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            fontSize:
                                screenW * 0.05,
                            fontWeight:
                                FontWeight.w500,
                            color: isDark
                                ? AppColors.darkSubText
                                : AppColors
                                    .lightSubText,
                          ),
                        ),

                        SizedBox(
                          height: screenH * 0.05,
                        ),

                        Container(
                          width: screenW * 0.8,
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 15,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                            borderRadius:
                                BorderRadius.circular(
                              15,
                            ),
                          ),
                          child: TextField(
                            controller: chatbotProvider
                                .voiceController,
                            minLines: 1,
                            maxLines: 5,
                            onChanged: (val) {
                              chatbotProvider.updateVoiceText(val);
                            },
                            style: TextStyle(
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                              fontWeight:
                                  FontWeight.w400,
                            ),
                            decoration: InputDecoration(
                              hintText:
                                  'voice.message_hint'
                                      .tr(),
                              hintStyle: TextStyle(
                                color: isDark
                                    ? AppColors
                                        .darkSubText
                                    : AppColors
                                        .lightSubText,
                              ),
                              border:
                                  InputBorder.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(
                  height: screenH * 0.03,
                ),

                Padding(
                  padding: EdgeInsets.only(
                    bottom: screenH * 0.02,
                  ),
                  child: ElevatedButton(
                    onPressed:
                        chatbotProvider.voiceController.text.trim().isEmpty
                            ? null
                            : () {
                                chatbotProvider
                                    .sendMessage(
                                  chatbotProvider
                                      .voiceController
                                      .text
                                      .trim(),
                                );

                                chatbotProvider
                                    .clearVoice();

                                chatbotProvider
                                    .stopListening();

                                Navigator.pop(
                                  context,
                                );
                              },
                    style: ButtonStyle(
                      backgroundColor:
                          WidgetStatePropertyAll(
                        isDark
                            ? AppColors.darkPrimary
                            : AppColors
                                .lightPrimary,
                      ),
                      fixedSize:
                          WidgetStatePropertyAll(
                        Size(
                          screenW * 0.8,
                          screenH * 0.065,
                        ),
                      ),
                      shape:
                          WidgetStatePropertyAll(
                        RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),
                    ),
                    child: Text(
                      'voice.send'.tr(),
                      style: TextStyle(
                        fontSize:
                            screenW * 0.055,
                        color: AppColors.darkBorder,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}