import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/providers/profile_provider.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/widgets/option_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class PersonalInfoScreen extends StatefulWidget {
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _gender;
  DateTime? _birthDate;
  bool _isInit = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProfile();
    });
  }

  Future<void> _loadProfile() async {
    if (!mounted || _isInit) return;

    _isInit = true;

    final profileProvider = context.read<ProfileProvider>();
    await profileProvider.loadFullProfile();

    if (!mounted) return;

    final profile = profileProvider.profile;

    setState(() {
      _nameController.text = profile?.name ?? '';
      _emailController.text = profile?.email ?? '';
      _phoneController.text = profile?.phone ?? '';
      _gender = profile?.gender?.toLowerCase();
      _birthDate = profile?.birthDate;
    });
  }

  Future<void> _retryLoadProfile() async {
    _isInit = false;
    await _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final profileProvider = context.read<ProfileProvider>();

    final success = await profileProvider.updateProfile(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      gender: _gender,
      birthDate: _birthDate,
    );

    if (!mounted) return;

    if (success) {
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            profileProvider.errorMessage ??
                'common.something_went_wrong'.tr(),
          ),
          backgroundColor: AppColors.darkError,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = context.watch<ProfileProvider>();
    final themeProvider = context.watch<Themeprovider>();
    final screenW = Device.width(context);
    final screenH = Device.height(context);
    final isDark = themeProvider.isDark;

    final femaleLabel = 'personal_info.female'.tr();
    final maleLabel = 'personal_info.male'.tr();

    String selectedGenderLabel = femaleLabel;
    if (_gender == 'male') {
      selectedGenderLabel = maleLabel;
    }

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? AppColors.darkText : AppColors.lightText,
        ),
        title: Text(
          'profile.edit_profile'.tr(),
          style: GoogleFonts.ibmPlexSansArabic(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: profileProvider.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color:
                      isDark ? AppColors.darkPrimary : AppColors.lightPrimary,
                ),
              )
            : profileProvider.errorMessage != null &&
                    !profileProvider.hasProfile
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 48,
                          color: AppColors.darkError,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'common.something_went_wrong'.tr(),
                          style: GoogleFonts.ibmPlexSansArabic(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _retryLoadProfile,
                          icon: const Icon(Icons.refresh),
                          label: Text(
                            'common.try_again'.tr(),
                            style: GoogleFonts.ibmPlexSansArabic(
                              color: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenW * 0.05,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: screenH * 0.03),
                        Text(
                          'profile.full_name'.tr(),
                          style: TextStyle(
                            fontSize: screenW * 0.04,
                            color: isDark
                                ? AppColors.darkSubText
                                : AppColors.lightSubText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenH * 0.01),
                        TextField(
                          controller: _nameController,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkBorder
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: screenH * 0.02),
                        Text(
                          'profile.email'.tr(),
                          style: TextStyle(
                            fontSize: screenW * 0.04,
                            color: isDark
                                ? AppColors.darkSubText
                                : AppColors.lightSubText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenH * 0.01),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkBorder
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: screenH * 0.02),
                        Text(
                          'profile.phone'.tr(),
                          style: TextStyle(
                            fontSize: screenW * 0.04,
                            color: isDark
                                ? AppColors.darkSubText
                                : AppColors.lightSubText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenH * 0.01),
                        TextField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDark
                                ? AppColors.darkBorder
                                : Colors.grey[200],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        SizedBox(height: screenH * 0.02),
                        Text(
                          'personal_info.gender'.tr(),
                          style: TextStyle(
                            fontSize: screenW * 0.04,
                            color: isDark
                                ? AppColors.darkSubText
                                : AppColors.lightSubText,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: screenH * 0.01),
                        OptionChip(
                          items: [femaleLabel, maleLabel],
                          selected: selectedGenderLabel,
                          onTap: (value) {
                            setState(() {
                              _gender =
                                  value == femaleLabel ? 'female' : 'male';
                            });
                          },
                        ),
                        SizedBox(height: screenH * 0.05),
                        SizedBox(
                          width: double.infinity,
                          height: screenH * 0.065,
                          child: ElevatedButton(
                            onPressed:
                                profileProvider.isSaving ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? AppColors.darkPrimary
                                  : AppColors.lightPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: profileProvider.isSaving
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : Text(
                                    'common.save_changes'.tr(),
                                    style: TextStyle(
                                      fontSize: screenW * 0.055,
                                      color: AppColors.darkBorder,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                        SizedBox(height: screenH * 0.05),
                      ],
                    ),
                  ),
      ),
    );
  }
}
