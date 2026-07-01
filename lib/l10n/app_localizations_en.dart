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
}
