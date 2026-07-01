import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"), // Will be replaced by L10n
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionTitle("Appearance"),
          _buildSettingsTile(
            icon: Icons.dark_mode,
            title: "Dark Mode",
            subtitle: appState.isDarkMode ? "Enabled" : "Disabled",
            trailing: Switch(
              value: appState.isDarkMode,
              onChanged: (val) {
                // appState.toggleDarkMode(); // To be implemented in AppState
              },
            ),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle("Preferences"),
          _buildSettingsTile(
            icon: Icons.language,
            title: "Language",
            subtitle: appState.currentLang == 'zh' ? "Traditional Chinese" : "English",
            onTap: () {
              // Language selection dialog
            },
          ),
          const SizedBox(height: 24),
          _buildSectionTitle("Information"),
          _buildSettingsTile(
            icon: Icons.info_outline,
            title: "About",
            subtitle: "YouBike Android v1.0",
            onTap: () {
              // About dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey[600],
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600])),
        trailing: trailing ?? const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
