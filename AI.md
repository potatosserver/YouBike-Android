# YouBike-Android — AI.md

> 全台 YouBike 微笑單車即時查詢 Android App（Flutter）
> M3 Material Design · 橘色品牌種子 · 0 0 0 靜態分析

---

## 檔案樹

```
lib/
├── main.dart                              ← 啟動入口 (Zero-Jump 序)
│
├── core/
│   ├── l10n/                              ← ARB 多語系 (zh_TW / en)
│   │   ├── app_localizations.dart         ← 生成基底
│   │   ├── app_localizations_en.dart      ← 英文
│   │   └── app_localizations_zh.dart      ← 繁中
│   │
│   ├── router/
│   │   └── app_router.dart                ← GoRouter 路由表
│   │
│   ├── services/                          ← ★ 無狀態服務層 (10 個)
│   │   ├── card_refresh_coordinator.dart  ← 🎯 統一口：串聯所有刷新步驟
│   │   ├── distance_calculator.dart       ← Haversine 距離計算
│   │   ├── gps_requester.dart             ← GPS 統一請求入口
│   │   ├── loading_notice_translator.dart ← ARB key → loading 文字
│   │   ├── location_resolver.dart         ← 座標決策 (GPS → 區域中心)
│   │   ├── map_move_trigger.dart          ← MapController 薄封裝
│   │   ├── realtime_updater.dart          ← API 批次即時車輛數據
│   │   ├── route_instruction_translator.dart ← GraphHopper 導航翻譯
│   │   ├── station_format_helper.dart     ← Station 欄位格式化 (含 l10n)
│   │   └── station_sorter.dart            ← 距離排序 + 釘選置頂 + 取前 N
│   │
│   ├── theme/
│   │   ├── brand_colors.dart              ← 品牌色 (橘/黃/藍/綠 — 無語意)
│   │   └── theme_provider.dart            ← M3 ThemeMode 持久化
│   │
│   └── utils/
│       └── log_service.dart               ← 結構化 Log (release 自動靜音)
│
├── data/
│   ├── models/
│   │   └── station.dart                   ← Station 模型 (nullable 數量)
│   │
│   └── services/
│       ├── api_service.dart               ← YouBike API (基礎+即時+電動車)
│       ├── app_config_service.dart        ← 全局配置 (語言/區域/定位/釘選)
│       ├── language_service.dart          ← 語系持久化 + 系統回退
│       └── route_service.dart             ← GraphHopper 步行導航 API
│
├── providers/                             ← ChangeNotifier ViewModels
│   ├── localized_view_model.dart          ← 抽象基類 (L10n 注入)
│   ├── loading_view_model.dart            ← 啟動進度條 + 安全提示
│   ├── map_view_model.dart                ← GPS 定位 + 地圖 center
│   └── station_view_model.dart            ← 🎯 站點狀態 + 60s 倒數 + refreshCards()
│
└── ui/
    ├── app.dart                           ← MaterialApp.router (M3 橘種子)
    │
    ├── screens/
    │   ├── home_screen.dart               ← 主畫面 (地圖+搜尋面板 Divided Layout)
    │   ├── settings_screen.dart           ← 設定首頁
    │   ├── theme_selection_screen.dart    ← 主題選擇 (系統/淺/深)
    │   ├── language_selection_screen.dart ← 語言選擇 (繁中/English)
    │   └── region_selection_screen.dart   ← 區域選擇 (13 縣市)
    │
    └── widgets/
        ├── app_wrapper.dart               ← 啟動載入層 (Double-Delay Guard)
        ├── map_view.dart                  ← flutter_map + 聚類標記層
        ├── map_markers.dart               ← RoadSign 站點標記 + Cluster
        ├── pulse_marker.dart              ← GPS 雙層脈衝動畫
        ├── map_mask_overlay.dart          ← CustomPaint 地圖鏤空遮罩
        ├── search_panel.dart              ← 搜尋框 + 站點卡片列表
        ├── station_card.dart              ← 單一站點卡片 (名稱/距離/即時數據)
        ├── route_detail_panel.dart        ← 步行導航步驟清單 (BottomSheet)
        ├── electric_bike_modal.dart       ← 電動車電池詳情 (BottomSheet)
        ├── home_update_button.dart        ← 更新按鈕 (180° 旋轉動畫 + 倒數)
        ├── loading_overlay.dart           ← 全屏橘色啟動畫面
        └── setting_group_card.dart        ← WalkGo 風格設定卡片群組
```

---

## 架構圖：呼叫鏈全景

