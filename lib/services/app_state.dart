import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'dart:math' as math;
import '../models/station.dart';
import '../services/api_service.dart';
import 'package:flutter_map/flutter_map.dart';

class _VisualAnchor {
  final double lat;
  final double lon;
  int count;
  _VisualAnchor(this.lat, this.lon, {this.count = 0});
}

class AppState extends ChangeNotifier {
  LatLng center = const LatLng(22.631442, 120.301890);
  List<Station> _fullStationList = []; 
  List<Station> allStations = [];     
  Station? selectedStation;
  bool _isLoading = true;
  bool _isInitialLoadComplete = false;
  bool get isLoading => _isLoading;
  set isLoading(bool value) {
    if (_isInitialLoadComplete && value == true) return;
    _isLoading = value;
    notifyListeners();
  }
  int loadingProgress = 0;
  String currentNotice = "正在啟動...";
  List<String> logs = [];
  bool isFollowingUser = false;
  bool hasObtainedRealLocation = false;
  LatLng? lastKnownLocation;
  String currentLang = 'zh_TW';
  bool isDarkMode = false;
  int countdownRemaining = 60;
  String selectedRegion = 'kaohsiung';
  Set<String> pinnedStationIds = {};
  StreamSubscription<Position>? _locationSubscription;
  SharedPreferences? _prefs;
  final List<_VisualAnchor> _anchors = [];

  final Map<String, Map<String, dynamic>> _regions = {
    "taipei": {"name": "台北市", "lat": 25.047924, "lng": 121.517081},
    "newTaipei": {"name": "新北市", "lat": 25.0215339197085, "lng": 121.4568090197085},
    "taoyuan": {"name": "桃園市", "lat": 24.953671, "lng": 121.225783},
    "hsinchuCounty": {"name": "新竹縣", "lat": 24.826917615712, "lng": 121.01290295049},
    "hsinchuCity": {"name": "新竹市", "lat": 24.801815, "lng": 120.971459},
    "sciencePark": {"name": "新竹科學園區", "lat": 24.781830, "lng": 121.005074},
    "miaoli": {"name": "苗栗縣", "lat": 24.5648599, "lng": 120.8185503},
    "taichung": {"name": "台中市", "lat": 24.154712, "lng": 120.664265},
    "chiayi": {"name": "嘉義市", "lat": 23.4797837, "lng": 120.4397206},
    "tainan": {"name": "臺南市", "lat": 22.99230083082, "lng": 120.18509419659},
    "kaohsiung": {"name": "高雄市", "lat": 22.631442, "lng": 120.301890},
    "pingtung": {"name": "屏東縣", "lat": 22.683036253664, "lng": 120.48790854724},
    "taitung": {"name": "臺東縣", "lat": 22.755711056126138, "lng": 121.15035332587574},
  };

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000;
    final double dLat = (lat2 - lat1) * math.pi / 180;
    final double dLon = (lon2 - lon1) * math.pi / 180;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  LatLng getEffectiveLocation() {
    if (lastKnownLocation != null) return lastKnownLocation!;
    final region = _regions[selectedRegion]!;
    return LatLng(region['lat'] as double, region['lng'] as double);
  }

    void startTracking() {
    if (_locationSubscription != null) return;
    stopTracking();
    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((Position position) {
      lastKnownLocation = LatLng(position.latitude, position.longitude);
      center = lastKnownLocation!;
      
      if (isFollowingUser) {
        notifyListeners();
      }
      
      for (var s in allStations) {
        final d = _calculateDistance(center.latitude, center.longitude, s.lat, s.lng);
        s.distance = d;
      }
      notifyListeners();
    });
  }

