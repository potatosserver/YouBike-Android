import 'package:flutter/material.dart';
import 'package:youbike/core/theme/brand_colors.dart';

/// YouBike 品牌 Logo：橙色圓形背景 + 白色自行車圖示。
///
/// 用在歡迎畫面（welcome_page）與載入畫面（loading_overlay）
/// 兩處，取代原本各自重複的 Container。
class YouBikeLogo extends StatelessWidget {
  /// 圓形容器的高度（預設 120 = welcome_page 尺寸）。
  final double size;

  /// 內部圖示的大小（預設 56 = welcome_page 尺寸）。
  final double iconSize;

  const YouBikeLogo({super.key, this.size = 120, this.iconSize = 56});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: BrandColors.orange,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: BrandColors.orange.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 5,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Icon(
        Icons.directions_bike_rounded,
        size: iconSize,
        color: Colors.white,
      ),
    );
  }
}