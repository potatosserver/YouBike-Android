import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/station.dart';
import '../services/app_state.dart';
import '../widgets/app_theme.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;
  final VoidCallback onNavigate;
  final VoidCallback onShowElectric;

  const StationCard({
    super.key,
    required this.station,
    required this.onTap,
    required this.onNavigate,
    required this.onShowElectric,
  });

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    final isPinned = appState.pinnedStationIds.contains(station.id);
    final isEn = appState.currentLang == 'en';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.stationCardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    isEn ? station.nameEn : station.nameTw,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Row(
                  children: [
                    // Electric bikes button - Added to the left of the star as requested
                    IconButton(
                      icon: const Icon(Icons.electric_bike, color: Colors.green, size: 22),
                      onPressed: onShowElectric,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isPinned ? Icons.star : Icons.star_border,
                        color: isPinned ? Colors.amber : AppColors.primary,
                      ),
                      onPressed: () => appState.togglePinStation(station.id),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.navigation, color: AppColors.primary),
                      onPressed: onNavigate,
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Strict vertical layout mirroring the web's detailed list
            _buildTextRow(isEn ? "Distance" : "距離", appState.getDistanceLabel(station)),
            _buildTextRow(isEn ? "Address" : "地址", isEn ? station.addressEn : station.addressTw),
            _buildTextRow(isEn ? "YouBike 2.0" : "YouBike 2.0", "${station.availableBikes}"),
            _buildTextRow(isEn ? "YouBike 2.0E" : "YouBike 2.0E", "${station.availableElectricBikes}"),
            _buildTextRow(isEn ? "Empty Spaces" : "可停空位數", "${station.emptySpaces}"),
          ],
        ),
      ),
    );
  }

  Widget _buildTextRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$label : ",
            style: TextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
