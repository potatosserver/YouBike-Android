import 'package:flutter/material.dart';

/// All non-ColorScheme colors in one place.
/// Everything else MUST use theme.colorScheme.*.
class BrandColors {
  BrandColors._();

  // ── brand identity ──

  /// YouBike orange — seed color, loading circle, progress bar.
  static const Color orange = Color(0xFFFF9800);

  /// Light orange for map buttons — readable with black text.
  static const Color lightOrange = Color(0xFFFFCC80);

  /// Station marker & cluster yellow (Road-Sign standard).
  static const Color markerYellow = Color(0xFFFFD700);

  // ── fixed accent ──

  /// Navigation icon, GPS pulse dot — always blue.
  static const Color accentBlue = Colors.blue;

  /// Electric bike icon & battery percentage — always bright green.
  static const Color accentGreen = Color(0xFF4CAF50);
}