import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/language_service.dart';

class SettingsPanel extends StatelessWidget {
  const SettingsPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return NavigationDrawer(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 16),
          child: Text(
            LanguageService.getText('settings_title', appState.currentLang),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
        const Divider(),
        _buildSettingItem(
          context,
          icon: Icons.location_on_outlined,
          label: LanguageService.getText('region_select', appState.currentLang),
          child: DropdownButton<String>(
            value: appState.currentRegion,
            isExpanded: true,
            underline: const SizedBox(),
            items: [
              // Add 'Custom' option to prevent Dropdown assertion error
              const DropdownMenuItem(
                value: 'custom',
                child: Text("我的位置"),
              ),
              ...AppState.regionCoordinates.entries
                  .where((e) => e.key != 'custom')
                  .map((e) => DropdownMenuItem(
                        value: e.key,
                        child: Text(e.key),
                      )),
            ],
            onChanged: (newValue) {
              if (newValue != null) appState.setRegion(newValue);
            },
          ),
        ),
        _buildSettingItem(
          context,
          icon: Icons.my_location,
          label: LanguageService.getText('location_service', appState.currentLang),
          child: Switch(
            value: appState.isFollowingUser,
            onChanged: (value) => appState.setFollowingUser(value),
          ),
        ),
        _buildSettingItem(
          context,
          icon: Icons.dark_mode_outlined,
          label: LanguageService.getText('dark_mode', appState.currentLang),
          child: Switch(
            value: appState.isDarkMode,
            onChanged: (value) => appState.toggleDarkMode(value),
          ),
        ),
        _buildSettingItem(
          context,
          icon: Icons.language,
          label: LanguageService.getText('lang_toggle', appState.currentLang),
          child: Switch(
            value: appState.currentLang == 'en',
            onChanged: (value) => appState.setLanguage(value ? 'en' : 'zh'),
          ),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Text(
              "YouBike Android v1.0",
              style: TextStyle(color: Colors.grey[600], fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSettingItem(BuildContext context, {required IconData icon, required String label, required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.grey[600]),
        title: Text(label, style: const TextStyle(fontSize: 15)),
        trailing: child,
        contentPadding: EdgeInsets.zero,
      ),
    );
  }
}
