import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/language_service.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Drawer( // 確保封裝在 Drawer 中以支持 Scaffold.openDrawer()
      child: NavigationDrawer(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(28, 60, 28, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.settings, size: 48, color: AppColors.primary),
                const SizedBox(height: 16),
                Text(
                  "系統設定",
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          const Divider(),
          // 地區選擇
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              title: const Text("選擇地區"),
              trailing: DropdownButton<String>(
                value: appState.currentRegion,
                items: AppState.regionCoordinates.keys.map((region) {
                  return DropdownMenuItem(
                    value: region,
                    child: Text(region),
                  );
                }).toList(),
                onChanged: (val) => appState.setRegion(val!),
              ),
            ),
          ),
          // 語言選擇
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: ListTile(
              title: const Text("語言設定"),
              trailing: DropdownButton<String>(
                value: appState.currentLang,
                items: const [
                  DropdownMenuItem(value: 'zh', child: Text("中文")),
                  DropdownMenuItem(value: 'en', child: Text("English")),
                ],
                onChanged: (val) => appState.setLanguage(val!),
              ),
            ),
          ),
          // 深色模式
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: SwitchListTile(
              title: const Text("深色模式"),
              value: appState.isDarkMode,
              onChanged: (val) => appState.toggleDarkMode(val),
            ),
          ),
        ],
      ),
    );
  }
}
