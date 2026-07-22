import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:youbike/core/services/map_animated_move.dart';

/// MapController 薄封裝，讓 coordinator 不需接觸 UI 細節。
class MapMoveTrigger {
  MapController? _controller;

  void attach(MapController controller) => _controller = controller;

  /// Optional animated strategy. When set, `fire` delegates to the strategy's
  /// `moveTo`, otherwise falls back to instant `_controller?.move(...)`.
  void attachStrategy(MapMoveStrategy Function()? factory) {
    _strategy = factory?.call();
  }

  MapMoveStrategy? _strategy;

  void fire(LatLng position, {double zoom = 18.0}) {
    if (_strategy != null) {
      _strategy!.moveTo(position, zoom: zoom);
      return;
    }
    _controller?.move(position, zoom);
  }
}