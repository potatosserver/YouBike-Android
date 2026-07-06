import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/app_state.dart';
import '../services/language_service.dart';
import '../services/theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final langService = Provider.of<LanguageService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
          children: [
            _buildSettingsCard(
              context,
              title: "外觀設定",
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.palette_outlined),
                  title: const Text("主題模式"),
                  subtitle: Text(themeProvider.themeMode == ThemeMode.dark ? "深色模式" : (themeProvider.themeMode == ThemeMode.light ? "淺色模式" : "系統預設")),
                  value: themeProvider.themeMode != ThemeMode.light,
                  onChanged: (val) {
                    themeProvider.setThemeMode(val ? ThemeMode.dark : ThemeMode.light);
                  },
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildSettingsCard(
              context,
              title: "定位設定",
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.location_on_outlined),
                  title: const Text("啟用啟動自動定位"),
                  subtitle: const Text("開啟後將在啟動時嘗試獲取您的位置"),
                  value: appState.useLocation,
                  onChanged: (val) => appState.setUseLocation(val),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.map_outlined, size: 20),
                      const SizedBox(width: 12),
                      const Text("預設區域", style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: appState.selectedRegion,
                          underline: const SizedBox(),
                          onChanged: (val) {
                            if (val != null) appState.setRegion(val);
                          },
                          items: appState.regions.entries.map((entry) {
                            return DropdownMenuItem<String>(
                              value: entry.key,
                              child: Text(entry.value['name']),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            _buildSettingsCard(
              context,
              title: "通用設定",
              children: [
                ListTile(
                  leading: const Icon(Icons.language_outlined),
                  title: const Text("語言設定"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(langService.appLocale.languageCode.toUpperCase()),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                  onTap: () => _showLanguageSelector(context, langService),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: theme.brightness == Brightness.dark ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...children,
          ],
        ),
      ),
    );
  }

  void _showLanguageSelector(BuildContext context, LanguageService langService) {
    const List<Locale> supported = AppLocalizations.supportedLocales;
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text("選擇語言", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ...supported.map((locale) {
                final isSelected = langService.appLocale == locale;
                return ListTile(
                  title: Text(locale.languageCode == 'zh' ? "繁體中文" : "English"),
                  trailing: isSelected ? const Icon(Icons.check, color: Colors.blue) : null,
                  onTap: () {
                    langService.setLocale(locale);
                    Navigator.pop(context);
                  },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
