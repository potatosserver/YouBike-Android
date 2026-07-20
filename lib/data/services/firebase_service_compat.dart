// firebase_service_compat.dart — 向後相容 wrapper（平台適配）
//
// 提供舊版 FirebaseService class，將方法轉發到細粒度模組。
// 平台適配策略：
//   - Web：import stub（無 Firebase 依賴）
//   - 原生：import 實作
//
// 此檔案會由 firebase_service.dart 祭出，對上層透明。

import 'firebase/firebase_core_stub.dart' if (dart.library.io) 'firebase/firebase_core_service.dart';
import 'firebase/firestore_device_stats_stub.dart' if (dart.library.io) 'firebase/firestore_device_stats_service.dart';

/// Firebase 服務整合（向後相容 wrapper）
///
/// 所有方法直接轉發到對應的細粒度模組。
/// 新程式碼建議直接使用：
///   - [FirebaseCoreService]
///   - [FirestoreDeviceStatsService]
///   - [FcmTokenService]
///   - [FcmMessageHandler]
// ignore: deprecated_member_use_from_same_package
class FirebaseService {
  static FirebaseService? _instance;

  FirebaseService._();

  static FirebaseService get instance {
    _instance ??= FirebaseService._();
    return _instance!;
  }

  bool get isInitialized => FirebaseCoreService.instance.isInitialized;

  /// 初始化 Firebase
  Future<void> init() => FirebaseCoreService.instance.ensureInitialized();

  /// 回報裝置活躍到 Firestore
  ///
  /// 警告：此方法已過時。新的實作需要傳入 [AppConfigService] 才能取得 appVersion，
  /// 請改用 `FirestoreDeviceStatsService.instance.reportAppActive(config)`。
  @Deprecated(
      'Pass AppConfigService explicitly. Use FirestoreDeviceStatsService.instance.reportAppActive(config) directly.')
  Future<void> reportAppActive() => _legacyReport();

  /// 刪除 Firestore 上的裝置紀錄
  Future<void> deleteDeviceStats() =>
      FirestoreDeviceStatsService.instance.deleteDeviceStats();

  /// 在沒有 AppConfigService 注入時的 fallback — 用靜態值。
  /// 應被視為 deprecated，使用者應 migrations 至新介面。
  Future<void> _legacyReport() async {
    // FirestoreDeviceStatsService.instance.reportAppActive(config) 必須傳 config，
    // 但本 compat 介面不能破壞現存 caller 簽名。仍走完整路徑：呼叫新介面但傳
    // 一個空實作不是選項（會丟失版本資訊）。
    // 解法：拋出明確錯誤提示呼叫端遷移。
    throw UnsupportedError(
        'FirebaseService.reportAppActive() 已過時，'
        '請改用 FirestoreDeviceStatsService.instance.reportAppActive(config) — '
        'config 為已 init 的 AppConfigService singleton。');
  }
}