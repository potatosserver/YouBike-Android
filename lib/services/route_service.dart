import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteStep {
  final String instruction;
  final double distance;
  final double duration;

  RouteStep({
    required this.instruction,
    required this.distance,
    required this.duration,
  });

  factory RouteStep.fromJson(Map<String, dynamic> json) {
    return RouteStep(
      instruction: json['instruction'] ?? '',
      distance: (json['distance'] as num).toDouble(),
      duration: (json['duration'] as num).toDouble(),
    );
  }
}

class RouteService {
  final String osrmUrl = "https://router.project-osrm.org/route/v1/walking/";

  Future<List<RouteStep>> getRoute(LatLng start, LatLng end) async {
    final url = "$osrmUrl${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=false";
    
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final steps = data['routes'][0]['legs'][0]['steps'] as List;
        return steps.map((s) => RouteStep.fromJson(s)).toList();
      }
    } catch (e) {
      print("Route error: $e");
    }
    return [];
  }
}
