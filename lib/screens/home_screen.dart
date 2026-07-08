import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:latlong2/latlong.dart' as ll;
import '../models/station.dart';
import '../services/app_state.dart';
import '../widgets/station_card.dart';
import '../widgets/route_detail_panel.dart';
import '../widgets/electric_bike_modal.dart';
import '../widgets/loading_overlay.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapLibreMapController? _mapController;
  double? _panelHeight; 
  bool _isMapLoaded = false; 
  List<Station>? _lastRenderedStations; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final screenHeight = MediaQuery.of(context).size.height;
      setState(() {
        _panelHeight = screenHeight * 0.35;
      });
      
      final appState = Provider.of<AppState>(context, listen: false);
      appState.addListener(_onAppStateChanged);
    });
  }

  @override
  void dispose() {
    Provider.of<AppState>(context, listen: false).removeListener(_onAppStateChanged);
    super.dispose();
  }

  void _updateStationMarkers() {
    if (_mapController == null || !_isMapLoaded) {
      debugPrint("[MAP-SYNC] Skipping markers: Controller null or Map not loaded");
      return;
    }
    
    final appState = Provider.of<AppState>(context, listen: false);
    final stations = appState.allStations;
    
    if (_lastRenderedStations != null && 
        _lastRenderedStations!.length == stations.length &&
        _lastRenderedStations!.every((s) => s.id == stations[appState.allStations.indexOf(s)].id)) {
      return;
    }

    debugPrint("[MAP-SYNC] Rendering ${stations.length} stations...");
    _mapController!.clearSymbols();
    _mapController!.clearCircles();

    for (var s in stations) {
      // 1. Add a visible gold circle as the "pin" base
      _mapController!.addCircle(CircleOptions(
        geometry: LatLng(s.lat, s.lng),
        circleRadius: 5.0,
        circleColor: '#FFD700', // Gold
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2.0,
      ));

      // 2. Add the text label above the circle
      _mapController!.addSymbol(SymbolOptions(
        geometry: LatLng(s.lat, s.lng),
        textField: s.nameTw,
        textOffset: const Offset(0, 12),
        textSize: 12.0,
        textColor: '#000000',
      ));
    }
    _lastRenderedStations = List.from(stations);
    debugPrint("[MAP-SYNC] Rendering complete.");
  }

  void _onAppStateChanged() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isFollowingUser && appState.center != null) {
      _animateMapTo(appState.center!);
    }
    _updateStationMarkers();
  }

  void _animateMapTo(ll.LatLng position, {double zoom = 18.0}) {
    _mapController?.animateCamera(CameraUpdate.newLatLngZoom(
      LatLng(position.latitude, position.longitude), 
      zoom
    ));
  }

  void _handleLocationPress() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    ll.LatLng snapPos = appState.lastKnownLocation ?? appState.getEffectiveLocation();
    
    _animateMapTo(snapPos);
    
    NotificationService.instance.show(
      message: l10n.locationTrackingEnabled, 
      type: NotificationType.success
    );
    appState.setFollowing(true);
    try {
      await appState.requestPermission();
      final pos = await appState.getCurrentPosition();
      if (pos != null && mounted) {
        _animateMapTo(ll.LatLng(pos.latitude, pos.longitude));
      }
    } catch (e) {
      debugPrint("[LOC-ERROR] $e");
    }
  }

  void _showRoutePanel(Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => RouteDetailPanel(
        destination: station.nameTw,
        destLat: station.lat,
        destLng: station.lng,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final screenHeight = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final currentPanelHeight = _panelHeight != null && _panelHeight! > 0 
        ? _panelHeight! 
        : (screenHeight * 0.35 > 0 ? screenHeight * 0.35 : 300.0);

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          if (appState.center != null)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              bottom: currentPanelHeight + 8, 
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                child: MapLibreMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(appState.center!.latitude, appState.center!.longitude),
                    zoom: 18.0,
                  ),
                  styleString: 'https://tiles.openfreemap.org/styles/liberty',
                  myLocationEnabled: true,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                  onStyleLoadedCallback: () {
                    _isMapLoaded = true;
                    _updateStationMarkers();
                  },
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),
          Positioned(
            top: 40, 
            right: 15,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.settings, 
                    size: 22, 
                    color: theme.brightness == Brightness.dark ? const Color(0xFF90CAF9) : Colors.black87
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            bottom: currentPanelHeight + 20, 
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? const Color(0xFF222222) : const Color(0xFFFDCACB),
                borderRadius: BorderRadius.circular(12), 
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: IconButton(
                icon: Icon(
                  Icons.my_location, 
                  size: 22, 
                  color: theme.brightness == Brightness.dark ? const Color(0xFF90CAF9) : Colors.black87,
                ),
                onPressed: _handleLocationPress,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: currentPanelHeight,
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFFFF5F0),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1), 
                    blurRadius: 15, 
                    offset: const Offset(0, -5)
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.max, // FIX: Fill the bounded Positioned height
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onVerticalDragUpdate: (details) {
                      setState(() {
                        _panelHeight = (currentPanelHeight) - details.delta.dy;
                        _panelHeight = _panelHeight!.clamp(screenHeight * 0.2, screenHeight * 0.8);
                      });
                    },
                    child: Container(
                      width: double.infinity,
                      height: 24,
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      child: Center(
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.4, 
                          height: 6, 
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark ? Colors.white38 : const Color(0xFFBBBBBB), 
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                              filled: true, 
                              fillColor: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF),
                              hintText: l10n.input_placeholder,
                              prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15), 
                                borderSide: BorderSide.none
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 0),
                            ),
                            onSubmitted: (val) => appState.searchStations(val),
                            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                          ),
                          const SizedBox(height: 12),
                          Expanded(child: _buildStationPanel()),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 30, left: 0, right: 0,
            child: const HomeUpdateButton(),
          ),
          if (appState.isLoading) const LoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildStationPanel() {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    
    if (appState.allStations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              l10n.noStationsFound,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: appState.allStations.length,
      itemBuilder: (context, index) {
        final station = appState.allStations[index];
        return StationCard(
          station: station,
          onTap: () {},
          onNavigate: () => _showRoutePanel(station),
          onShowElectric: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
              builder: (context) => ElectricBikeDetailsModal(stationId: station.id, stationName: station.nameTw),
            );
          },
        );
      },
    );
  }
}

