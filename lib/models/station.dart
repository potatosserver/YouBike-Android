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
      // 1. 兼容 ID 鍵名
      final id = json['station_no'] ?? json['id'] ?? '';
      if (id == '') return null;

      // 2. 解析坐標 (關鍵修復：處理 String 類型的坐標)
      final latString = json['lat']?.toString() ?? '';
      final lngString = json['lng']?.toString() ?? '';
      
      final lat = double.tryParse(latString);
      final lng = double.tryParse(lngString);
      
      if (lat == null || lng == null) return null;

      return Station(
        id: id.toString(),
        nameTw: (json['name_tw'] ?? '').toString(),
        nameEn: (json['name_en'] ?? '').toString(),
        addressTw: (json['address_tw'] ?? '').toString(),
        addressEn: (json['address_en'] ?? '').toString(),
        lat: lat,
        lng: lng,
      );
    } catch (e) {
      return null;
    }
  }

  void updateRealtimeData(Map<String, dynamic> data) {
    availableBikes = int.tryParse(data['available_bikes']?.toString() ?? '0') ?? 0;
    availableElectricBikes = int.tryParse(data['available_ebikes']?.toString() ?? '0') ?? 0;
    totalBikes = int.tryParse(data['total_bikes']?.toString() ?? '0') ?? 0;
    totalElectricBikes = int.tryParse(data['total_ebikes']?.toString() ?? '0') ?? 0;
  }
}
