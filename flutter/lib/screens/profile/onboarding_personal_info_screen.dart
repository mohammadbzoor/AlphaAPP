import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/core/utils/step_resolver.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/option_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:provider/provider.dart';

class OnboardingPersonalInfoScreen extends StatefulWidget {
  const OnboardingPersonalInfoScreen({
    super.key,
  });

  @override
  State<OnboardingPersonalInfoScreen> createState() =>
      _OnboardingPersonalInfoScreenState();
}

class _OnboardingPersonalInfoScreenState
    extends State<OnboardingPersonalInfoScreen> {
  String? _gender = 'Female';
  String? _maritalStatus = 'Single';

  bool _isHeadOfHousehold = false;
  bool _contributesToExpenses = false;
  bool _isStudent = false;

  int _familySize = 1;

  bool _isNavigating = false;

  Future<void> _submit() async {
    if (_isNavigating) {
      return;
    }

    setState(() {
      _isNavigating = true;
    });

    try {
      final provider = context.read<OnboardingProvider>();

      // نفس أسماء الحقول والقيم التي يعتمد عليها الباك.
      final data = {
        'gender': _gender?.toLowerCase(),
        'maritalStatus': _maritalStatus?.toLowerCase(),
        'isHeadOfHousehold': _isHeadOfHousehold,
        'isStudent': _isStudent,
        'familySize': _familySize,
        'contributesToExpenses': _contributesToExpenses,
      };

      // نفس استدعاء الباك.
      final success = await provider.savePersonalInfo(data);

      if (!mounted) {
        return;
      }

      if (success) {
        // نفس الانتقال الذي يحدده الباك.
        replaceWithOnboardingStep(
          context,
          provider.nextStep,
        );

        return;
      }

      if (provider.errorMessage != null) {
        final themeProvider = context.read<Themeprovider>();
        final isDark = themeProvider.isDark;

        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(
                provider.errorMessage!,
                style: GoogleFonts.ibmPlexSansArabic(),
              ),
              backgroundColor: isDark
                  ? AppColors.darkError
                  : AppColors.lightError,
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = Device.width(context);
    final screenH = Device.height(context);

    final provider = context.watch<OnboardingProvider>();
    final themeProvider = context.watch<Themeprovider>();

    final isDark = themeProvider.isDark;

    final backgroundColor = isDark
        ? AppColors.darkBackground
        : AppColors.lightBackground;

    final textColor =
        isDark ? AppColors.darkText : AppColors.lightText;

    final subTextColor = isDark
        ? AppColors.darkSubText
        : AppColors.lightSubText;

    final primaryColor = isDark
        ? AppColors.darkPrimary
        : AppColors.lightPrimary;

    final secondaryColor = isDark
        ? AppColors.darkSecondary
        : AppColors.lightSecondary;

    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final errorColor =
        isDark ? AppColors.darkError : AppColors.lightError;

    final isLoading =
        provider.isLoading || _isNavigating;

    final genderValues = <String>[
      'Female',
      'Male',
    ];

    final maritalStatusValues = <String>[
      'Single',
      'Married',
      'Other',
    ];

    final yesNoValues = <String>[
      'Yes',
      'No',
    ];

    String translateGender(String value) {
      switch (value) {
        case 'Female':
          return 'personal_info.female'.tr();
        case 'Male':
          return 'personal_info.male'.tr();
        default:
          return value;
      }
    }

    String translateMaritalStatus(String value) {
      switch (value) {
        case 'Single':
          return 'personal_info.single'.tr();
        case 'Married':
          return 'personal_info.married'.tr();
        case 'Other':
          return 'personal_info.other'.tr();
        default:
          return value;
      }
    }

    String translateYesNo(String value) {
      return value == 'Yes'
          ? 'personal_info.yes'.tr()
          : 'personal_info.no'.tr();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            screenW * 0.055,
            screenH * 0.025,
            screenW * 0.055,
            screenH * 0.035,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'personal_info.step'.tr(
                  namedArgs: {
                    'current': '1',
                    'total': '3',
                  },
                ),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: screenW * 0.038,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkAccent
                      : AppColors.lightAccent,
                ),
              ),

              SizedBox(
                height: screenH * 0.012,
              ),

              Text(
                'personal_info.title'.tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: screenW * 0.075,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                  height: 1.2,
                ),
              ),

              SizedBox(
                height: screenH * 0.01,
              ),

              Text(
                'personal_info.description'.tr(),
                style: GoogleFonts.ibmPlexSansArabic(
                  fontSize: screenW * 0.036,
                  fontWeight: FontWeight.w500,
                  color: subTextColor,
                  height: 1.5,
                ),
              ),

              SizedBox(
                height: screenH * 0.022,
              ),

              LinearPercentIndicator(
                lineHeight: screenH * 0.015,
                percent: 0.25,
                padding: EdgeInsets.zero,
                backgroundColor: borderColor,
                progressColor: secondaryColor,
                barRadius: const Radius.circular(10),
                animation: false,
              ),

              SizedBox(
                height: screenH * 0.03,
              ),

              _OptionSection(
                title: 'personal_info.gender'.tr(),
                isDark: isDark,
                screenW: screenW,
                child: OptionChip(
                  items: genderValues
                      .map(translateGender)
                      .toList(),
                  selected: _gender == null
                      ? null
                      : translateGender(_gender!),
                  onTap: (translatedValue) {
                    if (isLoading) {
                      return;
                    }

                    final translatedItems = genderValues
                        .map(translateGender)
                        .toList();

                    final selectedIndex = translatedItems
                        .indexOf(translatedValue);

                    if (selectedIndex != -1) {
                      setState(() {
                        _gender =
                            genderValues[selectedIndex];
                      });
                    }
                  },
                ),
              ),

              SizedBox(
                height: screenH * 0.022,
              ),

              _OptionSection(
                title: 'personal_info.marital_status'.tr(),
                isDark: isDark,
                screenW: screenW,
                child: OptionChip(
                  items: maritalStatusValues
                      .map(translateMaritalStatus)
                      .toList(),
                  selected: _maritalStatus == null
                      ? null
                      : translateMaritalStatus(
                          _maritalStatus!,
                        ),
                  onTap: (translatedValue) {
                    if (isLoading) {
                      return;
                    }

                    final translatedItems =
                        maritalStatusValues
                            .map(
                              translateMaritalStatus,
                            )
                            .toList();

                    final selectedIndex = translatedItems
                        .indexOf(translatedValue);

                    if (selectedIndex != -1) {
                      setState(() {
                        _maritalStatus =
                            maritalStatusValues[
                                selectedIndex];
                      });
                    }
                  },
                ),
              ),

              SizedBox(
                height: screenH * 0.022,
              ),

              _OptionSection(
                title:
                    'personal_info.head_of_household'.tr(),
                isDark: isDark,
                screenW: screenW,
                child: OptionChip(
                  items: yesNoValues
                      .map(translateYesNo)
                      .toList(),
                  selected: translateYesNo(
                    _isHeadOfHousehold
                        ? 'Yes'
                        : 'No',
                  ),
                  onTap: (translatedValue) {
                    if (isLoading) {
                      return;
                    }

                    setState(() {
                      _isHeadOfHousehold =
                          translatedValue ==
                              translateYesNo('Yes');
                    });
                  },
                ),
              ),

              if (!_isHeadOfHousehold) ...[
                SizedBox(
                  height: screenH * 0.022,
                ),
                _OptionSection(
                  title:
                      'personal_info.contribute_expenses'
                          .tr(),
                  isDark: isDark,
                  screenW: screenW,
                  child: OptionChip(
                    items: yesNoValues
                        .map(translateYesNo)
                        .toList(),
                    selected: translateYesNo(
                      _contributesToExpenses
                          ? 'Yes'
                          : 'No',
                    ),
                    onTap: (translatedValue) {
                      if (isLoading) {
                        return;
                      }

                      setState(() {
                        _contributesToExpenses =
                            translatedValue ==
                                translateYesNo('Yes');
                      });
                    },
                  ),
                ),
              ],

              SizedBox(
                height: screenH * 0.022,
              ),

              _OptionSection(
                title:
                    'personal_info.university_student'.tr(),
                isDark: isDark,
                screenW: screenW,
                child: OptionChip(
                  items: yesNoValues
                      .map(translateYesNo)
                      .toList(),
                  selected: translateYesNo(
                    _isStudent ? 'Yes' : 'No',
                  ),
                  onTap: (translatedValue) {
                    if (isLoading) {
                      return;
                    }

                    setState(() {
                      _isStudent =
                          translatedValue ==
                              translateYesNo('Yes');
                    });
                  },
                ),
              ),

              SizedBox(
                height: screenH * 0.022,
              ),

              _OptionSection(
                title:
                    'personal_info.family_members'.tr(),
                isDark: isDark,
                screenW: screenW,
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.start,
                  children: [
                    _CounterButton(
                      icon: Icons.remove,
                      onTap: isLoading
                          ? null
                          : () {
                              if (_familySize > 1) {
                                setState(() {
                                  _familySize--;
                                });
                              }
                            },
                      isDark: isDark,
                      screenW: screenW,
                    ),

                    Container(
                      constraints: BoxConstraints(
                        minWidth: screenW * 0.18,
                      ),
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenW * 0.04,
                      ),
                      child: Text(
                        '$_familySize',
                        style:
                            GoogleFonts.ibmPlexSansArabic(
                          fontSize: screenW * 0.06,
                          color: primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    _CounterButton(
                      icon: Icons.add,
                      onTap: isLoading
                          ? null
                          : () {
                              setState(() {
                                _familySize++;
                              });
                            },
                      isDark: isDark,
                      screenW: screenW,
                    ),
                  ],
                ),
              ),

              SizedBox(
                height: screenH * 0.03,
              ),

              SizedBox(
                width: double.infinity,
                height: screenH * 0.065,
                child: ElevatedButton(
                  // نفس دالة الإرسال للباك.
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    disabledBackgroundColor:
                        primaryColor.withOpacity(0.55),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          width: screenW * 0.055,
                          height: screenW * 0.055,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: isDark
                                ? AppColors.darkBackground
                                : AppColors.lightCard,
                          ),
                        )
                      : Text(
                          'personal_info.next'.tr(),
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            fontSize: screenW * 0.047,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),

              if (provider.errorMessage != null) ...[
                SizedBox(
                  height: screenH * 0.014,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: errorColor.withOpacity(0.10),
                    borderRadius:
                        BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          errorColor.withOpacity(0.30),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: errorColor,
                        size: screenW * 0.05,
                      ),
                      SizedBox(
                        width: screenW * 0.02,
                      ),
                      Expanded(
                        child: Text(
                          provider.errorMessage!,
                          style: GoogleFonts
                              .ibmPlexSansArabic(
                            color: errorColor,
                            fontSize: screenW * 0.033,
                            fontWeight:
                                FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(
                height: screenH * 0.02,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OptionSection extends StatelessWidget {
  final String title;
  final bool isDark;
  final double screenW;
  final Widget child;

  const _OptionSection({
    required this.title,
    required this.isDark,
    required this.screenW,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;

    final cardColor = isDark
        ? AppColors.darkCard.withOpacity(0.55)
        : AppColors.lightCard;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        screenW * 0.035,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          _SectionTitle(
            title: title,
            isDark: isDark,
            screenW: screenW,
          ),
          SizedBox(
            height: screenW * 0.035,
          ),
          child,
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final bool isDark;
  final double screenW;

  const _SectionTitle({
    required this.title,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.ibmPlexSansArabic(
        fontSize: screenW * 0.04,
        color: isDark
            ? AppColors.darkSubText
            : AppColors.lightSubText,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _CounterButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;
  final double screenW;

  const _CounterButton({
    required this.icon,
    required this.onTap,
    required this.isDark,
    required this.screenW,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = isDark
        ? AppColors.darkAccent
        : AppColors.lightAccent;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: screenW * 0.115,
        height: screenW * 0.115,
        decoration: BoxDecoration(
          color: accentColor.withOpacity(
            onTap == null ? 0.04 : 0.10,
          ),
          borderRadius:
              BorderRadius.circular(12),
          border: Border.all(
            color: accentColor.withOpacity(
              onTap == null ? 0.35 : 1,
            ),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon,
          color: accentColor.withOpacity(
            onTap == null ? 0.4 : 1,
          ),
          size: screenW * 0.06,
        ),
      ),
    );
  }
}
