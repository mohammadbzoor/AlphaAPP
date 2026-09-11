import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/app_button.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({
    super.key,
  });

  static const List<_TermsSectionData> _sections = [
    _TermsSectionData(
      groupKey: "terms.section_general",
      titleKey: "terms.introduction_title",
      bodyKey: "terms.introduction_body",
      icon: Icons.info_outline_rounded,
    ),
    _TermsSectionData(
      titleKey: "terms.service_title",
      bodyKey: "terms.service_body",
      icon: Icons.analytics_outlined,
    ),
    _TermsSectionData(
      groupKey: "terms.section_data",
      titleKey: "terms.privacy_title",
      bodyKey: "terms.privacy_body",
      icon: Icons.shield_outlined,
    ),
    _TermsSectionData(
      titleKey: "terms.accuracy_title",
      bodyKey: "terms.accuracy_body",
      icon: Icons.fact_check_outlined,
    ),
    _TermsSectionData(
      groupKey: "terms.section_compliance",
      titleKey: "terms.property_title",
      bodyKey: "terms.property_body",
      icon: Icons.gavel_outlined,
    ),
    _TermsSectionData(
      titleKey: "terms.disclaimer_title",
      bodyKey: "terms.disclaimer_body",
      icon: Icons.warning_amber_rounded,
    ),
    _TermsSectionData(
      groupKey: "terms.section_contract",
      titleKey: "terms.account_title",
      bodyKey: "terms.account_body",
      icon: Icons.manage_accounts_outlined,
    ),
    _TermsSectionData(
      groupKey: "terms.section_disputes",
      titleKey: "terms.disputes_title",
      bodyKey: "terms.disputes_body",
      icon: Icons.balance_outlined,
    ),
    _TermsSectionData(
      groupKey: "terms.section_governance",
      titleKey: "terms.audit_title",
      bodyKey: "terms.audit_body",
      icon: Icons.policy_outlined,
    ),
    _TermsSectionData(
      titleKey: "terms.kyc_title",
      bodyKey: "terms.kyc_body",
      icon: Icons.badge_outlined,
    ),
    _TermsSectionData(
      titleKey: "terms.dpia_title",
      bodyKey: "terms.dpia_body",
      icon: Icons.privacy_tip_outlined,
    ),
    _TermsSectionData(
      titleKey: "terms.development_title",
      bodyKey: "terms.development_body",
      icon: Icons.system_update_alt_rounded,
    ),
    _TermsSectionData(
      titleKey: "terms.acceptance_title",
      bodyKey: "terms.acceptance_body",
      icon: Icons.task_alt_rounded,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);

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

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics:
                    const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(
                  screenW * 0.055,
                  18,
                  screenW * 0.055,
                  28,
                ),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                "terms.title".tr(),
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color: textColor,
                                  fontSize:
                                      screenW * 0.064,
                                  fontWeight:
                                      FontWeight.bold,
                                  height: 1.3,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                "terms.last_updated".tr(),
                                style: GoogleFonts
                                    .ibmPlexSansArabic(
                                  color: subTextColor,
                                  fontSize:
                                      screenW * 0.032,
                                  fontWeight:
                                      FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                       
                      ],
                    ),

                    const SizedBox(height: 22),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.16),
                        borderRadius:
                            BorderRadius.circular(22),
                        border: Border.all(
                          color: accentColor,
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color:
                                  accentColor.withOpacity(0.14),
                              borderRadius:
                                  BorderRadius.circular(14),
                            ),
                            child: Icon(
                              Icons.lock_outline_rounded,
                              color: accentColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 13),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "terms.commitment_title".tr(),
                                  style: GoogleFonts
                                      .ibmPlexSansArabic(
                                    color: textColor,
                                    fontSize: 14,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  "terms.commitment_description"
                                      .tr(),
                                  style: GoogleFonts
                                      .ibmPlexSansArabic(
                                    color: subTextColor,
                                    fontSize: 12,
                                    height: 1.65,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    ..._sections.map(
                      (section) => _TermsSectionCard(
                        data: section,
                        isDark: isDark,
                      ),
                    ),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: primaryColor.withOpacity(0.06),
                        borderRadius:
                            BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              primaryColor.withOpacity(0.30),
                        ),
                      ),
                      child: Text(
                        "terms.signature".tr(),
                        style:
                            GoogleFonts.ibmPlexSansArabic(
                          color: textColor,
                          fontSize: 13,
                          height: 1.6,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              padding: EdgeInsets.fromLTRB(
                screenW * 0.055,
                12,
                screenW * 0.055,
                MediaQuery.paddingOf(context).bottom +
                    14,
              ),
              decoration: BoxDecoration(
                color: backgroundColor,
                border: Border(
                  top: BorderSide(
                    color: borderColor.withOpacity(0.7),
                  ),
                ),
              ),
              child: AppButton(
                text: "terms.back_button".tr(),
                isDark: isDark,
                width: double.infinity,
                height: 54,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TermsSectionData {
  final String? groupKey;
  final String titleKey;
  final String bodyKey;
  final IconData icon;

  const _TermsSectionData({
    this.groupKey,
    required this.titleKey,
    required this.bodyKey,
    required this.icon,
  });
}

class _TermsSectionCard extends StatelessWidget {
  final _TermsSectionData data;
  final bool isDark;

  const _TermsSectionCard({
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final textColor = isDark
        ? AppColors.darkText
        : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        if (data.groupKey != null) ...[
          Padding(
            padding:
                const EdgeInsetsDirectional.only(
              start: 2,
              bottom: 10,
            ),
            child: Text(
              data.groupKey!.tr(),
              style: GoogleFonts
                  .ibmPlexSansArabic(
                color: primaryColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            color: primaryColor.withOpacity(0.04),
            borderRadius:
                BorderRadius.circular(22),
            border: Border.all(
              color: borderColor,
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color:
                          primaryColor.withOpacity(0.12),
                      borderRadius:
                          BorderRadius.circular(13),
                    ),
                    child: Icon(
                      data.icon,
                      color: primaryColor,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data.titleKey.tr(),
                      style: GoogleFonts
                          .ibmPlexSansArabic(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              Text(
                data.bodyKey.tr(),
                style:
                    GoogleFonts.ibmPlexSansArabic(
                  color: subTextColor,
                  fontSize: 12.5,
                  height: 1.75,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),
      ],
    );
  }
}