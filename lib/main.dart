import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youbike_android/data/services/language_service.dart';
import 'package:youbike_android/core/theme/theme_provider.dart';
import 'package:youbike_android/data/services/app_config_service.dart';
import 'package:youbike_android/core/utils/log_service.dart';
import 'package:youbike_android/providers/map_view_model.dart';
import 'package:youbike_android/providers/station_view_model.dart';
import 'package:youbike_android/providers/loading_view_model.dart';
import 'package:youbike_android/ui/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final log = LogService();
  log.i('APP_START', 'Initializing YouBike-Android startup sequence...');

  // 1. 預先初始化全局配置，確保第一幀渲染時數據就緒（零跳變）
  final configService = AppConfigService();
  await configService.init();
  
  final languageService = LanguageService();
  await languageService.loadLocale();
  
  log.i('APP_START', 'Configuration and Locale loaded. currentLang: ${configService.currentLang}');

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider.value(value: configService),
        ChangeNotifierProvider(create: (_) => LoadingViewModel()),
        ChangeNotifierProxyProvider<AppConfigService, MapViewModel>(
          create: (_) => MapViewModel(configService),
          update: (_, config, mapVm) => mapVm!..updateConfig(config),
        ),
        ChangeNotifierProxyProvider2<AppConfigService, MapViewModel, StationViewModel>(
          create: (_) => StationViewModel(configService, MapViewModel(configService)),
          update: (_, config, mapVm, stationVm) => stationVm!..updateDependencies(config, mapVm),
        ),
        ChangeNotifierProvider.value(value: languageService),
      ],
      child: const MyApp(),
    ),
  );
}
