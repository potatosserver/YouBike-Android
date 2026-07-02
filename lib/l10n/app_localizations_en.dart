// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'YouBike Finder';

  @override
  String get searchPlaceholder => 'Search for stations...';

  @override
  String get settings => 'Settings';

  @override
  String get location => 'My Location';

  @override
  String get refresh => 'Refresh';

  @override
  String get debug => 'Debug';

  @override
  String stationCount(num count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count stations found',
      one: '1 station found',
      zero: 'No stations found',
    );
    return '$_temp0';
  }

  @override
  String get recentStations => 'Recent Stations';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get about => 'About';

  @override
  String updatingIn(Object seconds) {
    return 'Updating in ${seconds}s';
  }

  @override
  String electricBikeDetailsTitle(Object name) {
    return 'Electric Bike Details: $name';
  }

  @override
  String get gettingBikeData => 'Fetching bike data...';

  @override
  String bikeNumber(Object no) {
    return 'Bike No: $no';
  }

  @override
  String pillarNumber(Object no) {
    return 'Pillar No: $no';
  }

  @override
  String batteryPower(Object power) {
    return 'Battery: $power%';
  }

  @override
  String get noElectricBikes => 'No electric bikes available';

  @override
  String electricBikeError(Object error) {
    return 'Failed to get electric bike info: $error';
  }

  @override
  String routeTo(Object name) {
    return 'Route to $name';
  }

  @override
  String get calculatingRoute => 'Calculating route...';

  @override
  String get routeNotFound => 'Route not found';

  @override
  String distance(Object dist) {
    return 'Distance: $dist';
  }

  @override
  String estimatedTime(Object time) {
    return 'Estimated Time: $time minutes';
  }

  @override
  String get retry => 'Retry';

  @override
  String get ok => 'OK';

  @override
  String loading(Object progress) {
    return 'Loading: $progress%';
  }

  @override
  String loadingNotice(Object notice) {
    return 'Notice: $notice';
  }
}
