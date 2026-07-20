import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:youbike/core/theme/theme_provider.dart';
import 'package:youbike/core/theme/brand_colors.dart';
import 'package:youbike/data/services/language_service.dart';
import 'package:youbike/core/l10n/app_localizations.dart';
import 'package:youbike/core/router/app_router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<ThemeProvider, LanguageService>(
      builder: (context, themeProvider, languageService, child) {
        return MaterialApp.router(
          title: 'YouBike',
          themeMode: themeProvider.themeMode,
          // 統一由 LanguageService 解析 locale — 避免重複維護 supportedLocales/_localeMap。
          locale: languageService.appLocale,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: AppRouter.router,
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
        );
      },
    );
  }

  /// 各 Brightness 對應的 ThemeData。ColorScheme 只算一次，避免 light/dark 雙重 build。
  ThemeData _buildTheme(Brightness brightness) {
    final cs = ColorScheme.fromSeed(
      seedColor: BrandColors.orange,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: cs,
      dialogTheme: DialogThemeData(
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
      ),
    );
  }
}
