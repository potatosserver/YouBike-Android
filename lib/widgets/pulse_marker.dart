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
        // Outer pulse ring
        const PulseAnimation(
          color: Color(0xFF2196F3),
          size: 40,
        ),
        // Inner pulse ring
        const PulseAnimation(
          color: Color(0xFF2196F3),
          size: 20,
          delay: Duration(milliseconds: 500),
        ),
        // Center dot
        Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Color(0xFF2196F3),
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 2)],
          ),
        ),
      ],
    );
  }
}

class PulseAnimation extends StatefulWidget {
  final Color color;
  final double size;
  final Duration delay;

  const PulseAnimation({
    super.key,
    required this.color,
    required this.size,
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
        return Container(
          width: widget.size * (1 + progress),
          height: widget.size * (1 + progress),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.color.withValues(alpha: 1.0 - progress),
              width: 2,
            ),
          ),
        );
      },
    );
  }
}
