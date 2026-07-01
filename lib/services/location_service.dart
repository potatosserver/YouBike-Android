import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

enum LocationPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  serviceDisabled,
}

class LocationService {
  /// 檢查並請求位置權限
  /// 返回權限狀態，以便 UI 顯示對應的提示 (模仿網頁版的 permissionModal)
  Future<LocationPermissionStatus> requestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. 檢查定位服務是否開啟
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationPermissionStatus.serviceDisabled;
    }

    // 2. 檢查目前權限狀態
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // 請求權限
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationPermissionStatus.permanentlyDenied;
    }

    return LocationPermissionStatus.granted;
  }

  /// 獲取單次當前位置
  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// 獲取位置實時流 (模仿 locationTracker.js 的 watchPosition)
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 每移動 10 公尺更新一次
      ),
    );
  }
}