class HomeUpdateButton extends StatefulWidget {
  const HomeUpdateButton({super.key});
  @override
  State<HomeUpdateButton> createState() => _HomeUpdateButtonState();
}

class _HomeUpdateButtonState extends State<HomeUpdateButton> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _wasUpdating = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
      upperBound: 0.5,
    );
    
    final appState = Provider.of<AppState>(context, listen: false);
    appState.addListener(_handleUpdateAnimation);
    _wasUpdating = appState.isUpdating;
  }

  void _handleUpdateAnimation() {
    final appState = Provider.of<AppState>(context, listen: false);
    if (appState.isUpdating) {
      if (!_wasUpdating) {
        _controller.forward(from: 0.0);
        _wasUpdating = true;
      }
    } else {
      if (_wasUpdating) {
        _controller.stop();
        _controller.reset();
        _wasUpdating = false;
      }
    }
  }

  @override
  void dispose() {
    final appState = Provider.of<AppState>(context, listen: false);
    appState.removeListener(_handleUpdateAnimation);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Center(
      child: GestureDetector(
        onTap: appState.isUpdating ? null : () {
          appState.refreshStations();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark ? const Color(0xFF4A4A4A) : const Color(0xFFFDCACB),
            borderRadius: BorderRadius.circular(50),
            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              RotationTransition(
                turns: _controller,
                child: Icon(
                  Icons.autorenew, 
                  size: 20, 
                  color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                "${appState.countdownRemaining}${l10n.countdown_unit}${l10n.countdown_text}",
                style: TextStyle(
                  color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
