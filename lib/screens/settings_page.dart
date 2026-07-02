import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isEn = appState.currentLang == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEn ? "Settings" : "設定"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SectionTitle(title: isEn ? "Region Settings" : "區域設定"),
          DropdownButtonFormField<String>(
            initialValue: appState.currentRegion,
            decoration: InputDecoration(
              labelText: isEn ? "Select Region" : "選擇區域",
              border: const OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'taipei', child: Text("台北市 / Taipei")),
              DropdownMenuItem(value: 'newTaipei', child: Text("新北市 / New Taipei")),
              DropdownMenuItem(value: 'taoyuan', child: Text("桃園市 / Taoyuan")),
              DropdownMenuItem(value: 'kaohsiung', child: Text("高雄市 / Kaohsiung")),
            ],
            onChanged: (val) {
              if (val != null) appState.setRegion(val);
            },
          ),
          const SizedBox(height: 24),
          SectionTitle(title: isEn ? "Language Settings" : "語言設定"),
          SwitchListTile(
            title: Text(appState.currentLang == 'zh' ? "中文" : "English"),
            subtitle: Text(isEn ? "Switch display language" : "切換顯示語言"),
            value: appState.currentLang == 'zh',
            onChanged: (val) {
              appState.toggleLanguage();
            },
          ),
          const SizedBox(height: 24),
          SectionTitle(title: isEn ? "Appearance Settings" : "外觀設定"),
          SwitchListTile(
            title: Text(isEn ? "Dark Mode" : "深色模式"),
            subtitle: Text(isEn ? "Switch map and UI colors" : "切切地圖與介面配色"),
            value: appState.isDarkMode,
            onChanged: (val) {
              appState.toggleDarkMode();
            },
          ),
          const SizedBox(height: 24),
          SectionTitle(title: isEn ? "Location Settings" : "定位設定"),
          SwitchListTile(
            title: Text(isEn ? "Enable Auto-location" : "啟用自動定位"),
            subtitle: Text(isEn ? "Map will automatically follow your position" : "啟動後地圖將自動跟隨您的位置"),
            value: appState.useLocation,
            onChanged: (val) {
              // Logic handled in AppState
            },
          ),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }
}
