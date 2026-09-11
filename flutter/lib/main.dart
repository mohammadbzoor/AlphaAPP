import 'dart:io';

import 'package:alpha_app/config/api_config.dart';
import 'package:alpha_app/providers/auth_provider.dart';
import 'package:alpha_app/providers/challenge_provider.dart';
import 'package:alpha_app/providers/chatbot_provider.dart';
import 'package:alpha_app/providers/cycle_provider.dart';
import 'package:alpha_app/providers/expense_provider.dart';
import 'package:alpha_app/providers/financial_analysis_provider.dart';
import 'package:alpha_app/providers/financial_profile_provider.dart';
import 'package:alpha_app/providers/financial_setup_provider.dart';
import 'package:alpha_app/providers/goal_provider.dart';
import 'package:alpha_app/providers/home_provider.dart';
import 'package:alpha_app/providers/income_provider.dart';
import 'package:alpha_app/providers/language_provider.dart';
import 'package:alpha_app/providers/leaderbord_provider.dart';
import 'package:alpha_app/providers/notification_provider.dart';
import 'package:alpha_app/providers/onboarding_provider.dart';
import 'package:alpha_app/providers/personal_provider.dart';
import 'package:alpha_app/providers/profile_provider.dart';
import 'package:alpha_app/providers/receipt_provider.dart';
import 'package:alpha_app/providers/reward_provider.dart'
    show RewardProvider;
import 'package:alpha_app/providers/themeprovider.dart';
import 'package:alpha_app/screens/auth/login.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final GlobalKey<NavigatorState> navigatorKey =
    GlobalKey<NavigatorState>();

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(
    SecurityContext? context,
  ) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (
        X509Certificate certificate,
        String host,
        int port,
      ) {
        return true;
      };
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = MyHttpOverrides();

  await EasyLocalization.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  final savedLanguage =
      prefs.getString('language_code') ?? 'en';

  final initialLocale =
      savedLanguage == 'ar'
          ? const Locale('ar')
          : const Locale('en');

  if (kDebugMode) {
    debugPrint(
      '\n=========================================',
    );

    debugPrint(
      'AlphaV3 Environment: '
      '${ApiConfig.environment.name.toUpperCase()}',
    );

    debugPrint(
      'API Base URL: ${ApiConfig.apiV1BaseUrl}',
    );

    debugPrint(
      'Current Language: ${initialLocale.languageCode}',
    );

    debugPrint(
      '=========================================\n',
    );
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ar'),
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: initialLocale,
      saveLocale: true,
      child: MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) =>
                Themeprovider()..loadtheme(),
          ),

          ChangeNotifierProvider(
            create: (_) =>
                LanguageProvider()
                  ..loadSavedLanguage(),
          ),

          ChangeNotifierProvider(
            create: (_) => AuthProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => OnboardingProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => IncomeProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => PersonalProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) =>
                FinancialProfileProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => FinancialProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => GoalProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => CycleProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => ChallengeProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => RewardProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => LeaderboardProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => ChatbotProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => HomeProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => ReceiptProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => ExpenseProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) =>
                FinancialAnalysisProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) =>
                NotificationProvider(),
          ),

          ChangeNotifierProvider(
            create: (_) => ProfileProvider(),
          ),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer2<
        Themeprovider,
        LanguageProvider>(
      builder: (
        context,
        themeProvider,
        languageProvider,
        child,
      ) {
        final locale = context.locale;

        return MaterialApp(
        
          debugShowCheckedModeBanner: false,
          navigatorKey: navigatorKey,
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeProvider.thememode,
          locale: locale,
          supportedLocales:
              context.supportedLocales,
          localizationsDelegates:
              context.localizationDelegates,
          home: const Login(),
        );
      },
    );
  }
}