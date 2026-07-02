import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../models/station.dart';
import '../services/app_state.dart';
import '../services/api_service.dart';
import '../services/route_service.dart';
import '../widgets/app_theme.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/station_card.dart';
import '../widgets/route_detail_panel.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final MapController _mapController = MapController();

  void _handleLocationPress() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.requestPermission();
    
    if (appState.isFollowingUser) {
      appState.toggleFollowing();
    } else {
      appState.toggleFollowing();
      if (appState.lastKnownLocation != null) {
        _mapController.move(appState.lastKnownLocation!, 15.0);
      } else {
        final pos = await appState.getCurrentPosition();
        if (pos != null) {
          _mapController.move(LatLng(pos.latitude, pos.longitude), 15.0);
        }
      }
    }
  }

  void _showRoutePanel(Station station) async {
    final appState = Provider.of<AppState>(context, listen: false);
    final routeService = RouteService();
    
    final steps = await routeService.getRoute(
      appState.center, 
      LatLng(station.lat, station.lng), 
      appState.currentLang
    );

    if (!mounted) return;

    if (steps.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(appState.currentLang == 'zh' ? "找不到路線" : "Route not found"))
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => RouteDetailPanel(
        destination: station.nameTw,
        steps: steps.map((s) => "${s.instruction} (${(s.distance / 1000).toStringAsFixed(2)} km)").toList(),
      ),
    );
  }

  void _showStationDetails(Station station) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(station.nameTw),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: ApiService().fetchElectricBikeDetails(station.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final appState = Provider.of<AppState>(context, listen: false);
              if (snapshot.hasError) {
                return Text(appState.currentLang == 'en' 
                    ? "Failed to get electric bike info: ${snapshot.error}" 
                    : "獲取電輔車資訊失敗: ${snapshot.error}");
              }
              
              final bikes = snapshot.data ?? [];
              if (bikes.isEmpty) {
                return Text(appState.currentLang == 'en' ? "No electric bikes available" : "目前無可用電輔車");
              }
              
              bikes.sort((a, b) => (b['battery_power'] as num).compareTo(a['battery_power'] as num));
              
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: bikes.map((bike) => ListTile(
                  leading: const Icon(Icons.directions_bike),
                  title: Text("車號: ${bike['bike_no']}"),
                  subtitle: Text("車位: ${bike['pillar_no']}"),
                  trailing: Text("${bike['battery_power']}%", 
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                )).toList(),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Builder(
              builder: (context) {
                final appState = Provider.of<AppState>(context, listen: false);
                return Text(appState.currentLang == 'en' ? "OK" : "確定");
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      body: Stack(

        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: appState.center,
              initialZoom: 15.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.youbike.android',
              ),
              MarkerLayer(markers: appState.stationMarkers),
              MarkerLayer(
                markers: [
                  Marker(
                    point: appState.center,
                    width: 20,
                    height: 20,
                    child: const Icon(Icons.my_location, color: Colors.blue, size: 20),
                  ),
                ],
              ),
            ],
          ),
          
          // Search Bar
          Positioned(
            top: 50,
            left: 20,
            right: 20,
            child: TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFFE8D6),
                hintText: appState.currentLang == 'en' ? "Search stations..." : "搜尋站點...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (val) => appState.searchStations(val),
            ),
          ),
          
          // Location Button
          Positioned(
            bottom: 100,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: 'loc_btn',
              onPressed: _handleLocationPress,
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: appState.isFollowingUser ? const Color(0xFF007BFF) : Colors.black87,
              ),
            ),
          ),
          
          // Refresh Pill
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDCACB),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "${appState.currentLang == 'en' ? 'Updating in' : '更新於'} ${appState.countdownRemaining}s",
                      style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        appState.countdownRemaining = 60;
                        appState.refreshStations();
                      },
                      child: const Icon(Icons.play_arrow, size: 18, color: Colors.black87),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          if (appState.isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }
}
