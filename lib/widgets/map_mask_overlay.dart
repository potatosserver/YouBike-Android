import 'package:flutter/material.dart';

class MapMaskOverlay extends StatelessWidget {
  final Color maskColor;
  final double panelHeight;
  final bool isWide;

  const MapMaskOverlay({super.key, required this.maskColor, required this.panelHeight, required this.isWide});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.infinite,
      painter: _MapMaskPainter(maskColor, panelHeight, isWide),
    );
  }
}

class _MapMaskPainter extends CustomPainter {
  final Color color;
  final double panelHeight;
  final bool isWide;
  _MapMaskPainter(this.color, this.panelHeight, this.isWide);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..fillType = PathFillType.evenOdd;
    
    path.addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    final double horizontalMargin = isWide ? 12.0 : 0.0;
    final cutoutRect = RRect.fromRectAndCorners(
      Rect.fromLTWH(horizontalMargin, 0, size.width - (horizontalMargin * 2), size.height - panelHeight),
      topLeft: Radius.zero,
      topRight: Radius.zero,
      bottomLeft: const Radius.circular(24),
      bottomRight: const Radius.circular(24),
    );
    path.addRRect(cutoutRect);

    canvas.drawPath(path, paint..style = PaintingStyle.fill);
    
    final shadowPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0);
    
    canvas.drawRRect(cutoutRect, shadowPaint);
    
    final borderPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    
    canvas.drawRRect(cutoutRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is _MapMaskPainter) {
      return oldDelegate.panelHeight != panelHeight || oldDelegate.isWide != isWide;
    }
    return true;
  }
}