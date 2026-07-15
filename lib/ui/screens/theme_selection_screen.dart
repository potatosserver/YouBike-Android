import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:youbike_android/core/l10n/app_localizations.dart';
import 'package:youbike_android/core/theme/theme_provider.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final currentMode = Provider.of<ThemeProvider>(context).themeMode;

    final cs = theme.colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        title: Text(l10n.settings_theme),
        backgroundColor: cs.surface,
        foregroundColor: cs.onSurface,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: [
          _buildOption(context, title: "系統預設", mode: ThemeMode.system, isSelected: currentMode == ThemeMode.system),
          const SizedBox(height: 24),
          _buildOption(context, title: "淺色模式", mode: ThemeMode.light, isSelected: currentMode == ThemeMode.light),
          const SizedBox(height: 24),
          _buildOption(context, title: "深色模式", mode: ThemeMode.dark, isSelected: currentMode == ThemeMode.dark),
        ],
      ),
    );
  }


  Widget _buildOption(BuildContext context, {required String title, required ThemeMode mode, required bool isSelected}) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () {
        Provider.of<ThemeProvider>(context, listen: false).setThemeMode(mode);
      },
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? cs.primary : cs.onSurfaceVariant,
                width: 2,
              ),
            ),
            child: Center(
              child: isSelected 
                ? Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: cs.primary,
                      shape: BoxShape.circle,
                    ),
                  ) 
                : null,
            ),
          ),
          const SizedBox(width: 16),
          Text(title, style: TextStyle(
            fontSize: 18, 
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: cs.onSurface,
          )),
        ],
      ),
    );
  }
}
