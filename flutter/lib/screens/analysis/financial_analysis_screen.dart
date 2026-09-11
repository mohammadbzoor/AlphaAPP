import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/models/financial_analysis_model.dart';
import 'package:alpha_app/providers/financial_analysis_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class FinancialAnalysisScreen extends StatefulWidget {
  final bool autoPlayAudio;

  const FinancialAnalysisScreen({
    super.key,
    this.autoPlayAudio = true,
  });

  @override
  State<FinancialAnalysisScreen> createState() =>
      _FinancialAnalysisScreenState();
}

class _FinancialAnalysisScreenState extends State<FinancialAnalysisScreen> {
  bool _didAutoPlay = false;
  bool _autoPlayScheduled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_autoPlayScheduled) {
      return;
    }

    _autoPlayScheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) {
        return;
      }

      final provider =
          context.read<FinancialAnalysisProvider>();

      await _tryAutoPlay(provider);
    });
  }

  Future<void> _tryAutoPlay(
    FinancialAnalysisProvider provider,
  ) async {
    if (!mounted ||
        !widget.autoPlayAudio ||
        _didAutoPlay ||
        !provider.hasAnalysis ||
        !provider.hasAudio ||
        provider.isPlaying ||
        provider.isAudioLoading) {
      return;
    }

    _didAutoPlay = true;

    try {
      await provider.toggleAudio();
    } catch (_) {
      _didAutoPlay = false;
    }
  }

  Future<void> _closeScreen(
    FinancialAnalysisProvider provider,
  ) async {
    await provider.stopAudio();

    if (!mounted) {
      return;
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final analysisProvider =
        context.watch<FinancialAnalysisProvider>();

    final themeProvider =
        context.watch<Themeprovider>();

    final bool isDark = themeProvider.isDark;
    final double screenW = Device.width(context);
    final double screenH = Device.height(context);

    if (analysisProvider.hasAnalysis &&
        analysisProvider.hasAudio &&
        !_didAutoPlay &&
        widget.autoPlayAudio) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) {
          return;
        }

        await _tryAutoPlay(
          context.read<FinancialAnalysisProvider>(),
        );
      });
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (
        didPop,
        result,
      ) async {
        if (didPop) {
          return;
        }

        await _closeScreen(
          analysisProvider,
        );
      },
      child: Scaffold(
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        body: SafeArea(
          child: _buildBody(
            context: context,
            provider: analysisProvider,
            isDark: isDark,
            screenW: screenW,
            screenH: screenH,
          ),
        ),
      ),
    );
  }

  Widget _buildBody({
    required BuildContext context,
    required FinancialAnalysisProvider provider,
    required bool isDark,
    required double screenW,
    required double screenH,
  }) {
    if (provider.isLoading && !provider.hasAnalysis) {
      return Center(
        child: CircularProgressIndicator(
          color: isDark
              ? AppColors.darkPrimary
              : AppColors.lightPrimary,
        ),
      );
    }

    if (!provider.hasAnalysis) {
      return _EmptyAnalysisView(
        isDark: isDark,
        screenW: screenW,
        errorMessage: provider.errorMessage,
        onRetry: () async {
          Navigator.pop(context);
        },
      );
    }

    final FinancialAnalysisModel analysis =
        provider.analysis!;

    return RefreshIndicator(
      onRefresh: () async {
        await Future<void>.value();
      },
      color: isDark
          ? AppColors.darkPrimary
          : AppColors.lightPrimary,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: screenW * 0.055,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: screenH * 0.022,
            ),

            _AnalysisHeader(
              isDark: isDark,
              screenW: screenW,
              analysisDate:
                  provider.analysisTitleDate,
              onClose: () {
                _closeScreen(provider);
              },
            ),

            SizedBox(
              height: screenH * 0.025,
            ),

            _AudioAnalysisCard(
              provider: provider,
              analysis: analysis,
              isDark: isDark,
              screenW: screenW,
            ),

            SizedBox(
              height: screenH * 0.028,
            ),

            _SectionHeader(
              icon: Icons.summarize_outlined,
              title:
                  'financial_analysis.analysis_summary'
                      .tr(),
              color: isDark
                  ? AppColors.darkAccent
                  : AppColors.lightAccent,
              isDark: isDark,
              screenW: screenW,
            ),

            SizedBox(
              height: screenH * 0.012,
            ),

            _SummaryCard(
              summary:
                  analysis.content.summary,
              isDark: isDark,
              screenW: screenW,
            ),

            SizedBox(
              height: screenH * 0.028,
            ),

            _SectionHeader(
              icon: Icons.analytics_outlined,
              title:
                  'financial_analysis.financial_indicators'
                      .tr(),
              color: isDark
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              isDark: isDark,
              screenW: screenW,
            ),

            SizedBox(
              height: screenH * 0.012,
            ),

            _MetricsSection(
              metrics: analysis.metrics,
              currency:
                  analysis.user.currency,
              isDark: isDark,
              screenW: screenW,
            ),

            SizedBox(
              height: screenH * 0.028,
            ),

            _SectionHeader(
              icon: Icons
                  .lightbulb_outline_rounded,
              title:
                  'financial_analysis.key_insights'
                      .tr(),
              color: const Color(
                0xFF4F9CF9,
              ),
              isDark: isDark,
              screenW: screenW,
            ),

            SizedBox(
              height: screenH * 0.012,
            ),

            _AnalysisItemsCard(
              items:
                  analysis.content.insights,
              icon:
                  Icons.insights_outlined,
              color: const Color(
                0xFF4F9CF9,
              ),
              isDark: isDark,
              screenW: screenW,
              emptyText:
                  'financial_analysis.no_insights'
                      .tr(),
            ),

            SizedBox(
              height: screenH * 0.028,
            ),

            _SectionHeader(
              icon: Icons.recommend_outlined,
              title:
                  'financial_analysis.recommendations'
                      .tr(),
              color: isDark
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              isDark: isDark,
              screenW: screenW,
            ),

            SizedBox(
              height: screenH * 0.012,
            ),

            _AnalysisItemsCard(
              items: analysis
                  .content.recommendations,
              icon: Icons
                  .check_circle_outline_rounded,
              color: isDark
                  ? AppColors.darkPrimary
                  : AppColors.lightPrimary,
              isDark: isDark,
              screenW: screenW,
              emptyText:
                  'financial_analysis.no_recommendations'
                      .tr(),
            ),

            if (provider.errorMessage !=
                null) ...[
              SizedBox(
                height: screenH * 0.02,
              ),
              _ErrorCard(
                message:
                    provider.errorMessage!,
                onClose:
                    provider.clearError,
                isDark: isDark,
              ),
            ],

            SizedBox(
              height: screenH * 0.032,
            ),

            SizedBox(
              width: double.infinity,
              height: screenH * 0.062,
              child: ElevatedButton(
                onPressed: () {
                  _closeScreen(provider);
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.darkPrimary
                      : AppColors
                          .lightPrimary,
                  foregroundColor:
                      Colors.white,
                  elevation: 0,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                ),
                child: Text(
                  'financial_analysis.done'
                      .tr(),
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    fontSize:
                        screenW * 0.041,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ),

            SizedBox(
              height: screenH * 0.03,
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisHeader extends StatelessWidget {
  final bool isDark;
  final double screenW;
  final String analysisDate;
  final VoidCallback onClose;

  const _AnalysisHeader({
    required this.isDark,
    required this.screenW,
    required this.analysisDate,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'financial_analysis.title'
                    .tr(),
                style: GoogleFonts
                    .ibmPlexSansArabic(
                  color: isDark
                      ? AppColors.darkText
                      : AppColors.lightText,
                  fontSize:
                      screenW * 0.058,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              if (analysisDate
                  .isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  'financial_analysis.analysis_as_of'
                      .tr(
                    namedArgs: {
                      'date': analysisDate,
                    },
                  ),
                  style: GoogleFonts
                      .ibmPlexSansArabic(
                    color: isDark
                        ? AppColors
                            .darkSubText
                        : AppColors
                            .lightSubText,
                    fontSize:
                        screenW * 0.029,
                  ),
                ),
              ],
            ],
          ),
        ),
        InkWell(
          onTap: onClose,
          borderRadius:
              BorderRadius.circular(14),
          child: Container(
            width: screenW * 0.105,
            height: screenW * 0.105,
            decoration: BoxDecoration(
              color:
                  primaryColor.withOpacity(
                isDark ? 0.10 : 0.07,
              ),
              borderRadius:
                  BorderRadius.circular(14),
              border: Border.all(
                color:
                    primaryColor.withOpacity(
                  0.22,
                ),
              ),
            ),
            child: Icon(
              Icons.close_rounded,
              color: primaryColor,
              size: screenW * 0.058,
            ),
          ),
        ),
      ],
    );
  }
}

