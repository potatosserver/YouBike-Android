class Station {
  final String id;
  final String nameTw;
  final String nameEn;
  final String addressTw;
  final String addressEn;
  final double lat;
  final double lng;
  
  // Real-time data
  int availableBikes;
  int availableElectricBikes;
  int totalBikes;
  int totalElectricBikes;

  Station({
    required this.id,
    required this.nameTw,
    required this.nameEn,
    required this.addressTw,
    required this.addressEn,
    required this.lat,
    required this.lng,
    this.availableBikes = 0,
    this.availableElectricBikes = 0,
    this.totalBikes = 0,
    this.totalElectricBikes = 0,
  });

  static Station? fromJson(Map<String, dynamic> json) {
    try {
      // 兼容 YouBike API 不同版本的鍵名
      final id = json['station_no'] ?? json['id'] ?? '';
      final nameTw = json['name_tw'] ?? '';
      final nameEn = json['name_en'] ?? '';
      final addressTw = json['address_tw'] ?? '';
      final addressEn = json['address_en'] ?? '';
      
      // 坐標處理
      final latRaw = json['lat'];
      final lngRaw = json['lng'];
      if (latRaw == null || lngRaw == null) return null;

      return Station(
        id: id.toString(),
        nameTw: nameTw.toString(),
        nameEn: nameEn.toString(),
        addressTw: addressTw.toString(),
        addressEn: addressEn.toString(),
        lat: (latRaw as num).toDouble(),
        lng: (lngRaw as num).toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  void updateRealtimeData(Map<String, dynamic> data) {
    availableBikes = data['available_bikes'] ?? 0;
    availableElectricBikes = data['available_ebikes'] ?? 0;
    totalBikes = data['total_bikes'] ?? 0;
    totalElectricBikes = data['total_ebikes'] ?? 0;
  }
}
