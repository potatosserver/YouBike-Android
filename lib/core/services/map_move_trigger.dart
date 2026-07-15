import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// MapController 薄封裝，讓 coordinator 不需接觸 UI 細節。
class MapMoveTrigger {
  MapController? _controller;

  void attach(MapController controller) => _controller = controller;

  void fire(LatLng position, {double zoom = 18.0}) {
    _controller?.move(position, zoom);
  }
}