import 'package:flutter_test/flutter_test.dart';
import 'package:youbike_android/models/station.dart';

void main() {
  group('Station.fromJson Type Robustness Test', () {
    test('should parse numeric types correctly', () {
      final json = {
        "station_no": "123",
        "station_name": "Num Station",
        "lat": 25.0,
        "lng": 121.0,
        "available_bikes": 10,
        "available_electric_bikes": 5,
        "empty_spaces": 2,
      };
      final station = Station.fromJson(json);
      expect(station.lat, 25.0);
      expect(station.availableBikes, 10);
    });

    test('should parse string types correctly (API edge case)', () {
      final json = {
        "station_no": "123",
        "station_name": "Str Station",
        "lat": "25.0",
        "lng": "121.0",
        "available_bikes": "10",
        "available_electric_bikes": "5",
        "empty_spaces": "2",
      };
      final station = Station.fromJson(json);
      expect(station.lat, 25.0);
      expect(station.lng, 121.0);
      expect(station.availableBikes, 10);
      expect(station.availableElectricBikes, 5);
      expect(station.emptySpaces, 2);
    });

    test('should handle nulls or missing keys gracefully', () {
      final json = {
        "station_no": "123",
        "station_name": "Null Station",
        // lat/lng missing
      };
      final station = Station.fromJson(json);
      expect(station.lat, 0.0);
      expect(station.availableBikes, 0);
    });
  });
}
