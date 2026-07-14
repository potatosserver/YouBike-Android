import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:youbike_android/screens/settings_screen.dart';
import 'package:youbike_android/screens/theme_selection_screen.dart';
import 'package:youbike_android/screens/region_selection_screen.dart';
import 'package:youbike_android/screens/language_selection_screen.dart';
import 'package:youbike_android/services/theme_provider.dart';
import 'package:youbike_android/services/app_config_service.dart';
import 'package:youbike_android/l10n/app_localizations.dart';
import 'package:youbike_android/widgets/app_wrapper.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Locale _getLocale(String lang) {
    if (lang == 'en') return const Locale('en', 'US');
    return const Locale('zh', 'TW');
  }

  @override
  Widget build(BuildContext context) {
    final dialogTheme = DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
    );

    return Consumer2<ThemeProvider, AppConfigService>(
      builder: (context, themeProvider, config, child) {
        return MaterialApp(
          title: 'YouBike',
          themeMode: themeProvider.themeMode,
          locale: _getLocale(config.currentLang),
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.light,
            dialogTheme: dialogTheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.deepPurple,
            brightness: Brightness.dark,
            dialogTheme: dialogTheme,
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'TW'),
            Locale('en', 'US'),
          ],
          home: const AppWrapper(),
          routes: {
            '/settings': (context) => const SettingsScreen(),
            '/theme-selection': (context) => const ThemeSelectionScreen(),
            '/region-selection': (context) => const RegionSelectionScreen(),
            '/language-selection': (context) => const LanguageSelectionScreen(),
          },
        );
      },
    );
  }
}
