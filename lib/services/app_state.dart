import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/station.dart';

class AppState extends ChangeNotifier {
  // Configuration
  final String apiBaseUrl = "https://apis.youbike.com.tw/json";
  final String apiEnBaseUrl = "https://apis.youbike.com.tw/json/en"; // For English API
  
  // State
  LatLng center = const LatLng(22.631442, 120.30189);
  bool isLoading = true;
  bool isDarkMode = false;
  bool isFollowingUser = false;
  String currentLang = 'zh';
  String currentRegion = 'kaohsiung';
  int countdown = 30;
  
  // Data
  List<Station> _allStations = [];
  List<Station> _searchResults = [];
  List<Marker> stationMarkers = [];

  List<Station> get allStations => _allStations;
  List<Station> get searchResults => _searchResults;

  AppState() {
    _initialize();
    _startTimer();
  }

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();
    try {
      await Future.wait([
        loadBaseStations(),
      ]);
    } catch (e) {
      debugPrint("Critical Initialization Error: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        countdown--;
      } else {
        countdown = 30;
        refreshStations();
      }
      notifyListeners();
    });
  }

  Future<void> loadBaseStations() async {
    try {
      // Dynamic URL based on language
      final url = currentLang == 'en' 
          ? "$apiEnBaseUrl/station-min-yb2.json" 
          : "$apiBaseUrl/station-min-yb2.json";
          
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allStations = data
            .map((json) => Station.fromJson(json))
            .whereType<Station>()
            .toList();
        _generateMarkers();
      }
    } catch (e) {
      debugPrint("Error loading base stations: $e");
    }
  }

  void _generateMarkers() {
    stationMarkers = _allStations.map((s) {
      return Marker(
        point: LatLng(s.lat, s.lng),
        width: 30,
        height: 30,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26)],
          ),
          child: const Icon(Icons.location_on, color: Colors.white, size: 16),
        ),
      );
    }).toList();
    notifyListeners();
  }

  void searchStations(String query) {
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      _searchResults = _allStations
          .where((s) => s.nameTw.contains(query) || s.addressTw.contains(query))
          .toList();
    }
    notifyListeners();
  }

  List<Station> getClosestStations(LatLng point, {int limit = 10}) {
    if (_allStations.isEmpty) return [];
    
    final distanceList = _allStations.map((s) {
      final distance = const Distance().as(
        LengthUnit.Meter, 
        LatLng(s.lat, s.lng), 
        point
      );
      return (station: s, distance: distance);
    }).toList();

    distanceList.sort((a, b) => a.distance.compareTo(b.distance));
    return distanceList.take(limit).map((pair) => pair.station).toList();
  }

  Future<void> refreshStations() async {
    await loadBaseStations();
    notifyListeners();
  }

  Future<void> requestPermission() async {
    return Future.value();
  }

  void toggleFollowing() {
    isFollowingUser = !isFollowingUser;
    notifyListeners();
  }

  Future<LatLng?> getCurrentPosition() async {
    return null;
  }

  void updateCenter(LatLng newCenter) {
    center = newCenter;
    notifyListeners();
  }

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }

  void setLanguage(String lang) {
    currentLang = lang;
    // Trigger data reload to get English API data
    loadBaseStations();
    notifyListeners();
  }
}
