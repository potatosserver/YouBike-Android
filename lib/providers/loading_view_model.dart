import 'dart:async';
import 'package:flutter/material.dart';

class LoadingViewModel with ChangeNotifier {
  bool isLoading = false;
  double loadingProgress = 0.0;
  String currentNotice = "init_starting";
  int? statusValue; // 用於存放動態數據（如站點數量）
  Timer? _progressTimer;

  // 分類管理通知
  final Map<String, String> technicalSteps = {
    "init_starting": "init_starting",
    "init_requesting_permission": "init_requesting_permission",
    "init_verifying_permission": "init_verifying_permission",
    "init_locating": "init_locating",
    "init_map_engine": "init_map_engine",
    "init_map_tiles": "init_map_tiles",
    "init_syncing": "init_syncing",
    "init_syncing_stations": "init_syncing_stations", // 新增：動態站點同步
    "init_clustering": "init_clustering",
    "init_updating": "init_updating",
    "init_success": "init_success",
  };

  final List<String> safetyTips = [
    "notice_no_phone",
    "notice_no_sidewalk",
    "notice_no_brake",
    "notice_seat_height",
    "notice_lights_work",
    "notice_insurance",
    "notice_take_belongings",
  ];

  void setLoading(bool value) {
    _progressTimer?.cancel();
    _progressTimer = null;
    isLoading = value;
    if (!value) {
      loadingProgress = 0.0;
      statusValue = null;
    }
    notifyListeners();
  }

  void setProgress(double progress) {
    _animateToProgress(progress.clamp(0.0, 100.0));
  }

  // 強化版更新狀態：支持傳入動態數值與進度
  void updateStatus(String key, {int? value, double? progress}) {
    currentNotice = key;
    statusValue = value;
    if (progress != null) {
      setProgress(progress);
    } else {
      notifyListeners();
    }
  }

  void simulatePercentage() {
    // 保留方法以兼容舊呼叫，但不再用於啟動流程。
    setProgress(loadingProgress);
  }

  void setFinished() {
    _progressTimer?.cancel();
    _progressTimer = null;
    isLoading = false;
    setProgress(100.0);
    currentNotice = "init_success";
    statusValue = null;
  }

  void _animateToProgress(double targetProgress) {
    if (!isLoading && targetProgress < 100.0) {
      loadingProgress = targetProgress;
      notifyListeners();
      return;
    }

    _progressTimer?.cancel();
    _progressTimer = null;

    if ((loadingProgress - targetProgress).abs() < 0.01) {
      loadingProgress = targetProgress;
      notifyListeners();
      return;
    }

    final stepSize = (targetProgress - loadingProgress).abs() > 10 ? 2.4 : 1.0;

    _progressTimer = Timer.periodic(const Duration(milliseconds: 16), (_) {
      final diff = targetProgress - loadingProgress;
      if (diff.abs() <= stepSize) {
        loadingProgress = targetProgress;
        _progressTimer?.cancel();
        _progressTimer = null;
        notifyListeners();
        return;
      }

      loadingProgress += diff > 0 ? stepSize : -stepSize;
      notifyListeners();
    });
  }
}
