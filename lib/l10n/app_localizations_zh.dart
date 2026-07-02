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

  @override
  String updatingIn(Object seconds) {
    return '更新於 ${seconds}s';
  }

  @override
  String electricBikeDetailsTitle(Object name) {
    return '電輔車詳細資訊: $name';
  }

  @override
  String get gettingBikeData => '正在獲取車輛資料...';

  @override
  String bikeNumber(Object no) {
    return '車號: $no';
  }

  @override
  String pillarNumber(Object no) {
    return '車位: $no';
  }

  @override
  String batteryPower(Object power) {
    return '電量: $power%';
  }

  @override
  String get noElectricBikes => '目前無可用電輔車';

  @override
  String electricBikeError(Object error) {
    return '獲取電輔車資訊失敗: $error';
  }

  @override
  String routeTo(Object name) {
    return '前往 $name 的路線';
  }

  @override
  String get calculatingRoute => '計算路線中...';

  @override
  String get routeNotFound => '找不到路線';

  @override
  String distance(Object dist) {
    return '距離: $dist';
  }

  @override
  String estimatedTime(Object time) {
    return '預計時間: $time 分鐘';
  }

  @override
  String get retry => '重整';

  @override
  String get ok => '確定';

  @override
  String loading(Object progress) {
    return '載入中：$progress%';
  }

  @override
  String loadingNotice(Object notice) {
    return '通知: $notice';
  }
}
