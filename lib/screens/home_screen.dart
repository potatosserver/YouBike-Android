import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:latlong2/latlong.dart' as ll;
import 'dart:ui' as ui;
import 'dart:async';
import 'package:flutter/services.dart';
import '../models/station.dart';
import '../services/app_state.dart';
import '../widgets/station_card.dart';
import '../widgets/route_detail_panel.dart';
import '../widgets/electric_bike_modal.dart';
import '../services/notification_service.dart';
import '../l10n/app_localizations.dart';

const String openFreeMapStyle = "https://tiles.openfreemap.org/styles/liberty";

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  MapLibreMapController? _mapController;
  late ValueNotifier<double> _panelHeightNotifier;
  bool _isMapLoaded = false;
  int _lastRenderedCount = 0;

  @override
  void initState() {
    super.initState();
    _panelHeightNotifier = ValueNotifier<double>(0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final appState = Provider.of<AppState>(context, listen: false);
      appState.addListener(_onAppStateChanged);
      final screenHeight = MediaQuery.of(context).size.height;
      _panelHeightNotifier.value = screenHeight * 0.35;
    });
  }

  @override
  void dispose() {
    Provider.of<AppState>(context, listen: false).removeListener(_onAppStateChanged);
    _panelHeightNotifier.dispose();
    super.dispose();
  }

  void _onAppStateChanged() {
    final appState = Provider.of<AppState>(context, listen: false);
    
    if (appState.isFollowingUser && appState.center != null) {
      _animateMapTo(appState.center!);
    }
    
    if (_isMapLoaded && appState.allStations.length != _lastRenderedCount) {
      debugPrint("[MAP-SYNC] Data changed ($_lastRenderedCount -> ${appState.allStations.length}), re-rendering...");
      _renderStationsChunked(appState.allStations);
    }
  }

  void _animateMapTo(ll.LatLng position) {
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(position.latitude, position.longitude), 18.0),
    );
  }

  void _handleLocationPress() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    ll.LatLng snapPos = appState.lastKnownLocation ?? appState.getEffectiveLocation();
    _animateMapTo(snapPos);
    NotificationService.instance.show(message: l10n.locationTrackingEnabled, type: NotificationType.success);
    appState.setFollowing(true);
    try {
      await appState.requestPermission();
      final pos = await appState.getCurrentPosition();
      if (pos != null && mounted) _animateMapTo(ll.LatLng(pos.latitude, pos.longitude));
    } catch (e) {
      debugPrint("[LOC-ERROR] $e");
    }
  }

  void _showRoutePanel(Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => RouteDetailPanel(destination: station.nameTw, destLat: station.lat, destLng: station.lng),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final theme = Theme.of(context);
    final screenHeight = MediaQuery.of(context).size.height;

    final mapLayer = RepaintBoundary(
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
        child: MapLibreMap(
          styleString: openFreeMapStyle,
          onMapCreated: (controller) => _mapController = controller,
          initialCameraPosition: CameraPosition(
            target: LatLng(
              appState.center?.latitude ?? appState.getEffectiveLocation().latitude,
              appState.center?.longitude ?? appState.getEffectiveLocation().longitude,
            ),
            zoom: 18.0,
          ),
          onStyleLoadedCallback: () async {
            await Future.delayed(const Duration(milliseconds: 200));
            _isMapLoaded = true;
            debugPrint("[MAP-BOOT] Style loaded, composing composite icons...");
            await _loadBikeIcons();
            await _renderStationsChunked(appState.allStations);
          },
          myLocationEnabled: false,
        ),
      ),
    );

    final panelLayer = RepaintBoundary(
      child: _BottomPanel(
        appState: appState,
        heightNotifier: _panelHeightNotifier,
        screenHeight: screenHeight,
        onStationTap: (station) {
          appState.setFollowing(false);
          _animateMapTo(ll.LatLng(station.lat, station.lng));
        },
        onNavigate: _showRoutePanel,
      ),
    );

    return Scaffold(
      backgroundColor: theme.brightness == Brightness.dark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          ValueListenableBuilder<double>(
            valueListenable: _panelHeightNotifier,
            builder: (context, panelHeight, child) {
              if (appState.center == null) return const Center(child: CircularProgressIndicator());
              return Stack(
                children: [
                  Positioned(
                    top: 0, left: 0, right: 0, bottom: panelHeight + 12,
                    child: mapLayer,
                  ),
                  Positioned(
                    right: 20, bottom: panelHeight + 20,
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.brightness == Brightness.dark ? const Color(0xFF222222) : const Color(0xFFFDCACB),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: IconButton(
                        icon: Icon(Icons.my_location, size: 22, color: theme.brightness == Brightness.dark ? const Color(0xFF90CAF9) : Colors.black87),
                        onPressed: _handleLocationPress,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0, left: 0, right: 0, height: panelHeight,
                    child: panelLayer,
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 40, right: 15,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/settings'),
              child: Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Center(
                  child: Icon(Icons.settings, size: 22, color: theme.brightness == Brightness.dark ? const Color(0xFF90CAF9) : Colors.black87),
                ),
              ),
            ),
          ),
          const Positioned(
            bottom: 30, left: 0, right: 0,
            child: HomeUpdateButton(),
          ),
        ],
      ),
    );
  }

  Future<void> _loadBikeIcons() async {
    if (_mapController == null) return;
    try {
      // 1. Load the PNG asset
      final ByteData data = await rootBundle.load('assets/icons/bike_icon.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo frame = await codec.getNextFrame();
      final ui.Image bikeImage = frame.image;

      // 2. Setup Canvas for composition (64x64)
      const double size = 64.0;
      final ui.PictureRecorder recorder = ui.PictureRecorder();
      final ui.Canvas canvas = ui.Canvas(recorder);
      final ui.Paint paint = ui.Paint()..color = const Color(0xFFFFD700); // YouBike Yellow

      // 3. Draw Background Circle
      canvas.drawCircle(
        const Offset(size / 2, size / 2), 
        size / 2, 
        paint
      );

      // 4. Draw Bike Image centered on top
      const double imageSize = 40.0;
      const double offset = (size - imageSize) / 2;
      const Rect destRect = Rect.fromLTWH(offset, offset, imageSize, imageSize);
      
      canvas.drawImageRect(
        bikeImage,
        Rect.fromLTWH(0, 0, bikeImage.width.toDouble(), bikeImage.height.toDouble()),
        destRect,
        ui.Paint(),
      );

      // 5. Convert composition to bytes
      final ui.Picture picture = recorder.endRecording();
      final ui.Image compositeImage = await picture.toImage(size.toInt(), size.toInt());
      final ByteData? compositeData = await compositeImage.toByteData(format: ui.ImageByteFormat.png);
      final Uint8List compositeBytes = compositeData!.buffer.asUint8List();

      // 6. Inject into MapLibre
      await _mapController!.addImage('bike-icon', compositeBytes);
      debugPrint("[MAP-BOOT] Composite icon 'bike-icon' (Yellow Circle + PNG) loaded successfully.");
    } catch (e) {
      debugPrint("[MAP-BOOT] Error composing asset icon: $e");
    }
  }

  Future<void> _renderStationsChunked(List<Station> stations) async {
    if (!_isMapLoaded || _mapController == null) return;
    
    _lastRenderedCount = stations.length;
    
    const int chunkSize = 20;
    debugPrint("[MAP-BOOT] Rendering ${stations.length} stations in chunks...");
    for (int i = 0; i < stations.length; i += chunkSize) {
      if (!mounted) return;
      final chunk = stations.skip(i).take(chunkSize);
      for (var s in chunk) {
        await _mapController!.addSymbol(
          SymbolOptions(
            geometry: LatLng(s.lat, s.lng),
            iconImage: 'bike-icon',
            iconSize: 0.6,
            textField: s.nameTw,
            textOffset: const Offset(0, 1.5),
            textHaloColor: "#FFFFFF",
            textHaloWidth: 1.0,
          ),
        );
      }
      await Future.delayed(const Duration(milliseconds: 16));
    }
    debugPrint("[MAP-BOOT] All stations rendered.");
  }
}

