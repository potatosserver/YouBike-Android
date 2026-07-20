import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:youbike/core/theme/theme_provider.dart';
import 'package:youbike/core/theme/brand_colors.dart';
import 'package:youbike/data/services/app_config_service.dart';
import 'package:youbike/core/l10n/app_localizations.dart';
import 'package:youbike/core/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Map<String, Locale> _localeMap = {
    'en': Locale('en'),
    'zh': Locale('zh'),
  };

  static const List<Locale> supportedLocales = [
    Locale('zh'),
    Locale('en'),
  ];

  Locale _getLocale(String lang) => _localeMap[lang] ?? const Locale('zh');

  @override
  Widget build(BuildContext context) {
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
              seedColor: BrandColors.orange,
              brightness: Brightness.light,
            ),
            dialogTheme: _buildDialogTheme(Brightness.light),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: BrandColors.orange,
              brightness: Brightness.dark,
            ),
            dialogTheme: _buildDialogTheme(Brightness.dark),
          ),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: supportedLocales,
        );
      },
    );
  }

  DialogThemeData _buildDialogTheme(Brightness brightness) {
    // 以 brightness 對應的 ColorScheme.fromSeed 計算需用的 onSurface，
    // 由於這裡拿不到 theme，這條 helper 改由呼叫端提供 colorScheme。
    // 實際做法：建立 ColorScheme 後組 DialogThemeData。
    final cs = ColorScheme.fromSeed(
      seedColor: BrandColors.orange,
      brightness: brightness,
    );
    return DialogThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: cs.surface,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 20,
        color: cs.onSurface,
      ),
      contentTextStyle: TextStyle(
        fontSize: 14,
        color: cs.onSurfaceVariant,
      ),
    );
  }
}
