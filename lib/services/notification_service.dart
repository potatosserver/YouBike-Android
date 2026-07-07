import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:math' as math;

enum NotificationType { info, success, error }

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  static const List<String> _notices = [
    "YouBike 2.0 讓通勤更方便！",
    "記得騎乘完畢後將車輛停在正確的站牌區域喔！",
    "使用 YouBike 減少碳排放，保護地球環境。",
    "發現 YouBike 故障？請透過官方 App 通報。",
    "嘗試探索不同的騎乘路徑，發現城市的另一面。",
    "YouBike 2.0E 電動單車，讓爬坡不再吃力！",
    "騎乘 YouBike 前，請檢查煞車與輪胎狀態。",
  ];

  String getRandomNotice() {
    return _notices[math.Random().nextInt(_notices.length)];
  }

  void show({
    required String message,
    NotificationType type = NotificationType.info,
  }) {
    // WalkGo Style: 100% Native. 
    // Do not specify colors to let the Android OS handle the system theme.
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      fontSize: 14.0,
    );
    
    debugPrint("[Notification] [${type.name.toUpperCase()}] $message");
  }
}