class _AudioAnalysisCard extends StatelessWidget {
  final FinancialAnalysisProvider provider;
  final FinancialAnalysisModel analysis;
  final bool isDark;
  final double screenW;

  const _AudioAnalysisCard({
    required this.provider,
    required this.analysis,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final Color accentColor = isDark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    final Color cardColor = isDark
        ? AppColors.darkBorder
            .withOpacity(0.40)
        : AppColors.lightBorder
            .withOpacity(0.40);

    final Color borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final double sliderValue =
        provider.audioProgress.clamp(
      0.0,
      1.0,
    );

    final String speechText =
        analysis.content.speechText ?? '';

    return Material(
      color: cardColor,
      borderRadius:
          BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: Container(
        width: double.infinity,
        padding:
            const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(24),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration:
                      BoxDecoration(
                    color: accentColor
                        .withOpacity(0.14),
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                  child: Icon(
                    Icons
                        .graphic_eq_rounded,
                    color: accentColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        'financial_analysis.listen_to_alpha'
                            .tr(),
                        style: GoogleFonts
                            .ibmPlexSansArabic(
                          color: isDark
                              ? AppColors
                                  .darkText
                              : AppColors
                                  .lightText,
                          fontSize:
                              screenW *
                                  0.043,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                      const SizedBox(
                        height: 3,
                      ),
                      Text(
                        provider.hasAudio
                            ? provider
                                    .isAudioLoading
                                ? 'financial_analysis.preparing_audio'
                                    .tr()
                                : 'financial_analysis.voice_analysis'
                                    .tr()
                            : 'financial_analysis.audio_unavailable'
                                .tr(),
                        style: GoogleFonts
                            .ibmPlexSansArabic(
                          color: isDark
                              ? AppColors
                                  .darkSubText
                              : AppColors
                                  .lightSubText,
                          fontSize:
                              screenW *
                                  0.029,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed:
                      provider.hasAudio
                          ? provider.replayAudio
                          : null,
                  icon: Icon(
                    Icons.replay_rounded,
                    color:
                        provider.hasAudio
                            ? accentColor
                            : Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 17),
            Row(
              children: [
                InkWell(
                  onTap:
                      provider.hasAudio
                          ? provider.toggleAudio
                          : null,
                  borderRadius:
                      BorderRadius.circular(
                    40,
                  ),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration:
                        BoxDecoration(
                      color: accentColor,
                      shape:
                          BoxShape.circle,
                    ),
                    child: provider
                            .isAudioLoading
                        ? const Padding(
                            padding:
                                EdgeInsets.all(
                              13,
                            ),
                            child:
                                CircularProgressIndicator(
                              strokeWidth:
                                  2.4,
                              color:
                                  Colors.white,
                            ),
                          )
                        : Icon(
                            provider.isPlaying
                                ? Icons
                                    .pause_rounded
                                : Icons
                                    .play_arrow_rounded,
                            color:
                                Colors.white,
                            size: 31,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      SliderTheme(
                        data:
                            SliderTheme.of(
                          context,
                        ).copyWith(
                          activeTrackColor:
                              accentColor,
                          inactiveTrackColor:
                              accentColor
                                  .withOpacity(
                            0.18,
                          ),
                          thumbColor:
                              accentColor,
                          overlayColor:
                              accentColor
                                  .withOpacity(
                            0.10,
                          ),
                          trackHeight: 4,
                          thumbShape:
                              const RoundSliderThumbShape(
                            enabledThumbRadius:
                                6,
                          ),
                        ),
                        child: Slider(
                          min: 0,
                          max: 1,
                          value: sliderValue,
                          onChanged: provider
                                  .hasAudio
                              ? provider.seekAudio
                              : null,
                        ),
                      ),
                      Padding(
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 10,
                        ),
                        child: Row(
                          children: [
                            Text(
                              provider
                                  .formatDuration(
                                provider
                                    .position,
                              ),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(
                                color: isDark
                                    ? AppColors
                                        .darkSubText
                                    : AppColors
                                        .lightSubText,
                                fontSize: 10,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              provider
                                  .formatDuration(
                                provider
                                    .duration,
                              ),
                              style: GoogleFonts
                                  .ibmPlexSansArabic(
                                color: isDark
                                    ? AppColors
                                        .darkSubText
                                    : AppColors
                                        .lightSubText,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (speechText
                .trim()
                .isNotEmpty) ...[
              const SizedBox(height: 14),
              Theme(
                data: Theme.of(context)
                    .copyWith(
                  dividerColor:
                      Colors.transparent,
                  splashColor: accentColor
                      .withOpacity(0.08),
                  highlightColor:
                      accentColor
                          .withOpacity(0.04),
                ),
                child: ExpansionTile(
                  tilePadding:
                      EdgeInsets.zero,
                  childrenPadding:
                      const EdgeInsets.only(
                    bottom: 4,
                  ),
                  backgroundColor:
                      Colors.transparent,
                  collapsedBackgroundColor:
                      Colors.transparent,
                  iconColor: accentColor,
                  collapsedIconColor:
                      isDark
                          ? AppColors
                              .darkSubText
                          : AppColors
                              .lightSubText,
                  title: Text(
                    'financial_analysis.view_transcript'
                        .tr(),
                    style: GoogleFonts
                        .ibmPlexSansArabic(
                      color: isDark
                          ? AppColors
                              .darkText
                          : AppColors
                              .lightText,
                      fontSize: 12,
                      fontWeight:
                          FontWeight.w600,
                    ),
                  ),
                  children: [
                    Container(
                      width:
                          double.infinity,
                      padding:
                          const EdgeInsets
                              .all(13),
                      decoration:
                          BoxDecoration(
                        color: isDark
                            ? AppColors
                                .darkBackground
                            : AppColors
                                .lightBackground,
                        borderRadius:
                            BorderRadius
                                .circular(14),
                        border: Border.all(
                          color:
                              borderColor,
                        ),
                      ),
                      child: Text(
                        speechText,
                        textDirection:
                            Directionality.of(
                          context,
                        ),
                        style: GoogleFonts
                            .ibmPlexSansArabic(
                          color: isDark
                              ? AppColors
                                  .darkText
                              : AppColors
                                  .lightText,
                          fontSize: 12,
                          height: 1.7,
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
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final bool isDark;
  final double screenW;

  const _SectionHeader({
    required this.icon,
    required this.title,
    required this.color,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 37,
          height: 37,
          decoration: BoxDecoration(
            color:
                color.withOpacity(0.12),
            borderRadius:
                BorderRadius.circular(11),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: GoogleFonts
                .ibmPlexSansArabic(
              color: isDark
                  ? AppColors.darkText
                  : AppColors.lightText,
              fontSize:
                  screenW * 0.043,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String summary;
  final bool isDark;
  final double screenW;

  const _SummaryCard({
    required this.summary,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBorder
                .withOpacity(0.40)
            : AppColors.lightBorder
                .withOpacity(0.40),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Text(
        summary.trim().isEmpty
            ? 'financial_analysis.no_summary'
                .tr()
            : summary,
        textDirection:
            Directionality.of(context),
        style: GoogleFonts
            .ibmPlexSansArabic(
          color: isDark
              ? AppColors.darkText
              : AppColors.lightText,
          fontSize: screenW * 0.035,
          height: 1.8,
        ),
      ),
    );
  }
}

class _MetricsSection extends StatelessWidget {
  final AnalysisMetrics metrics;
  final String currency;
  final bool isDark;
  final double screenW;

  const _MetricsSection({
    required this.metrics,
    required this.currency,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MetricCard(
          title:
              'financial_analysis.metrics.savings'
                  .tr(),
          metric: metrics.savings,
          currency: currency,
          icon: Icons.savings_outlined,
          color:
              const Color(0xFF34D399),
          isDark: isDark,
          screenW: screenW,
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title:
              'financial_analysis.metrics.needs'
                  .tr(),
          metric: metrics.needs,
          currency: currency,
          icon:
              Icons.home_work_outlined,
          color:
              const Color(0xFF4F9CF9),
          isDark: isDark,
          screenW: screenW,
        ),
        const SizedBox(height: 12),
        _MetricCard(
          title:
              'financial_analysis.metrics.wants'
                  .tr(),
          metric: metrics.wants,
          currency: currency,
          icon: Icons
              .shopping_bag_outlined,
          color:
              const Color(0xFFF4C95D),
          isDark: isDark,
          screenW: screenW,
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final AnalysisMetric metric;
  final String currency;
  final IconData icon;
  final Color color;
  final bool isDark;
  final double screenW;

  const _MetricCard({
    required this.title,
    required this.metric,
    required this.currency,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final bool unavailable =
        metric.isUnavailable ||
            metric.current == null ||
            metric.target == null ||
            metric.percent == null;

    final double progress = unavailable
        ? 0
        : ((metric.percent ?? 0) / 100)
            .clamp(0.0, 1.0);

    final Color statusColor =
        _statusColor(metric.status);

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBorder
                .withOpacity(0.40)
            : AppColors.lightBorder
                .withOpacity(0.40),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration:
                    BoxDecoration(
                  color: color
                      .withOpacity(0.12),
                  borderRadius:
                      BorderRadius.circular(
                    13,
                  ),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: isDark
                            ? AppColors
                                .darkText
                            : AppColors
                                .lightText,
                        fontSize:
                            screenW *
                                0.039,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    const SizedBox(
                      height: 3,
                    ),
                    Text(
                      unavailable
                          ? 'financial_analysis.status.unknown'
                              .tr()
                          : '${metric.current!.toStringAsFixed(2)} / '
                              '${metric.target!.toStringAsFixed(2)} $currency',
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: isDark
                            ? AppColors
                                .darkSubText
                            : AppColors
                                .lightSubText,
                        fontSize:
                            screenW *
                                0.028,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.end,
                children: [
                  Text(
                    unavailable
                        ? 'N/A'
                        : '${metric.percent!.toStringAsFixed(0)}%',
                    style: GoogleFonts
                        .ibmPlexSansArabic(
                      color: color,
                      fontSize:
                          screenW * 0.043,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsets.only(
                      top: 4,
                    ),
                    padding: const EdgeInsets
                        .symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration:
                        BoxDecoration(
                      color: statusColor
                          .withOpacity(0.11),
                      borderRadius:
                          BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: Text(
                      _analysisStatusLabel(
                        metric.status,
                      ),
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: statusColor,
                        fontSize: 9,
                        fontWeight:
                            FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius:
                BorderRadius.circular(20),
            child:
                LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor:
                  color.withOpacity(0.13),
              valueColor:
                  AlwaysStoppedAnimation<
                      Color>(
                color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisItemsCard
    extends StatelessWidget {
  final List<String> items;
  final IconData icon;
  final Color color;
  final bool isDark;
  final double screenW;
  final String emptyText;

  const _AnalysisItemsCard({
    required this.items,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.screenW,
    required this.emptyText,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> displayedItems =
        items.isEmpty
            ? [emptyText]
            : items;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBorder
                .withOpacity(0.40)
            : AppColors.lightBorder
                .withOpacity(0.40),
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder
              : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: List.generate(
          displayedItems.length,
          (index) {
            final String item =
                displayedItems[index];

            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    vertical: 13,
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration:
                            BoxDecoration(
                          color: color
                              .withOpacity(
                            0.12,
                          ),
                          borderRadius:
                              BorderRadius
                                  .circular(
                            10,
                          ),
                        ),
                        child: Icon(
                          icon,
                          color: color,
                          size: 18,
                        ),
                      ),
                      const SizedBox(
                        width: 11,
                      ),
                      Expanded(
                        child: Text(
                          item,
                          textDirection:
                              Directionality.of(
                            context,
                          ),
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            color: isDark
                                ? AppColors
                                    .darkText
                                : AppColors
                                    .lightText,
                            fontSize:
                                screenW *
                                    0.033,
                            height: 1.65,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (index <
                    displayedItems.length -
                        1)
                  Divider(
                    height: 1,
                    color: isDark
                        ? AppColors
                            .darkBorder
                        : AppColors
                            .lightBorder,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onClose;
  final bool isDark;

  const _ErrorCard({
    required this.message,
    required this.onClose,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final Color errorColor = isDark
        ? AppColors.darkError
        : AppColors.lightError;

    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.only(
        left: 13,
        top: 8,
        bottom: 8,
      ),
      decoration: BoxDecoration(
        color: errorColor
            .withOpacity(0.10),
        borderRadius:
            BorderRadius.circular(14),
        border: Border.all(
          color: errorColor
              .withOpacity(0.22),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons
                .error_outline_rounded,
            color: errorColor,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: errorColor,
              ),
            ),
          ),
          IconButton(
            onPressed: onClose,
            icon: Icon(
              Icons.close_rounded,
              color: errorColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyAnalysisView
    extends StatelessWidget {
  final bool isDark;
  final double screenW;
  final String? errorMessage;
  final Future<void> Function() onRetry;

  const _EmptyAnalysisView({
    required this.isDark,
    required this.screenW,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    return Center(
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.all(24),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Container(
              width: screenW * 0.27,
              height: screenW * 0.27,
              decoration: BoxDecoration(
                color: primaryColor
                    .withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.analytics_outlined,
                color: primaryColor,
                size: screenW * 0.13,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'financial_analysis.empty_title'
                  .tr(),
              style: GoogleFonts
                  .ibmPlexSansArabic(
                color: isDark
                    ? AppColors.darkText
                    : AppColors.lightText,
                fontSize:
                    screenW * 0.052,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage ??
                  'financial_analysis.empty_description'
                      .tr(),
              textAlign:
                  TextAlign.center,
              style: GoogleFonts
                  .ibmPlexSansArabic(
                color: isDark
                    ? AppColors
                        .darkSubText
                    : AppColors
                        .lightSubText,
                fontSize:
                    screenW * 0.033,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(
                Icons.refresh_rounded,
              ),
              label: Text(
                'financial_analysis.load_analysis'
                    .tr(),
              ),
              style: ElevatedButton
                  .styleFrom(
                backgroundColor:
                    primaryColor,
                foregroundColor:
                    Colors.white,
                padding:
                    const EdgeInsets
                        .symmetric(
                  horizontal: 22,
                  vertical: 13,
                ),
                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _analysisStatusLabel(
  AnalysisStatus status,
) {
  switch (status) {
    case AnalysisStatus.onTrack:
      return 'financial_analysis.status.on_track'
          .tr();

    case AnalysisStatus.warning:
      return 'financial_analysis.status.warning'
          .tr();

    case AnalysisStatus.exceeded:
      return 'financial_analysis.status.critical'
          .tr();

    case AnalysisStatus.completed:
      return 'financial_analysis.status.on_track'
          .tr();

    case AnalysisStatus.unavailable:
      return 'financial_analysis.status.unknown'
          .tr();
  }
}

Color _statusColor(
  AnalysisStatus status,
) {
  switch (status) {
    case AnalysisStatus.onTrack:
      return const Color(
        0xFF34D399,
      );

    case AnalysisStatus.warning:
      return const Color(
        0xFFF4C95D,
      );

    case AnalysisStatus.exceeded:
      return const Color(
        0xFFFF6B6B,
      );

    case AnalysisStatus.completed:
      return const Color(
        0xFF34D399,
      );

    case AnalysisStatus.unavailable:
      return const Color(
        0xFF8A9A96,
      );
  }
}
