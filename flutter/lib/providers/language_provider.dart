import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  String get languageCode => _currentLocale.languageCode;

  Future<void> changeLanguage(
    BuildContext context,
    String langCode,
  ) async {
    if (_currentLocale.languageCode == langCode) {
      return;
    }

    _currentLocale = Locale(langCode);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', langCode);

    if (context.mounted) {
      await context.setLocale(_currentLocale);
    }

    notifyListeners();
  }

  Future<void> loadSavedLanguage() async {
    final prefs = await SharedPreferences.getInstance();

    final langCode =
        prefs.getString('language_code') ?? 'en';

    _currentLocale = Locale(langCode);

    notifyListeners();
  }

  void syncWithEasyLocalization(Locale locale) {
    if (_currentLocale.languageCode ==
        locale.languageCode) {
      return;
    }

    _currentLocale = locale;
    notifyListeners();
  }
}