```
main()
  │ await AppConfigService.init()    ← 語言/區域/定位偏好
  │ await LanguageService.loadLocale()
  │ runApp(MultiProvider(...))
  ▼
MyApp (MaterialApp.router)
  │ seedColor: 0xFFFF9800 (YouBike 橘)
  │ M3 ColorScheme.fromSeed()
  ▼
AppWrapper.initState()
  │ Future.microtask → addPostFrameCallback (Double-Delay Guard)
  │ _initializeApp()
  │   ├─ LoadingViewModel.setLoading(true)
  │   ├─ GpsRequester.requestOrFallback(mapVm)   ← GPS or region center
  │   ├─ StationViewModel.fetchBaseData()
  │   │     └─ ApiService.fetchAllStations()      ← 9,338+ 站點 JSON (~4MB)
  │   ├─ StationViewModel.refreshCards(moveTo: ...)
  │   │     └─ CardRefreshCoordinator.execute()
  │   │           ├─ LocationResolver.resolve()       ← ref point
  │   │           ├─ StationSorter.sortAndPick()      ← sort + pin + top 10
  │   │           │     └─ DistanceCalculator.haversine()
  │   │           ├─ RealtimeUpdater.apply()          ← API batch vehicle data
  │   │           │     ├─ ApiService.fetchRealtimeVehicles()
  │   │           │     └─ DistanceCalculator.haversine()
  │   │           └─ MapMoveTrigger.fire()           ← mapController.move()
  │   └─ LoadingViewModel.setFinished()
  ▼
HomeScreen (Divided Layout)
  ├─ MapView (flutter_map)
  │   ├─ TileLayer (Voyager light / Dark Matter dark)
  │   ├─ StationMarkerLayer (flutter_map_marker_cluster)
  │   │     └─ RoadSignMarker / ClusterMarker (BrandColors.markerYellow)
  │   └─ PulseMarker (GPS dot, BrandColors.pulseBlue)
  │
  ├─ MapMaskOverlay (CustomPaint evenOdd — 地圖鏤空)
  │
  └─ SearchPanel
        ├─ TextField → stationVm.searchStations() → refreshCards()
        └─ ListView.builder
              └─ StationCard × 10
                    ├─ StationFormatHelper (name/address/distance/bikes)
                    ├─ Icons.electric_bolt → BrandColors.accentGreen
                    ├─ Icons.star → Colors.amber (pin)
                    └─ Icons.navigation → BrandColors.accentBlue
                          └─ RouteDetailPanel (GraphHopper 步行導航)

持續更新循環 (60s):
  _startCountdown() → countdownRemaining-- → 歸零時
    → stationVm.refreshCards()
        └─ CardRefreshCoordinator.execute() (同上)
```

---

## 呼叫關係速查表

### CardRefreshCoordinator (統一口)

| 步驟 | 服務 | 方法 | 輸入 | 輸出 |
|---|---|---|---|---|
| 1 | `LocationResolver` | `.resolve(mapVm)` | MapViewModel | LatLng |
| 2 | `StationSorter` | `.sortAndPick(stations, ref, pinned)` | List<Station>, LatLng, Set<String> | List<Station> (≤10) |
| 3 | `RealtimeUpdater` | `.apply(stations, ref)` | List<Station>, LatLng | void (mutates stations) |
| 4 | `MapMoveTrigger` | `.fire(pos)` | LatLng | void |

### API 層

| 服務 | 方法 | 端點 | 用途 |
|---|---|---|---|
| `ApiService` | `fetchAllStations()` | `apis.youbike.com.tw/json/station-min-yb2.json` | 全台站點基礎資料 (~4MB, 30s timeout) |
| `ApiService` | `fetchRealtimeVehicles(ids)` | `apis.youbike.com.tw/tw2/parkingInfo` | 批次即時車輛數量 (每批 20, 10s timeout) |
| `ApiService` | `fetchElectricBikeDetails(id)` | `apis.youbike.com.tw/api/front/bike/lists` | 單站電動車電池詳情 |
| `RouteService` | `getRoute(start, end, lang)` | `graphhopper.com/api/1/route` | 步行導航步驟 |

### GPS 統一入口

| 服務 | 方法 | 回傳 | 失敗行為 |
|---|---|---|---|
| `GpsRequester` | `.request(mapVm)` | `LatLng?` | null |
| `GpsRequester` | `.requestOrFallback(mapVm)` | `LatLng` | GPS or 區域中心 (永不 null) |

### 品牌色 (無語意 — 不隨種子色變)

| 常量 | Hex | 用途 |
|---|---|---|
| `BrandColors.orange` | `#FF9800` | 種子色、啟動圈、進度條 |
| `BrandColors.lightOrange` | `#FFCC80` | 地圖浮動按鈕背景 |
| `BrandColors.markerYellow` | `#FFD700` | 站點標記、聚類圓 |
| `BrandColors.accentBlue` | `Colors.blue` | 導航圖標、GPS 脈衝、站點名稱 |
| `BrandColors.accentGreen` | `#4CAF50` | 電動車圖標、電池百分比 |

---

## 觸發源 → refreshCards() 完整清單

| 觸發源 | 檔案 | 情境 |
|---|---|---|
| 啟動初始化 | `app_wrapper.dart:62` | `stationVm.refreshCards(moveTo: mapVm.getEffectiveLocation())` |
| 60 秒倒數歸零 | `station_view_model.dart:_startCountdown` | `refreshCards()` (無 moveTo) |
| 更新按鈕點擊 | `home_update_button.dart:36` | `stationVm.refreshCards()` |
| MyLocation 按鈕 | `home_screen.dart:167` | `GpsRequester.requestOrFallback()` → `refreshCards(moveTo: pos)` |
| 搜尋框送出 | `search_panel.dart:150` | `stationVm.searchStations(val)` → `refreshCards()` |
| 點站點卡片 | `search_panel.dart:206` | `refreshCards(moveTo: target)` |
| useLocation ON | `station_view_model.dart:56` | `_onLocationEnabled()` → `requestAndCenterLocation()` → `refreshCards(moveTo:)` |
| useLocation OFF | `station_view_model.dart:62` | 清除 GPS → `refreshCards(moveTo: mapVm?.getEffectiveLocation())` |

---

## Flutter 靜態分析

```
flutter analyze → No issues found!
0 errors · 0 warnings · 0 infos
```

---

## 技術棧

| 層 | 依賴 |
|---|---|
| 狀態管理 | `provider` (ChangeNotifier + ProxyProvider) |
| 路由 | `go_router` |
| 地圖 | `flutter_map` + `flutter_map_marker_cluster` + `latlong2` |
| GPS | `geolocator` |
| HTTP | `http` |
| 持久化 | `shared_preferences` |
| 多語系 | `flutter_localizations` + ARB |
| M3 | `ColorScheme.fromSeed(seedColor: BrandColors.orange)` |