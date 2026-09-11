import 'dart:async';
import 'dart:io';

import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/dashboard_action_result.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/transactions/transaction_review_screen.dart';
import 'package:alpha_app/services/api_exception.dart';
import 'package:alpha_app/services/transaction_ai_service.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:record/record.dart';

class VoiceRecordScreen extends StatefulWidget {
  const VoiceRecordScreen({super.key});

  @override
  State<VoiceRecordScreen> createState() =>
      _VoiceRecordScreenState();
}

class _VoiceRecordScreenState extends State<VoiceRecordScreen>
    with SingleTickerProviderStateMixin {
  late final AudioRecorder _audioRecorder;
  late final AnimationController _pulseController;

  bool _isStarting = false;
  bool _isRecording = false;
  bool _isStopping = false;
  bool _isAnalyzing = false;
  bool _isNavigating = false;

  int _recordDuration = 0;
  Timer? _timer;
  String? _audioPath;

  final int _maxDurationSeconds = 60;

  @override
  void initState() {
    super.initState();

    _audioRecorder = AudioRecorder();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _startTimer() {
    _timer?.cancel();
    _recordDuration = 0;

    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (Timer timer) {
        if (!mounted) {
          return;
        }

        setState(() {
          _recordDuration++;
        });

        if (_recordDuration >= _maxDurationSeconds) {
          _stopRecording();
        }
      },
    );
  }

  String _formatDuration(int seconds) {
    final minutes =
        (seconds ~/ 60).toString().padLeft(2, '0');

    final remainingSeconds =
        (seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$remainingSeconds';
  }

  Future<void> _startRecording() async {
    if (_isStarting ||
        _isRecording ||
        _isStopping ||
        _isAnalyzing ||
        _isNavigating) {
      return;
    }

    setState(() {
      _isStarting = true;
    });

    try {
      final status =
          await Permission.microphone.request();

      if (status.isDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(
                'voice_record.microphone_permission_required'.tr(),
              ),
            ),
          );
        }

        setState(() {
          _isStarting = false;
        });

        return;
      }

      if (status.isPermanentlyDenied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'voice_record.microphone_permission_denied'.tr(),
              ),
              action: SnackBarAction(
                label: 'voice_record.open_settings'.tr(),
                onPressed: () {
                  openAppSettings();
                },
              ),
            ),
          );
        }

        setState(() {
          _isStarting = false;
        });

        return;
      }

      if (!await _audioRecorder.hasPermission()) {
        throw Exception(
          'Recorder permission not granted',
        );
      }

      final directory =
          await getTemporaryDirectory();

      final filePath =
          '${directory.path}/voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: filePath,
      );

      if (mounted) {
        setState(() {
          _isRecording = true;
          _audioPath = filePath;
        });

        _startTimer();
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'voice_record.unable_start_recording'.tr(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStarting = false;
        });
      }
    }
  }

  Future<void> _stopRecording() async {
    if (!_isRecording ||
        _isStopping ||
        _isAnalyzing ||
        _isNavigating) {
      return;
    }

    setState(() {
      _isStopping = true;
    });

    _timer?.cancel();

    try {
      final path = await _audioRecorder.stop();

      if (mounted) {
        setState(() {
          _isRecording = false;
        });
      }

      if (path == null || path.isEmpty) {
        throw Exception('Empty path');
      }

      final file = File(path);

      if (!await file.exists() ||
          await file.length() == 0 ||
          _recordDuration < 1) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
             SnackBar(
              content: Text(
                'voice_record.empty_recording'.tr(),
              ),
            ),
          );
        }

        await _deleteFile(path);
        return;
      }

      await _analyzeVoice(path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'voice_record.unable_analyze'.tr(),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isStopping = false;
        });
      }
    }
  }

  Future<void> _deleteFile(String? path) async {
    if (path == null) {
      return;
    }

    try {
      final file = File(path);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  Future<void> _cancelRecording() async {
    _timer?.cancel();

    try {
      await _audioRecorder.stop();
    } catch (_) {}

    await _deleteFile(_audioPath);

    setState(() {
      _isStarting = false;
      _isRecording = false;
      _isStopping = false;
      _isAnalyzing = false;
      _isNavigating = false;
      _recordDuration = 0;
      _audioPath = null;
    });
  }

  Future<void> _analyzeVoice(String path) async {
    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result =
          await TransactionAiService.analyzeVoice(
        path,
      );

      await _deleteFile(path);

      if (!mounted) {
        return;
      }

      if (result != null &&
          result.transactions.isNotEmpty) {
        setState(() {
          _isAnalyzing = false;
          _isNavigating = true;
        });

        await Future.delayed(Duration.zero);

        if (!mounted) {
          return;
        }

        debugPrint(
          'VOICE reviewNavigationStarted=true',
        );

        final navigationResult =
            await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) =>
                TransactionReviewScreen(
              transactions:
                  result.transactions,
              currentIndex: 0,
            ),
          ),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _isNavigating = false;
        });

        if (navigationResult ==
            DashboardActionResult.created) {
          Navigator.pop(
            context,
            DashboardActionResult.created,
          );
        }
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(
           SnackBar(
            content: Text(
              'voice_record.processing_failed'.tr(),
            ),
          ),
        );

        setState(() {
          _isAnalyzing = false;
        });
      }
    } catch (error) {
      await _deleteFile(path);

      if (mounted) {
        String message =
            'voice_record.unable_analyze'.tr();

        if (error is ApiException) {
          message = error.message ?? message;
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(message),
          ),
        );

        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        context.watch<Themeprovider>().isDark;

    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final cardColor = isDark
        ? AppColors.darkCard
        : AppColors.lightCard;

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

    final accentColor = isDark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    final errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final isBusy = _isStarting ||
        _isStopping ||
        _isAnalyzing ||
        _isNavigating;

    final progress =
        (_recordDuration / _maxDurationSeconds)
            .clamp(0.0, 1.0);

    return PopScope(
      canPop: !_isRecording &&
          !_isStopping &&
          !_isAnalyzing &&
          !_isNavigating,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Stack(
            children: [
              Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      screenW * 0.055,
                      screenH * 0.02,
                      screenW * 0.055,
                      screenH * 0.01,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                'voice_record.title'.tr(),
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color: textColor,
                                  fontSize:
                                      screenW * 0.065,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'voice_record.description'.tr(),
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color:
                                      subTextColor,
                                  fontSize:
                                      screenW * 0.032,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        InkWell(
                          onTap: isBusy ||
                                  _isRecording
                              ? null
                              : () {
                                  Navigator.pop(
                                    context,
                                  );
                                },
                          borderRadius:
                              BorderRadius.circular(
                            14,
                          ),
                          child: Container(
                            width: screenW * 0.115,
                            height: screenW * 0.115,
                            decoration:
                                BoxDecoration(
                              color: primaryColor
                                  .withOpacity(0.10),
                              borderRadius:
                                  BorderRadius
                                      .circular(14),
                              border: Border.all(
                                color: primaryColor
                                    .withOpacity(
                                  0.22,
                                ),
                              ),
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: isBusy ||
                                      _isRecording
                                  ? primaryColor
                                      .withOpacity(
                                      0.35,
                                    )
                                  : primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Expanded(
                    child: SingleChildScrollView(
                      physics:
                          const BouncingScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(
                        screenW * 0.055,
                        screenH * 0.025,
                        screenW * 0.055,
                        screenH * 0.03,
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(
                              18,
                            ),
                            decoration:
                                BoxDecoration(
                              color: cardColor,
                              borderRadius:
                                  BorderRadius
                                      .circular(22),
                              border: Border.all(
                                color: borderColor,
                              ),
                            ),
                            child: Column(
                              children: [
                                Stack(
                                  alignment:
                                      Alignment.center,
                                  children: [
                                    if (_isRecording)
                                      AnimatedBuilder(
                                        animation:
                                            _pulseController,
                                        builder: (
                                          context,
                                          child,
                                        ) {
                                          final size =
                                              screenW *
                                                      0.50 +
                                                  (_pulseController
                                                          .value *
                                                      screenW *
                                                      0.08);

                                          return Container(
                                            width: size,
                                            height:
                                                size,
                                            decoration:
                                                BoxDecoration(
                                              shape:
                                                  BoxShape
                                                      .circle,
                                              color:
                                                  errorColor
                                                      .withOpacity(
                                                0.08,
                                              ),
                                              border:
                                                  Border.all(
                                                color:
                                                    errorColor
                                                        .withOpacity(
                                                  0.18,
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    Container(
                                      width:
                                          screenW * 0.36,
                                      height:
                                          screenW * 0.36,
                                      decoration:
                                          BoxDecoration(
                                        shape:
                                            BoxShape.circle,
                                        gradient:
                                            LinearGradient(
                                          begin:
                                              Alignment
                                                  .topLeft,
                                          end: Alignment
                                              .bottomRight,
                                          colors:
                                              _isRecording
                                                  ? [
                                                      errorColor,
                                                      accentColor,
                                                    ]
                                                  : [
                                                      primaryColor,
                                                      secondaryColor,
                                                    ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: (_isRecording
                                                    ? errorColor
                                                    : primaryColor)
                                                .withOpacity(
                                              0.24,
                                            ),
                                            blurRadius:
                                                28,
                                            spreadRadius:
                                                3,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _isRecording
                                            ? Icons
                                                .graphic_eq_rounded
                                            : Icons
                                                .mic_rounded,
                                        color:
                                            Colors.white,
                                        size:
                                            screenW * 0.14,
                                      ),
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height:
                                      screenH * 0.035,
                                ),

                                Text(
                                  _formatDuration(
                                    _recordDuration,
                                  ),
                                  style: GoogleFonts
                                      .ibmPlexSansArabic(
                                    color: _isRecording
                                        ? errorColor
                                        : textColor,
                                    fontSize:
                                        screenW * 0.10,
                                    fontWeight:
                                        FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),

                                const SizedBox(
                                  height: 7,
                                ),

                                Text(
                                  _isRecording
                                      ? 'voice_record.recording'.tr()
                                      : 'voice_record.ready'.tr(),
                                  style: GoogleFonts
                                      .ibmPlexSansArabic(
                                    color: _isRecording
                                        ? errorColor
                                        : subTextColor,
                                    fontSize:
                                        screenW * 0.039,
                                    fontWeight:
                                        FontWeight.w600,
                                  ),
                                ),

                                const SizedBox(
                                  height: 16,
                                ),

                                ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(20),
                                  child:
                                      LinearProgressIndicator(
                                    value: progress,
                                    minHeight: 7,
                                    backgroundColor:
                                        borderColor,
                                    valueColor:
                                        AlwaysStoppedAnimation<
                                            Color>(
                                      _isRecording
                                          ? errorColor
                                          : primaryColor,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 8,
                                ),

                                Row(
                                  children: [
                                    Text(
                                      '00:00',
                                      style: GoogleFonts
                                          .ibmPlexSansArabic(
                                        color:
                                            subTextColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                    const Spacer(),
                                    Text(
                                      '01:00',
                                      style: GoogleFonts
                                          .ibmPlexSansArabic(
                                        color:
                                            subTextColor,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: screenH * 0.022,
                          ),

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(
                              15,
                            ),
                            decoration:
                                BoxDecoration(
                              color: secondaryColor
                                  .withOpacity(0.07),
                              borderRadius:
                                  BorderRadius
                                      .circular(16),
                              border: Border.all(
                                color: secondaryColor
                                    .withOpacity(0.22),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Icon(
                                  Icons
                                      .tips_and_updates_outlined,
                                  color:
                                      secondaryColor,
                                  size: 21,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    'voice_record.tip'.tr(),
                                    style: GoogleFonts
                                        .ibmPlexSansArabic(
                                      color:
                                          subTextColor,
                                      fontSize:
                                          screenW *
                                              0.031,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: screenH * 0.03,
                          ),

                          if (!_isRecording)
                            AppButton(
                              text: _isStarting
                                  ? 'voice_record.starting'.tr()
                                  : 'voice_record.start_recording'.tr(),
                              isDark: isDark,
                              isLoading:
                                  _isStarting,
                              width:
                                  double.infinity,
                              height: 56,
                              borderRadius: 14,
                              onPressed: isBusy
                                  ? null
                                  : _startRecording,
                            )
                          else
                            Row(
                              children: [
                                Expanded(
                                  child:
                                      OutlinedButton.icon(
                                    onPressed:
                                        (_isStopping ||
                                                _isNavigating)
                                            ? null
                                            : _cancelRecording,
                                    icon: const Icon(
                                      Icons
                                          .close_rounded,
                                    ),
                                    label:  Text(
                                      'voice_record.cancel'.tr(),
                                    ),
                                    style: OutlinedButton
                                        .styleFrom(
                                      minimumSize:
                                          const Size(
                                        0,
                                        55,
                                      ),
                                      foregroundColor:
                                          errorColor,
                                      side: BorderSide(
                                        color:
                                            errorColor,
                                      ),
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 12,
                                ),
                                Expanded(
                                  flex: 2,
                                  child:
                                      ElevatedButton.icon(
                                    onPressed:
                                        (_isStopping ||
                                                _isNavigating)
                                            ? null
                                            : _stopRecording,
                                    icon:
                                        _isStopping
                                            ? const SizedBox(
                                                width:
                                                    18,
                                                height:
                                                    18,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth:
                                                      2,
                                                  color:
                                                      Colors.white,
                                                ),
                                              )
                                            : const Icon(
                                                Icons
                                                    .stop_rounded,
                                              ),
                                    label: Text(
                                      _isStopping
                                          ? 'voice_record.stopping'.tr()
                                          : 'voice_record.stop_analyze'.tr(),
                                    ),
                                    style:
                                        ElevatedButton
                                            .styleFrom(
                                      minimumSize:
                                          const Size(
                                        0,
                                        55,
                                      ),
                                      elevation: 0,
                                      backgroundColor:
                                          errorColor,
                                      foregroundColor:
                                          Colors.white,
                                      shape:
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius
                                                .circular(
                                          14,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              if (_isAnalyzing)
                Positioned.fill(
                  child: Container(
                    color: Colors.black
                        .withOpacity(0.58),
                    alignment: Alignment.center,
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal:
                            screenW * 0.12,
                      ),
                      padding:
                          const EdgeInsets.all(
                        24,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius:
                            BorderRadius.circular(
                          22,
                        ),
                        border: Border.all(
                          color: secondaryColor
                              .withOpacity(0.25),
                        ),
                      ),
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 48,
                            height: 48,
                            child:
                                CircularProgressIndicator(
                              color:
                                  secondaryColor,
                              strokeWidth: 4,
                            ),
                          ),
                          const SizedBox(
                            height: 18,
                          ),
                          Text(
                            'voice_record.analyzing'.tr(),
                            textAlign:
                                TextAlign.center,
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              color: textColor,
                              fontSize:
                                  screenW * 0.045,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                          const SizedBox(
                            height: 7,
                          ),
                          Text(
                            'voice_record.analyzing_description'.tr(),
                            textAlign:
                                TextAlign.center,
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              color:
                                  subTextColor,
                              fontSize:
                                  screenW * 0.031,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
