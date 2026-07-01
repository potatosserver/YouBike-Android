// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'YouBike 站點搜尋';

  @override
  String get searchPlaceholder => '搜尋站點名稱...';

  @override
  String get settings => '設定';

  @override
  String get location => '我的位置';

  @override
  String get refresh => '重新整理';

  @override
  String get debug => '偵錯';

  @override
  String stationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '找到 $count 個站牌',
      one: '找到 1 個站牌',
      zero: '找不到站牌',
    );
    return '$_temp0';
  }

  @override
  String get recentStations => '最近站牌';

  @override
  String get darkMode => '深色模式';

  @override
  String get language => '語言';

  @override
  String get about => '關於';
}
