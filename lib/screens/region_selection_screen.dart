import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../services/app_state.dart';

class RegionSelectionScreen extends StatelessWidget {
  const RegionSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings_region),
        backgroundColor: theme.brightness == Brightness.dark ? theme.colorScheme.surface : Colors.white,
        foregroundColor: theme.brightness == Brightness.dark ? theme.colorScheme.primary : Colors.black,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        children: appState.regions.entries.map((entry) {
          final String regionId = entry.key;
          final String regionKey = entry.value['name'] as String;
          
          // Use the dynamic translation method
          final String regionName = (regionKey.startsWith('region_')) 
              ? (l10n as dynamic).getTranslation(regionKey) // Use dynamic to bypass compile-time check if method exists in generated class
              : regionKey;
          final bool isSelected = appState.selectedRegion == regionId;

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: InkWell(
              onTap: () {
                appState.setRegion(regionId);
              },
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected ? theme.colorScheme.primary : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: isSelected 
                        ? Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary,
                              shape: BoxShape.circle,
                            ),
                          ) 
                        : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(regionName, style: TextStyle(
                    fontSize: 18, 
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                  )),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
