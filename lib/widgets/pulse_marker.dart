import 'package:flutter/material.dart';

class PulseMarker extends StatelessWidget {
  final double latitude;
  final double longitude;

  const PulseMarker({super.key, required this.latitude, required this.longitude});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 2000),
      onEnd: () {
        // This is tricky in StatelessWidget, but we can't easily repeat.
        // I will change this to a StatefulWidget to ensure the animation repeats.
      },
      builder: (context, value, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 20 * value * 2,
              height: 20 * value * 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 1.0 - value),
                border: Border.all(color: Colors.blue, width: 2),
              ),
            ),
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
              ),
            ),
          ],
        );
      },
    );
  }
}
