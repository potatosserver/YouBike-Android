import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 必須導入以使用 Clipboard
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class DebugScreen extends StatelessWidget {
  const DebugScreen({super.key});

  String _buildDebugInfo(AppState appState) {
    return '''
[基礎狀態]
目前區域: ${appState.currentRegion}
目前語言: ${appState.currentLang}
深色模式: ${appState.isDarkMode}
追蹤模式: ${appState.isFollowingUser}
加載中: ${appState.isLoading}

[數據量]
總站牌數: ${appState.stationMarkers.length}
地圖 Marker 數: ${appState.stationMarkers.length}
倒數計時: ${appState.countdown}

[座標資訊]
中心點: ${appState.center}
''';
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final info = _buildDebugInfo(appState);

    return Scaffold(
      appBar: AppBar(
        title: const Text("系統偵錯資訊"),
        backgroundColor: Colors.redAccent,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("基礎狀態"),
            _buildInfoRow("目前區域", appState.currentRegion),
            _buildInfoRow("目前語言", appState.currentLang),
            _buildInfoRow("深色模式", appState.isDarkMode.toString()),
            _buildInfoRow("追蹤模式", appState.isFollowingUser.toString()),
            _buildInfoRow("加載中", appState.isLoading.toString()),
            const Divider(),
            _buildSectionTitle("數據量"),
            _buildInfoRow("總站牌數", "${appState.stationMarkers.length}"),
            _buildInfoRow("地圖 Marker 數", "${appState.stationMarkers.length}"),
            _buildInfoRow("倒數計時", "${appState.countdown}"),
            const Divider(),
            _buildSectionTitle("座標資訊"),
            _buildInfoRow("中心點", appState.center.toString()),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: info));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("資訊已複製到剪貼簿")),
                  );
                },
                child: const Text("複製所有資訊"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text(value, style: const TextStyle(fontSize: 16, color: Colors.blue)),
        ],
      ),
    );
  }
}
