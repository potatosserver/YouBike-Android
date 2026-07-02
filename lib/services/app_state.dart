import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart' as fm;
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/station.dart';

class AppState extends ChangeNotifier {
  // --- Settings & Preferences ---
  String currentRegion = 'kaohsiung';
  String currentLang = 'zh'; 
  bool isDarkMode = false;
  bool useLocation = true;
  
  // --- Pinned Stations ---
  Set<String> pinnedStationIds = {};

  // --- Location State ---
  LatLng center = const LatLng(22.6273, 120.3014); 
  bool isFollowingUser = false;
  bool hasObtainedRealLocation = false;
  bool isLoading = true;
  
  // --- Data State ---
  List<Station> allStations = [];
  List<Station> searchResults = [];
  // Use explicit fm.Marker to avoid name conflicts
  List<fm.Marker> stationMarkers = [];

  // --- Log System ---
  final List<String> logs = [];

  void addLog(String message) {
    final timestamp = DateTime.now().toIso8601String();
    logs.add('[$timestamp] $message');
    if (logs.length > 500) logs.removeAt(0);
    notifyListeners();
  }

  AppState() {
    _init();
  }

  Future<void> _init() async {
    addLog("Initializing AppState...");
    try {
      await loadSettings();
      await initializeLocation();
      await refreshStations();
    } catch (e) {
      addLog("Critical Init Error: $e");
    } finally {
      isLoading = false;
      addLog("Initialization complete.");
      notifyListeners();
    }
  }

  Future<void> loadSettings() async {
    addLog("Loading settings from SharedPreferences...");
    final prefs = await SharedPreferences.getInstance();
    currentRegion = prefs.getString('currentRegion') ?? 'kaohsiung';
    currentLang = prefs.getString('currentLang') ?? 'zh';
    isDarkMode = prefs.getBool('isDarkMode') ?? false;
    useLocation = prefs.getBool('useLocation') ?? true;
    final pinnedList = prefs.getStringList('pinnedStations') ?? [];
    pinnedStationIds = pinnedList.toSet();
    addLog("Settings loaded: Region=$currentRegion, Lang=$currentLang");
    notifyListeners();
  }

  Future<void> saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is String) await prefs.setString(key, value);
    else if (value is bool) await prefs.setBool(key, value);
    addLog("Setting saved: $key = $value");
  }

  // --- Location Methods ---

  Future<bool> requestPermission() async {
    addLog("Requesting location permission...");
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.always || permission == LocationPermission.whileInUse;
  }

  Future<Position?> getCurrentPosition() async {
    addLog("Fetching current position...");
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      addLog("getCurrentPosition error: $e");
      return null;
    }
  }

  Future<void> initializeLocation() async {
    addLog("Initializing location services...");
    if (!useLocation) {
      _useDefaultLocation();
      return;
    }
    try {
      bool hasPermission = await requestPermission();
      if (!hasPermission) {
        addLog("Location permission denied. Using default region.");
        _useDefaultLocation();
        return;
      }
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      center = LatLng(position.latitude, position.longitude);
      hasObtainedRealLocation = true;
      isFollowingUser = true;
      addLog("Obtained real location: ${center.latitude}, ${center.longitude}");
      Geolocator.getPositionStream(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 50),
      ).listen((Position pos) => _handleLocationUpdate(pos));
    } catch (e) {
      addLog("Location init error: $e");
      _useDefaultLocation();
    }
  }

  void _handleLocationUpdate(Position pos) {
    final newCenter = LatLng(pos.latitude, pos.longitude);
    if (isFollowingUser) {
      center = newCenter;
      notifyListeners();
    }
    addLog("Real-time location update: ${newCenter.latitude}, ${newCenter.longitude}");
  }

  void _useDefaultLocation() {
    final regions = {
      'taipei': const LatLng(25.0330, 121.5654),
      'newTaipei': const LatLng(25.0333, 121.5654),
      'taoyuan': const LatLng(24.8333, 121.3000),
      'kaohsiung': const LatLng(22.6273, 120.3014),
    };
    center = regions[currentRegion] ?? const LatLng(22.6273, 120.3014);
    isFollowingUser = false;
    hasObtainedRealLocation = false;
    addLog("Using default region: $currentRegion");
  }

  // --- Station Logic ---
  
  Future<void> refreshStations() async {
    addLog("Refreshing stations for region: $currentRegion...");
    notifyListeners();
  }

  void searchStations(String query) {
    addLog("Searching for: $query");
    notifyListeners();
  }

  // Composite Sorting: Pinned first -> then Distance
  List<Station> getSortedStations(List<Station> stations, LatLng userPos) {
    if (stations.isEmpty) return [];
    List<Station> sorted = List.from(stations);
    sorted.sort((a, b) {
      bool aPinned = pinnedStationIds.contains(a.id);
      bool bPinned = pinnedStationIds.contains(b.id);
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      double distA = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, a.lat, a.lng);
      double distB = Geolocator.distanceBetween(userPos.latitude, userPos.longitude, b.lat, b.lng);
      return distA.compareTo(distB);
    });
    return sorted;
  }

  void togglePinStation(String stationId) async {
    if (pinnedStationIds.contains(stationId)) {
      pinnedStationIds.remove(stationId);
    } else {
      pinnedStationIds.add(stationId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pinnedStations', pinnedStationIds.toList());
    addLog("Toggled pin for station: $stationId");
    notifyListeners();
  }

  void toggleFollowing() {
    isFollowingUser = !isFollowingUser;
    addLog("Following user: $isFollowingUser");
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    saveSetting('isDarkMode', isDarkMode);
    addLog("Dark mode toggle: $isDarkMode");
    notifyListeners();
  }

  void toggleLanguage() {
    currentLang = currentLang == 'zh' ? 'en' : 'zh';
    saveSetting('currentLang', currentLang);
    addLog("Language toggle: $currentLang");
    notifyListeners();
  }

  void setRegion(String region) {
    currentRegion = region;
    saveSetting('currentRegion', region);
    _useDefaultLocation();
    refreshStations();
    addLog("Region set to: $region");
  }
}
