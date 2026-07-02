import 'package:flutter/material.dart';
import '../models/station.dart';

class StationCard extends StatelessWidget {
  final Station station;
  final VoidCallback onTap;

  const StationCard({
    super.key, 
    required this.station, 
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    // Mirroring web CSS variables
    const primaryColor = Color(0xFFE44D26); // --primary-color
    const borderColor = Color(0xFFE0E0E0);    // --border-color (Approx Colors.grey.shade300)
    const bgColor = Color(0xFFFFFFFF);       // --bg-color
    const textColor = Color(0xFF333333);     // --text-color (Approx Colors.black87)
    const secondaryTextColor = Color(0xFF757575); // (Approx Colors.grey.shade600)

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: 6,
                  color: primaryColor,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                station.nameTw,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            _buildBikeCountRow(station),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          station.addressTw,
                          style: TextStyle(
                            fontSize: 13,
                            color: secondaryTextColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.location_on, size: 14, color: primaryColor),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "距離您的位置 ${station.distance} ${station.distanceUnit}",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: secondaryTextColor,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBikeCountRow(Station station) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildBikeCountItem("2.0", station.availableBikes),
        const SizedBox(width: 8),
        _buildBikeCountItem("2.0E", station.availableElectricBikes, isElectric: true),
        const SizedBox(width: 8),
        _buildBikeCountItem("空位", station.emptySpaces),
      ],
    );
  }

  Widget _buildBikeCountItem(String label, int count, {bool isElectric = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: isElectric ? const Color(0xFFFFF3E0) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isElectric ? Colors.orange.shade800 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            "$count",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
