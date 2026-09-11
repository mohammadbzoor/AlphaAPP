import 'package:alpha_app/media/images.dart';
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/core/utils/app_colors.dart';
import 'package:alpha_app/core/utils/device.dart';
import 'package:alpha_app/widgets/Custom_mesh_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class BoardingOne extends StatelessWidget {
  const BoardingOne({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenW = Device.width(context);
    final double screenH = Device.height(context);
    final themeProvider = Provider.of<Themeprovider>(context);

    return Center(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
              top: screenH * 0.08,
            ),
            child: CustomMeshCard(
              hight: screenH * 0.4,
              width: screenW * 0.8,
              isDark: themeProvider.isDark,
              imagepath: ImagesAssets.boarding1,
            ),
          ),
          SizedBox(
            height: screenH * 0.04,
          ),
          Text(
            'onboarding.page_one.title'.tr(),
            textAlign: TextAlign.center,
            style: GoogleFonts.ibmPlexSansArabic(
              fontSize: screenW * 0.07,
              fontWeight: FontWeight.bold,
              color: themeProvider.isDark
                  ? AppColors.darkText
                  : AppColors.lightText,
            ),
          ),
          SizedBox(
            height: screenH * 0.03,
          ),
          Expanded(
            child: Text(
              'onboarding.page_one.description'.tr(),
              textAlign: TextAlign.center,
              style: GoogleFonts.ibmPlexSansArabic(
                fontSize: screenW * 0.042,
                color: themeProvider.isDark
                    ? AppColors.darkSubText
                    : AppColors.lightSubText,
              ),
            ),
          ),
        ],
      ),
    );
  }
}