  void stopTracking() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    isDarkMode = _prefs?.getBool('isDarkMode') ?? false;
    currentLang = _prefs?.getString('currentLang') ?? 'zh_TW';
    selectedRegion = _prefs?.getString('selectedRegion') ?? 'kaohsiung';
    final pinnedList = _prefs?.getStringList('pinnedStations') ?? [];
    pinnedStationIds = pinnedList.map((id) => id.trim()).toSet();
    final cachedLat = _prefs?.getDouble('last_lat');
    final cachedLng = _prefs?.getDouble('last_lng');
    if (cachedLat != null && cachedLng != null) {
      center = LatLng(cachedLat, cachedLng);
      lastKnownLocation = center;
    } else {
      setRegion(selectedRegion);
    }
    await _runWebStyleInit();
    startAutoRefreshCycle();
    notifyListeners();
  }

  Future<void> _runWebStyleInit() async {
    isLoading = true;
    _simulateLoadingProgress();
    _simulateRandomNotices();
    try {
      await fetchBaseData();
      await Future.wait([
        _initializeLocation(),
        refreshStations(isInitial: true),
      ]);
    } catch (e) {
      addLog("初始化失敗: $e");
    } finally {
      isLoading = false;
      _isInitialLoadComplete = true;
      loadingProgress = 100;
      currentNotice = "初始化完成";
      notifyListeners();
    }
  }

  Future<void> _initializeLocation() async {
    addLog("[LOC] 開始初始化位置...");
    try {
      final pos = await getCurrentPosition();
      if (pos != null) {
        addLog("[LOC] 成功獲取位置: ${pos.latitude}, ${pos.longitude}");
        lastKnownLocation = LatLng(pos.latitude, pos.longitude);
        center = lastKnownLocation!;
        _prefs?.setDouble('last_lat', lastKnownLocation!.latitude);
        _prefs?.setDouble('last_lng', lastKnownLocation!.longitude);
        hasObtainedRealLocation = true;
      } else {
        addLog("[LOC] 獲取位置返回 null，使用預設位置");
        useDefaultLocation();
      }
    } catch (e) {
      addLog("[LOC] 獲取位置發生異常: $e");
      useDefaultLocation();
    }
  }

  Future<void> fetchBaseData() async {
    try {
      final api = ApiService();
      _fullStationList = await api.fetchAllStations();
    } catch (e) {
      addLog("基礎數據獲取失敗: $e");
    }
  }

  Future<void> refreshStations({bool isInitial = false}) async {
    final sw = Stopwatch()..start();
    print("[API] 🌐 開始刷新站點數據...");
    try {
      final api = ApiService();
      if (_fullStationList.isEmpty) {
        _fullStationList = await api.fetchAllStations();
      }
      
      // 嘗試獲取最新位置
      final pos = await getCurrentPosition();
      final LatLng referencePoint = pos != null ? LatLng(pos.latitude, pos.longitude) : getEffectiveLocation();
      
      if (pos != null) {
        lastKnownLocation = referencePoint;
        hasObtainedRealLocation = true;
      }
      
      final sorted = List<Station>.from(_fullStationList);
      sorted.sort((a, b) {
        final distA = _calculateDistance(referencePoint.latitude, referencePoint.longitude, a.lat, a.lng);
        final distB = _calculateDistance(referencePoint.latitude, referencePoint.longitude, b.lat, b.lng);
        return distA.compareTo(distB);
      });
      
      allStations = [...sorted.where((s) => pinnedStationIds.contains(s.id.trim())), ...sorted.where((s) => !pinnedStationIds.contains(s.id.trim()))].take(10).toList();
      
      for (var s in allStations) {
        final d = _calculateDistance(referencePoint.latitude, referencePoint.longitude, s.lat, s.lng);
        s.distance = d;
      }
      
      final vehicleData = await api.fetchRealtimeVehicles(allStations.map((s) => s.id).toList());
      for (var s in allStations) {
        if (vehicleData.containsKey(s.id)) {
          final data = vehicleData[s.id] as Map<String, dynamic>;
          s.availableBikes = data['available_2_0'] ?? 0;
          s.availableElectricBikes = data['available_e'] ?? 0;
          s.emptySpaces = data['empty_spaces'] ?? 0;
        }
      }
    } catch (e) {
      addLog("刷新出錯: $e");
    } finally {
      print("[API] ✅ 站點數據更新完成. 花費時間: ${sw.elapsedMilliseconds}ms");
      if (!isInitial) {
        isLoading = false;
        countdownRemaining = 60;
        notifyListeners();
      }
    }
  }

  Future<void> _simulateLoadingProgress() async {
    int progress = 0;
    int lockedProgress = 85 + math.Random().nextInt(11);
    while (isLoading && progress < lockedProgress) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (progress < 85) {
        progress++;
      } else {
        if (math.Random().nextInt(5) == 0) progress++;
      }
      loadingProgress = progress;
      notifyListeners();
    }
  }

  Future<void> _simulateRandomNotices() async {
    final notices = currentLang.startsWith('en') 
      ? ["❌Do not speed", "❌Do not use phone", "✔️Check lights"]
      : ["❌勿超速", "❌勿使用手機", "✔️確認車燈"];
    while (isLoading) {
      currentNotice = notices[math.Random().nextInt(notices.length)];
      notifyListeners();
      await Future.delayed(const Duration(seconds: 2));
    }
  }

  void setRegion(String regionId) {
    if (!_regions.containsKey(regionId)) return;
    selectedRegion = regionId;
    final region = _regions[regionId]!;
    center = LatLng(region['lat'] as double, region['lng'] as double);
    _prefs?.setString('selectedRegion', regionId);
    addLog("切換區域至: ${region['name']}");
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    _prefs?.setBool('isDarkMode', isDarkMode);
    notifyListeners();
  }

  void setLanguage(String lang) {
    currentLang = lang;
    _prefs?.setString('currentLang', lang);
    notifyListeners();
  }

  void toggleFollowing() {
    isFollowingUser = !isFollowingUser;
    if (isFollowingUser) {
      startTracking();
    } else {
      stopTracking();
    }
    notifyListeners();
  }

  void togglePinStation(String id) {
    final tid = id.trim();
    if (pinnedStationIds.contains(tid)) {
      pinnedStationIds.remove(tid);
    } else {
      pinnedStationIds.add(tid);
    }
    _prefs?.setStringList('pinnedStations', pinnedStationIds.toList());
    notifyListeners();
  }

  String getDistanceLabel(double distance) {
    if (distance < 100) return "${distance.toStringAsFixed(0)}m";
    if (distance < 1000) return "${(distance / 1000).toStringAsFixed(1)}km";
    return "${(distance / 1000).toStringAsFixed(2)}km";
  }

  Future<Position?> getCurrentPosition() async {
    final sw = Stopwatch()..start();
    print("[LOC] 📡 發送定位請求中...");
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;
      
      // 增加超時時間到 20s，防止模擬器冷啟動 GPS 過慢導致返回 null
          print("[LOC] ✅ 定位成功! 花費時間: ${sw.elapsedMilliseconds}ms");
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
        timeLimit: const Duration(seconds: 5),
      ).timeout(const Duration(seconds: 6)); 
    } catch (e) {
      return null;
    }
  }

  void useDefaultLocation() {
    final region = _regions[selectedRegion]!;
    center = LatLng(region['lat'] as double, region['lng'] as double);
    lastKnownLocation = center;
    isFollowingUser = false;
    hasObtainedRealLocation = false;
    addLog("使用預設地區位置: ${region['name']}");
  }

  Future<void> requestPermission() async {
    print("[LOC] 🛡️ 請求定位權限...");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  void startAutoRefreshCycle() {
    Future.delayed(const Duration(seconds: 1), () {
      if (countdownRemaining > 0) {
        countdownRemaining--;
        notifyListeners();
        startAutoRefreshCycle();
      } else {
        refreshStations(isInitial: false).then((_) => startAutoRefreshCycle());
      }
    });
  }

  Future<void> searchStations(String query) async {
    try {
      final api = ApiService();
      if (_fullStationList.isEmpty) {
        _fullStationList = await api.fetchAllStations();
      }
      final filtered = _fullStationList.where((s) => 
        s.nameTw.contains(query) || 
        s.addressTw.contains(query) || 
        s.nameEn.toLowerCase().contains(query.toLowerCase()) || 
        s.addressEn.toLowerCase().contains(query.toLowerCase())
      ).toList();
      final LatLng referencePoint = getEffectiveLocation();
      filtered.sort((a, b) => 
        _calculateDistance(referencePoint.latitude, referencePoint.longitude, a.lat, a.lng)
        .compareTo(_calculateDistance(referencePoint.latitude, referencePoint.longitude, b.lat, b.lng))
      );
      final limit = query.isEmpty ? 10 : 50;
      final pinned = filtered.where((s) => pinnedStationIds.contains(s.id.trim())).toList();
      final unpinned = filtered.where((s) => !pinnedStationIds.contains(s.id.trim())).toList();
      allStations = [...pinned, ...unpinned].take(limit).toList();
      
      for (var s in allStations) {
        final d = _calculateDistance(referencePoint.latitude, referencePoint.longitude, s.lat, s.lng);
        s.distance = d;
      }
      notifyListeners();
    } catch (e) {}
  }

  void addLog(String msg) {
    logs.add("[${DateTime.now().toString().split('.').first}] $msg");
    if (logs.length > 100) logs.removeAt(0);
    notifyListeners();
  }
}
