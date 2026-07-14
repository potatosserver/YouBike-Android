import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';

enum LogLevel { debug, info, warning, error }

class LogService {
  static final LogService _instance = LogService._internal();
  factory LogService() => _instance;
  LogService._internal();

  /// 核心日誌打印方法
  void _log(LogLevel level, String tag, String message, {Object? error, StackTrace? stackTrace}) {
    if (kReleaseMode && level == LogLevel.debug) return;

    final timestamp = DateTime.now().toIso8601String().split('.').first;
    final levelStr = _getLevelString(level);
    final formattedMessage = '[$timestamp] [$levelStr] [$tag]: $message';

    switch (level) {
      case LogLevel.debug:
      case LogLevel.info:
        developer.log(formattedMessage, name: tag);
        break;
      case LogLevel.warning:
        developer.log(formattedMessage, name: tag, level: 900);
        break;
      case LogLevel.error:
        developer.log(formattedMessage, name: tag, level: 1000, error: error, stackTrace: stackTrace);
        break;
    }
  }

  String _getLevelString(LogLevel level) {
    switch (level) {
      case LogLevel.debug: return 'DEBUG';
      case LogLevel.info: return 'INFO';
      case LogLevel.warning: return 'WARN';
      case LogLevel.error: return 'ERROR';
    }
  }

  void d(String tag, String message) => _log(LogLevel.debug, tag, message);
  void i(String tag, String message) => _log(LogLevel.info, tag, message);
  void w(String tag, String message) => _log(LogLevel.warning, tag, message);
  void e(String tag, String message, {Object? error, StackTrace? stackTrace}) => 
      _log(LogLevel.error, tag, message, error: error, stackTrace: stackTrace);
}
