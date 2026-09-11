import 'dart:io';

import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/dashboard_action_result.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/transactions/transaction_review_screen.dart';
import 'package:alpha_app/services/api_exception.dart';
import 'package:alpha_app/services/transaction_ai_service.dart';
import 'package:camera/camera.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ReceiptInputScreen extends StatefulWidget {
  final File? initialImage;

  const ReceiptInputScreen({
    super.key,
    this.initialImage,
  });

  @override
  State<ReceiptInputScreen> createState() =>
      _ReceiptInputScreenState();
}

class _ReceiptInputScreenState extends State<ReceiptInputScreen>
    with WidgetsBindingObserver {
  CameraController? _cameraController;
  bool _isInitializing = false;
  String? _cameraInitError;

  bool _isCapturing = false;
  bool _isPickingGallery = false;
  bool _isAnalyzing = false;
  bool _flashEnabled = false;

  File? _capturedImage;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    if (widget.initialImage != null) {
      _capturedImage = widget.initialImage;
      _analyzeImage(widget.initialImage!.path);
    } else {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(
    AppLifecycleState state,
  ) {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _cameraController = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) {
      return;
    }

    setState(() {
      _isInitializing = true;
      _cameraInitError = null;
    });

    try {
      final status = await Permission.camera.request();

      if (status.isPermanentlyDenied) {
        setState(() {
          _cameraInitError =
              'Camera permission was permanently denied. Open Settings to enable it.';
          _isInitializing = false;
        });

        return;
      }

      if (!status.isGranted) {
        setState(() {
          _cameraInitError =
              'Camera access is denied. Please enable it in Settings.';
          _isInitializing = false;
        });

        return;
      }

      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        setState(() {
          _cameraInitError =
              'No cameras found on this device.';
          _isInitializing = false;
        });

        return;
      }

      final backCamera = cameras.firstWhere(
        (camera) =>
            camera.lensDirection ==
            CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final oldController = _cameraController;
      _cameraController = null;
      await oldController?.dispose();

      final controller = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await controller.initialize();

      if (!mounted) {
        await controller.dispose();
        return;
      }

      await controller.setFlashMode(
        FlashMode.off,
      );

      setState(() {
        _cameraController = controller;
        _flashEnabled = false;
        _isInitializing = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }

      setState(() {
        _cameraInitError =
            'Unable to start the camera.';
        _isInitializing = false;
      });
    }
  }

  Future<void> _capturePhoto() async {
    if (_isCapturing ||
        _isAnalyzing ||
        _isPickingGallery) {
      return;
    }

    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    setState(() {
      _isCapturing = true;
    });

    try {
      final photo = await controller.takePicture();
      final imageFile = File(photo.path);

      final exists = await imageFile.exists();
      final length =
          exists ? await imageFile.length() : 0;

      if (!exists || length <= 0) {
        if (mounted) {
          _showError(
            'Failed to capture photo.',
          );
        }

        return;
      }

      if (mounted) {
        setState(() {
          _capturedImage = imageFile;
        });
      }

      await _analyzeImage(photo.path);
    } catch (_) {
      if (mounted) {
        _showError(
          'Failed to capture photo.',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCapturing = false;
        });
      }
    }
  }

  Future<void> _pickGalleryImage() async {
    if (_isPickingGallery ||
        _isCapturing ||
        _isAnalyzing) {
      return;
    }

    setState(() {
      _isPickingGallery = true;
    });

    try {
      final picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1280,
        maxHeight: 1280,
      );

      if (!mounted) {
        return;
      }

      if (picked == null) {
        return;
      }

      setState(() {
        _capturedImage = File(picked.path);
      });

      await _analyzeImage(picked.path);
    } catch (_) {
      if (!mounted) {
        return;
      }

      _showError(
        'Could not select image. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _isPickingGallery = false;
        });
      }
    }
  }

  Future<void> _analyzeImage(
    String imagePath,
  ) async {
    if (_isAnalyzing) {
      return;
    }

    final file = File(imagePath);
    final exists = await file.exists();

    if (!exists) {
      if (mounted) {
        _showError(
          'Could not read the image. Please try again.',
        );
      }

      return;
    }

    final length = await file.length();

    if (length <= 0) {
      if (mounted) {
        _showError(
          'The selected image appears to be empty. Please try again.',
        );
      }

      return;
    }

    setState(() {
      _isAnalyzing = true;
    });

    try {
      final result =
          await TransactionAiService.analyzeReceipt(
        file.path,
      );

      if (!mounted) {
        return;
      }

      if (result == null ||
          result.transactions.isEmpty) {
        setState(() {
          _isAnalyzing = false;
          _capturedImage = null;
        });

        await Future<void>.delayed(
          Duration.zero,
        );

        if (mounted) {
          _showError(
            'No transactions were found in the receipt.',
          );
        }

        return;
      }

      setState(() {
        _isAnalyzing = false;
        _capturedImage = null;
      });

      await Future<void>.delayed(
        Duration.zero,
      );

      if (!mounted) {
        return;
      }

      final actionResult =
          await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              TransactionReviewScreen(
            transactions: result.transactions,
            currentIndex: 0,
          ),
        ),
      );

      if (!mounted) {
        return;
      }

      if (actionResult ==
          DashboardActionResult.created) {
        Navigator.pop(
          context,
          DashboardActionResult.created,
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _capturedImage = null;
        });
      }

      await Future<void>.delayed(
        Duration.zero,
      );

      if (!mounted) {
        return;
      }

      if (error is ApiException) {
        _showError(error.message);
      } else {
        final errorText = error.toString();

        if (errorText.contains(
              'Unsupported response shape',
            ) ||
            errorText.contains(
              'Invalid transaction element format',
            ) ||
            errorText.contains(
              'ReceiptAnalysisContractException',
            )) {
          _showError(
            'The receipt analysis response could not be processed.',
          );
        } else {
          _showError(
            'Unable to analyze the receipt. Please try again.',
          );
        }
      }
    } finally {
      if (mounted && _isAnalyzing) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Future<void> _toggleFlash() async {
    final controller = _cameraController;

    if (controller == null ||
        !controller.value.isInitialized) {
      return;
    }

    final newValue = !_flashEnabled;

    try {
      await controller.setFlashMode(
        newValue
            ? FlashMode.torch
            : FlashMode.off,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _flashEnabled = newValue;
      });
    } on CameraException catch (error) {
      if (!mounted) {
        return;
      }

      _showError(
        error.description ??
            'Flash is unavailable.',
      );
    }
  }

  void _showError(
    String message,
  ) {
    if (message.isEmpty) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style:
                GoogleFonts.ibmPlexSansArabic(
              fontSize: 13,
            ),
          ),
          backgroundColor:
              AppColors.lightError,
          behavior:
              SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final isDark =
        context.watch<Themeprovider>().isDark;

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

    final accentColor = isDark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final isBusy = _isCapturing ||
        _isPickingGallery ||
        _isAnalyzing ||
        _isInitializing;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                22,
                18,
                22,
                36,
              ),
              child: Column(
                children: [
                  _ReceiptHeader(
                    isDark: isDark,
                    onClose: isBusy
                        ? null
                        : () {
                            Navigator.pop(context);
                          },
                  ),
                  const SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 0.95,
                    child: ClipRRect(
                      borderRadius:
                          BorderRadius.circular(
                        25,
                      ),
                      child: Container(
                        color: isDark
                            ? const Color(
                                0xFF071512,
                              )
                            : const Color(
                                0xFFE8F2EE,
                              ),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            _buildCameraPreview(
                              isDark,
                            ),
                            Container(
                              color: Colors.black
                                  .withOpacity(
                                0.08,
                              ),
                            ),
                            Center(
                              child: Container(
                                width: 175,
                                height: 270,
                                decoration:
                                    BoxDecoration(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    10,
                                  ),
                                  border:
                                      Border.all(
                                    color: Colors
                                        .white
                                        .withOpacity(
                                      0.60,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const Center(
                              child: _ScannerLine(),
                            ),
                            const Positioned(
                              top: 20,
                              left: 20,
                              child:
                                  _ScannerCorner(
                                top: true,
                                left: true,
                              ),
                            ),
                            const Positioned(
                              top: 20,
                              right: 20,
                              child:
                                  _ScannerCorner(
                                top: true,
                                left: false,
                              ),
                            ),
                            const Positioned(
                              bottom: 20,
                              left: 20,
                              child:
                                  _ScannerCorner(
                                top: false,
                                left: true,
                              ),
                            ),
                            const Positioned(
                              bottom: 20,
                              right: 20,
                              child:
                                  _ScannerCorner(
                                top: false,
                                left: false,
                              ),
                            ),
                            Positioned(
                              top: 14,
                              right: 14,
                              child: _FlashButton(
                                isEnabled:
                                    _flashEnabled,
                                onPressed: isBusy
                                    ? null
                                    : _toggleFlash,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'receipt_input.place_receipt'
                        .tr(),
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.ibmPlexSansArabic(
                      color: textColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'receipt_input.scan_hint'.tr(),
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.ibmPlexSansArabic(
                      color: subTextColor,
                      fontSize: 11.5,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    children: [
                      _SmallActionButton(
                        icon: Icons
                            .photo_library_outlined,
                        color: accentColor,
                        isDark: isDark,
                        enabled: !isBusy,
                        onPressed:
                            _pickGalleryImage,
                      ),
                      const SizedBox(width: 20),
                      _CaptureButton(
                        enabled: !isBusy &&
                            (_cameraController
                                    ?.value
                                    .isInitialized ??
                                false),
                        color: primaryColor,
                        onPressed:
                            _capturePhoto,
                      ),
                      const SizedBox(width: 20),
                      const SizedBox(
                        width: 52,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'receipt_input.input_methods'
                        .tr(),
                    textAlign: TextAlign.center,
                    style:
                        GoogleFonts.ibmPlexSansArabic(
                      color: subTextColor,
                      fontSize: 10,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          primaryColor.withOpacity(
                        0.06,
                      ),
                      borderRadius:
                          BorderRadius.circular(
                        15,
                      ),
                      border: Border.all(
                        color:
                            primaryColor.withOpacity(
                          0.18,
                        ),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons
                              .tips_and_updates_outlined,
                          color: primaryColor,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'receipt_input.capture_tip'
                                .tr(),
                            style: GoogleFonts
                                .ibmPlexSansArabic(
                              color: subTextColor,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_isAnalyzing)
              _ProcessingOverlay(
                isDark: isDark,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraPreview(
    bool isDark,
  ) {
    if (_cameraInitError != null) {
      return _CameraErrorView(
        error: _cameraInitError!,
        isDark: isDark,
        onRetry: _initializeCamera,
        onGallery:
            _pickGalleryImage,
      );
    }

    final capturedImage =
        _capturedImage;

    if (capturedImage != null) {
      return Image.file(
        capturedImage,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    if (_isInitializing ||
        _cameraController == null ||
        !_cameraController!
            .value
            .isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppColors.lightPrimary,
        ),
      );
    }

    return CameraPreview(
      _cameraController!,
    );
  }
}

class _ReceiptHeader extends StatelessWidget {
  final bool isDark;
  final VoidCallback? onClose;

  const _ReceiptHeader({
    required this.isDark,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Row(
      children: [
        Expanded(
          child: Text(
            'receipt_input.title'.tr(),
            style:
                GoogleFonts.ibmPlexSansArabic(
              color: isDark
                  ? AppColors.darkText
                  : AppColors.lightText,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius:
              BorderRadius.circular(14),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(
                isDark ? 0.10 : 0.07,
              ),
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color: primaryColor.withOpacity(
                  0.22,
                ),
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: onClose == null
                  ? primaryColor.withOpacity(
                      0.35,
                    )
                  : primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _SmallActionButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final bool isDark;
  final bool enabled;
  final VoidCallback onPressed;

  const _SmallActionButton({
    required this.icon,
    required this.color,
    required this.isDark,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      shape: const CircleBorder(),
      child: InkWell(
        onTap:
            enabled ? onPressed : null,
        customBorder:
            const CircleBorder(),
        child: Opacity(
          opacity: enabled ? 1 : 0.45,
          child: Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.darkCard
                  : AppColors.lightCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(
                  0.26,
                ),
              ),
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

class _CaptureButton extends StatelessWidget {
  final bool enabled;
  final Color color;
  final VoidCallback onPressed;

  const _CaptureButton({
    required this.enabled,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          enabled ? onPressed : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Container(
          width: 74,
          height: 74,
          padding:
              const EdgeInsets.all(5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 4,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 30,
            ),
          ),
        ),
      ),
    );
  }
}

class _FlashButton extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback? onPressed;

  const _FlashButton({
    required this.isEnabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.35),
      borderRadius:
          BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        borderRadius:
            BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            isEnabled
                ? Icons.flash_on_rounded
                : Icons.flash_off_rounded,
            color: isEnabled
                ? const Color(
                    0xFFF4C95D,
                  )
                : onPressed == null
                    ? Colors.white38
                    : Colors.white,
          ),
        ),
      ),
    );
  }
}

class _ScannerLine extends StatefulWidget {
  const _ScannerLine();

  @override
  State<_ScannerLine> createState() =>
      _ScannerLineState();
}

class _ScannerLineState extends State<_ScannerLine>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 2,
      ),
    );

    _animation = Tween<double>(
      begin: -105,
      end: 105,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    _controller.repeat(
      reverse: true,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (
        context,
        child,
      ) {
        return Transform.translate(
          offset: Offset(
            0,
            _animation.value,
          ),
          child: child,
        );
      },
      child: Container(
        height: 2,
        margin: const EdgeInsets.symmetric(
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: const Color(
            0xFF34D399,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(
                0xFF34D399,
              ).withOpacity(0.8),
              blurRadius: 13,
              spreadRadius: 2,
            ),
          ],
        ),
      ),
    );
  }
}

class _ScannerCorner extends StatelessWidget {
  final bool top;
  final bool left;

  const _ScannerCorner({
    required this.top,
    required this.left,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      height: 30,
      child: CustomPaint(
        painter: _ScannerCornerPainter(
          top: top,
          left: left,
        ),
      ),
    );
  }
}

class _ScannerCornerPainter
    extends CustomPainter {
  final bool top;
  final bool left;

  const _ScannerCornerPainter({
    required this.top,
    required this.left,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final paint = Paint()
      ..color = const Color(
        0xFF2BE4B0,
      )
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    if (top && left) {
      path
        ..moveTo(
          0,
          size.height,
        )
        ..lineTo(0, 0)
        ..lineTo(
          size.width,
          0,
        );
    } else if (top && !left) {
      path
        ..moveTo(0, 0)
        ..lineTo(
          size.width,
          0,
        )
        ..lineTo(
          size.width,
          size.height,
        );
    } else if (!top && left) {
      path
        ..moveTo(0, 0)
        ..lineTo(
          0,
          size.height,
        )
        ..lineTo(
          size.width,
          size.height,
        );
    } else {
      path
        ..moveTo(
          0,
          size.height,
        )
        ..lineTo(
          size.width,
          size.height,
        )
        ..lineTo(
          size.width,
          0,
        );
    }

    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter
        oldDelegate,
  ) {
    return false;
  }
}

class _CameraErrorView extends StatelessWidget {
  final String error;
  final bool isDark;
  final VoidCallback onRetry;
  final VoidCallback onGallery;

  const _CameraErrorView({
    required this.error,
    required this.isDark,
    required this.onRetry,
    required this.onGallery,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Container(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color:
                  AppColors.lightError,
              size: 42,
            ),
            const SizedBox(height: 12),
            Text(
              'receipt_input.camera_open_failed'
                  .tr(),
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.ibmPlexSansArabic(
                color: isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              error,
              textAlign: TextAlign.center,
              style:
                  GoogleFonts.ibmPlexSansArabic(
                color: isDark
                    ? AppColors.darkSubText
                    : AppColors.lightSubText,
                fontSize: 10,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 190,
              child: ElevatedButton(
                onPressed: onRetry,
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      primaryColor,
                  foregroundColor:
                      Colors.white,
                ),
                child: Text(
                  'common.try_again'.tr(),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: 190,
              child: OutlinedButton(
                onPressed: onGallery,
                child: Text(
                  'receipt_input.choose_gallery'
                      .tr(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProcessingOverlay extends StatelessWidget {
  final bool isDark;

  const _ProcessingOverlay({
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withOpacity(
          0.58,
        ),
        alignment: Alignment.center,
        child: Container(
          margin: const EdgeInsets.symmetric(
            horizontal: 46,
          ),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkCard
                : AppColors.lightCard,
            borderRadius:
                BorderRadius.circular(21),
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            children: [
              const CircularProgressIndicator(
                color:
                    AppColors.lightPrimary,
              ),
              const SizedBox(height: 15),
              Text(
                'receipt_input.analyzing_expense'
                    .tr(),
                textAlign: TextAlign.center,
                style:
                    GoogleFonts.ibmPlexSansArabic(
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.lightText,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
