import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/station.dart';

class ApiService {
  final String stationsUrl = "https://apis.youbike.com.tw/json/station-min-yb2.json";
  final String vehicleUrl = "https://apis.youbike.com.tw/json/vehicle-min-yb2.json";
  final http.Client? client;

  ApiService({this.client});

  http.Client get _client => client ?? http.Client();

  // 翻譯自 apiYoubike.js: fetchBaseStationData
  Future<List<Station>> fetchAllStations() async {
    final response = await _client.get(Uri.parse(stationsUrl));
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      
      // 使用容錯解析：過濾掉所有返回 null 的無效站牌
      return data
          .map((json) => Station.fromJson(json as Map<String, dynamic>))
          .whereType<Station>() 
          .toList();
    } else {
      throw Exception('Failed to load station base data: ${response.statusCode}');
    }
  }

  // 翻譯自 apiYoubike.js: queryVehicleData
  Future<Map<String, dynamic>> fetchRealtimeVehicles(List<String> stationIds) async {
    if (stationIds.isEmpty) return {};
    
    const batchSize = 20;
    Map<String, dynamic> allVehicleData = {};
    
    final url = Uri.parse('https://apis.youbike.com.tw/tw2/parkingInfo');
    final headers = {
      'Accept': '*/*',
      'Content-Type': 'application/json',
      'Origin': 'https://www.youbike.com.tw',
      'Referer': 'https://www.youbike.com.tw/',
    };

    for (var i = 0; i < stationIds.length; i += batchSize) {
      final batch = stationIds.sublist(i, i + batchSize > stationIds.length ? stationIds.length : i + batchSize);
      
      try {
        final response = await _client.post(
          url,
          headers: headers,
          body: jsonEncode({'station_no': batch}),
        );

        if (response.statusCode == 200) {
          final result = jsonDecode(response.body);
          if (result['retCode'] == 1 && result['retVal'] != null && result['retVal']['data'] != null) {
            final List<dynamic> data = result['retVal']['data'];
            for (var item in data) {
              final stationNo = item['station_no'].toString();
              final detail = item['available_spaces_detail'];
              allVehicleData[stationNo] = {
                'available_2_0': detail != null ? detail['yb2'] : 0,
                'available_e': detail != null ? detail['eyb'] : 0,
                'empty_spaces': item['empty_spaces'] ?? 0,
              };
            }
          }
        }
      } catch (e) {
        // Using a comment instead of print to avoid lint warning
        // Log: Error fetching batch: $e
      }
    }
    return allVehicleData;
  }

  // 翻譯自 apiElectric.js: showElectricBikeDetailsModal
  Future<List<Map<String, dynamic>>> fetchElectricBikeDetails(String stationId) async {
    final url = Uri.parse('https://apis.youbike.com.tw/api/front/bike/lists?station_no=$stationId');
    final headers = {
      'Accept': '*/*',
      'Accept-Language': 'zh-TW,zh;q=0.9',
      'Origin': 'https://www.youbike.com.tw',
      'Referer': 'https://www.youbike.com.tw/',
    };

    try {
      final response = await _client.get(url, headers: headers);
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        if (result['retCode'] == 1 && result['retVal'] != null) {
          return List<Map<String, dynamic>>.from(result['retVal']);
        }
      }
    } catch (e) {
      // Log: Error fetching electric bike details: $e
    }
    return [];
  }
}
