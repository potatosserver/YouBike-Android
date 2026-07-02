import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../services/app_state.dart';
import '../widgets/pulse_marker.dart';
import '../widgets/station_card.dart';
import 'settings_page.dart';
import 'debug_screen.dart';
import '../models/station.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final MapController _mapController = MapController();

  void _handleLocationPress() async {
    final appState = Provider.of<AppState>(context, listen: false);
    await appState.requestPermission();
    
    if (appState.isFollowingUser) {
      appState.toggleFollowing();
    } else {
      appState.toggleFollowing();
      final pos = await appState.getCurrentPosition();
      if (pos != null) {
        _mapController.move(pos, 15.0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);

    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        children: [
          SlidingUpPanel(
            body: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: appState.center,
                    initialZoom: 18.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.youbike.finder',
                    ),
                    MarkerLayer(
                      markers: [
                        ...appState.stationMarkers,
                        Marker(
                          point: appState.center,
                          width: 40,
                          height: 40,
                          child: PulseMarker(
                            latitude: appState.center.latitude, 
                            longitude: appState.center.longitude,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            panel: _buildSearchAndRecentPanel(appState),
          ),
          
          Positioned(
            top: 60,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: 'loc_btn',
              onPressed: _handleLocationPress,
              backgroundColor: Colors.white,
              child: Icon(
                appState.isFollowingUser ? Icons.my_location : Icons.location_on,
                color: appState.isFollowingUser ? Colors.blue : Colors.black87,
              ),
            ),
          ),
          Positioned(
            bottom: 100,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: 'set_btn',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
              backgroundColor: Colors.white,
              child: const Icon(Icons.settings, color: Colors.black87),
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Center(
              child: FloatingActionButton.small(
                heroTag: 'ref_btn',
                onPressed: () => appState.refreshStations(),
                backgroundColor: Colors.white,
                child: const Icon(Icons.refresh, color: Colors.black87),
              ),
            ),
          ),
          Positioned(
            bottom: 160,
            left: 20,
            child: FloatingActionButton.small(
              heroTag: 'dbg_btn',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DebugScreen()),
                );
              },
              backgroundColor: Colors.redAccent,
              child: const Icon(Icons.bug_report, color: Colors.white),
            ),
          ),
          
          if (appState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchAndRecentPanel(AppState appState) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (val) => appState.searchStations(val),
              decoration: InputDecoration(
                hintText: "搜尋站點名稱...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
            ),
          ),
          Expanded(
            child: _buildResultsList(appState),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(AppState appState) {
    bool isSearching = appState.searchResults.isNotEmpty;
    List<Station> displayList = isSearching 
        ? appState.searchResults 
        : appState.getClosestStations(appState.center);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: displayList.length,
      itemBuilder: (context, index) {
        final s = displayList[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: StationCard(
            station: s,
            onTap: () {
              _mapController.move(LatLng(s.lat, s.lng), 16.0);
            },
          ),
        ),
      },
    );
  }
}
