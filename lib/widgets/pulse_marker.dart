import 'package:flutter/material.dart';

class PulseMarker extends StatelessWidget {
  final double latitude;
  final double longitude;

  const PulseMarker({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer soft pulse (Solid fill, not a ring)
        const PulseAnimation(
          color: Color(0xFF4285F4),
          targetSize: 60,
        ),
        // Inner soft pulse (Solid fill, not a ring)
        const PulseAnimation(
          color: Color(0xFF4285F4),
          targetSize: 60,
          delay: Duration(milliseconds: 500),
        ),
        // Center Dot: Web-standard 20px core with crisp white halo
        Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              color: const Color(0xFF4285F4),
            ),
          ),
        ),
      ],
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Color color;
  final double targetSize;
  final Duration delay;

  const PulseAnimation({
    super.key,
    required this.color,
    required this.targetSize,
    this.delay = Duration.zero,
  });

  @override
  State<PulseAnimation> createState() => _PulseAnimationState();
}

class _PulseAnimationState extends State<PulseAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;
        // Expand from core dot (20px) to targetSize (60px)
        final currentSize = 20.0 + (widget.targetSize - 20.0) * progress;
        return Container(
          width: currentSize,
          height: currentSize,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color.withValues(alpha: 0.3 * (1.0 - progress)),
          ),
        );
      },
    );
  }
}
