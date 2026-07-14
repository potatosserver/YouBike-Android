import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:youbike_android/core/theme/theme_provider.dart';
import 'package:youbike_android/data/services/app_config_service.dart';
import 'package:youbike_android/core/l10n/app_localizations.dart';
import 'package:youbike_android/core/router/app_router.dart';

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
        return MaterialApp.router(
          title: 'YouBike',
          themeMode: themeProvider.themeMode,
          locale: _getLocale(config.currentLang),
          routerConfig: AppRouter.router,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.light,
              surface: Colors.white,
              onSurface: Colors.black87,
            ),
            dialogTheme: dialogTheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
              surface: const Color(0xFF121212),
              onSurface: Colors.white,
            ),
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
        );
      },
    );
  }
}
