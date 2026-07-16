import 'package:flutter/material.dart';

/// 統一的 BottomSheet drag handle — 頂部小橫條。
/// 供 route_detail_panel / electric_bike_modal 共用。
class DragHandle extends StatelessWidget {
  final Color? color;

  const DragHandle({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3);
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: c,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}

/// 共用形狀常數。
class AppShapes {
  AppShapes._();

  /// BottomSheet 頂部圓角 (24px)。
  static const bottomSheet = RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  );
}