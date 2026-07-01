import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/station.dart';

class AppState extends ChangeNotifier {
  final String apiBaseUrl = "https://apis.youbike.com.tw/json";
  final String apiEnBaseUrl = "https://apis.youbike.com.tw/json/en";
  final String realTimeApiUrl = "https://apis.youbike.com.tw/tw2/parkingInfo";
  
  LatLng center = const LatLng(22.631442, 120.30189);
  bool isLoading = true;
  bool isDarkMode = false;
  bool isFollowingUser = false;
  String currentLang = 'zh';
  String currentRegion = "Kaohsiung"; // Added to fix 'currentRegion' getter error
  int countdown = 30;
  
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
    isLoading = true;
    notifyListeners();
    try {
      await loadBaseStations();
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
      final url = currentLang == 'en' ? "$apiEnBaseUrl/station-min-yb2.json" : "$apiBaseUrl/station-min-yb2.json";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _allStations = data.map((json) => Station.fromJson(json)).whereType<Station>().toList();
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
      _searchResults = _allStations.where((s) {
        final q = query.toLowerCase();
        return s.nameTw.toLowerCase().contains(q) || 
               s.addressTw.toLowerCase().contains(q) || 
               s.nameEn.toLowerCase().contains(q) || 
               s.addressEn.toLowerCase().contains(q);
      }).toList();
      
      _sortStationsByDistance(_searchResults);
    }
    notifyListeners();
  }

  List<Station> getClosestStations(LatLng point, {int limit = 10}) {
    if (_allStations.isEmpty) return [];
    
    final sorted = List<Station>.from(_allStations);
    _sortStationsByDistance(sorted, point: point);
    return sorted.take(limit).toList();
  }

  void _sortStationsByDistance(List<Station> stations, {LatLng? point}) {
    final referencePoint = point ?? center;
    stations.sort((a, b) {
      final distA = const Distance().as(LengthUnit.Meter, LatLng(a.lat, a.lng), referencePoint);
      final distB = const Distance().as(LengthUnit.Meter, LatLng(b.lat, b.lng), referencePoint);
      return distA.compareTo(distB);
    });
  }

  Future<void> fetchRealTimeData(List<String> stationIds) async {
    if (stationIds.isEmpty) return;
    
    final batchSize = 20;
    for (int i = 0; i < stationIds.length; i += batchSize) {
      final batch = stationIds.sublist(i, i + batchSize > stationIds.length ? stationIds.length : i + batchSize);
      try {
        final response = await http.post(
          Uri.parse(realTimeApiUrl),
          headers: {
            'Content-Type': 'application/json',
            'Origin': 'https://www.youbike.com.tw',
            'Referer': 'https://www.youbike.com.tw/',
          },
          body: jsonEncode({'station_no': batch}),
        );
        
        if (response.statusCode == 200) {
          final result = json.decode(response.body);
          if (result['retCode'] == 1 && result['retVal'] != null && result['retVal']['data'] != null) {
            final List data = result['retVal']['data'];
            for (var item in data) {
              final id = item['station_no'].toString();
              final station = _allStations.firstWhere((s) => s.id == id, orElse: () => Station.empty());
              if (station != Station.empty()) {
                station.availableBikes = item['available_spaces_detail']?['yb2'] ?? 0;
                station.availableElectricBikes = item['available_spaces_detail']?['eyb'] ?? 0;
                station.emptySpaces = item['empty_spaces'] ?? 0;
              }
            }
            notifyListeners();
          }
        }
      } catch (e) {
        debugPrint("Error fetching real-time data: $e");
      }
    }
  }

  Future<void> refreshStations() async {
    await loadBaseStations();
    final closest = getClosestStations(center, limit: 50);
    await fetchRealTimeData(closest.map((s) => s.id).toList());
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
    loadBaseStations();
    notifyListeners();
  }
}