class _BottomPanel extends StatelessWidget {
  final AppState appState;
  final ValueNotifier<double> heightNotifier;
  final double screenHeight;
  final Function(Station) onStationTap;
  final Function(Station) onNavigate;

  const _BottomPanel({
    required this.appState,
    required this.heightNotifier,
    required this.screenHeight,
    required this.onStationTap,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark ? const Color(0xFF1E1E1E) : const Color(0xFFFFF5F0),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, -5))],
      ),
      child: Column(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (details) {
              double newHeight = heightNotifier.value - details.delta.dy;
              heightNotifier.value = newHeight.clamp(screenHeight * 0.2, screenHeight * 0.8);
            },
            child: Container(
              width: double.infinity,
              height: 32,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4, height: 4,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark ? Colors.white38 : const Color(0xFFBBBBBB),
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 3, offset: const Offset(0, 1))],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: theme.brightness == Brightness.dark ? const Color(0xFF2A2A2A) : const Color(0xFFFFFFFF),
                      hintText: l10n.input_placeholder,
                      prefixIcon: const Icon(Icons.search, color: Colors.grey, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    ),
                    onSubmitted: (val) => appState.searchStations(val),
                    style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _buildStationContent(l10n),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStationContent(AppLocalizations l10n) {
    if (appState.allStations.isEmpty) {
      return _buildEmptyState(l10n);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 8),
      itemCount: appState.allStations.length,
      itemBuilder: (context, index) {
        final station = appState.allStations[index];
        return StationCard(
          station: station,
          onTap: () => onStationTap(station),
          onNavigate: () => onNavigate(station),
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

  Widget _buildEmptyState(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          Text(l10n.noStationsFound, textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
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
                  color: theme.brightness == Brightness.dark ? const Color(0xFF90CAF9) : Colors.black87,
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
