import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../device_id_service.dart';
import '../app_config_service.dart';
import 'firebase_core_service.dart';
import 'fcm_service.dart';
import 'package:youbike/core/config/app_environment.dart';

/// Firestore device_stats 文件操作
///
/// 單一職責：管理 Firestore 上 `device_stats/{deviceId}` 文件的
/// 寫入（reportAppActive）與刪除（deleteDeviceStats）。
///
/// 依賴 [FirebaseCoreService] 確保 Firebase 已初始化，
/// 依賴 [FcmTokenService] 取得 FCM Token。
///
/// App version 與 display channel 統一由 [AppConfigService] / [AppEnvironment]
/// 提供，避免在此檔重複計算。
///
/// Web 使用 firestore_device_stats_stub.dart，由條件 import 排除此檔案。
class FirestoreDeviceStatsService {
  static FirestoreDeviceStatsService? _instance;

  FirestoreDeviceStatsService._();

  static FirestoreDeviceStatsService get instance {
    _instance ??= FirestoreDeviceStatsService._();
    return _instance!;
  }

  /// 回報裝置活躍狀態到 Firestore
  ///
  /// 自動初始化 Firebase（冪等）、取得 FCM Token、寫入 Firestore。
  /// 失敗不拋出例外，僅 log 錯誤。
  ///
  /// 需要來自 [config] 的 `appVersion`、`displayChannel` 等 runtime 值，
  /// 請於 AppConfigService.init() 完成後呼叫本 method。
  Future<void> reportAppActive(AppConfigService config) async {
    try {
      // 確保 Firebase 已初始化（冪等）
      await FirebaseCoreService.instance.ensureInitialized();
    } catch (e) {
      debugPrint('[FirestoreDeviceStats] Firebase 初始化失敗，略過回報: $e');
      return;
    }

    try {
      final deviceData = await DeviceIdHelper.getDeviceInfo();
      final deviceId = deviceData['id']!;
      final deviceModel = deviceData['model']!;
      final fcmToken = await FcmTokenService.instance.getToken();

      // 共用 AppConfigService.appVersion（init 階段讀取一次）與
      // AppEnvironment.displayChannel（靜態 String.fromEnvironment 解析），
      // 不再於本檔重複 PackageInfo.fromPlatform() 與 channel 雙分支。
      final appVersion = config.appVersion;
      final displayChannel = AppEnvironment.displayChannel;

      await FirebaseFirestore.instance
          .collection('device_stats')
          .doc(deviceId)
          .set({
        'last_active': FieldValue.serverTimestamp(),
        'platform': 'Android ($displayChannel)',
        'device_model': deviceModel,
        'fcm_token': fcmToken ?? '',
        'app_version': appVersion,
      }, SetOptions(merge: true));

      debugPrint('[FirestoreDeviceStats] 裝置活躍回報完成');
    } catch (e) {
      debugPrint('[FirestoreDeviceStats] 回報裝置活躍失敗: $e');
    }
  }

  /// 刪除 Firestore 上的裝置紀錄
  Future<void> deleteDeviceStats() async {
    // 如果沒有初始化過，跳過（沒有資料可刪）
    if (!FirebaseCoreService.instance.isInitialized) return;

    try {
      final deviceData = await DeviceIdHelper.getDeviceInfo();
      final deviceId = deviceData['id']!;

      await FirebaseFirestore.instance
          .collection('device_stats')
          .doc(deviceId)
          .delete();

      debugPrint('[FirestoreDeviceStats] 裝置紀錄已刪除');
    } catch (e) {
      debugPrint('[FirestoreDeviceStats] 刪除裝置紀錄失敗: $e');
    }
  }
}