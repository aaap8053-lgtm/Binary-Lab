import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Ambient "Matrix-style" falling binary. Pure CustomPainter, no state,
/// deterministic from the animation value → seamless loop, cheap to paint.
class BinaryRain extends StatefulWidget {
  const BinaryRain({super.key, this.opacity = 0.06});

  /// Keep this small (0.04–0.06) behind content, larger on the splash.
  final double opacity;

  @override
  State<BinaryRain> createState() => _BinaryRainState();
}

class _BinaryRainState extends State<BinaryRain>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 26),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          size: Size.infinite,
          painter: _RainPainter(t: _controller.value, opacity: widget.opacity),
        ),
      ),
    );
  }
}

class _RainPainter extends CustomPainter {
  _RainPainter({required this.t, required this.opacity});

  final double t; // 0..1, loops
  final double opacity;

  /// Cheap deterministic pseudo-random in [0,1).
  double _n(int n) {
    final x = (n * 2654435761) % 4294967296;
    return (x % 1000) / 1000.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (opacity <= 0) return;

    const colWidth = 30.0;
    const trail = 9;
    final cols = math.min((size.width / colWidth).ceil(), 16);
    final cycle = size.height + 260.0;

    for (var c = 0; c < cols; c++) {
      // Each column completes a whole number of cycles per loop → seamless.
      final cycles = 1 + (_n(c + 3) * 2).floor();
      final headY =
          ((_n(c * 7 + 5) * cycle) + t * cycles * cycle) % cycle - 130;

      for (var k = 0; k < trail; k++) {
        final y = headY - k * 20;
        if (y < -20 || y > size.height + 20) continue;

        final glyph = _n(c * 13 + k * 7 + 1) > 0.5 ? '1' : '0';
        final alpha = opacity * (1 - k / trail) * (k == 0 ? 1 : 0.65);

        final painter = TextPainter(
          text: TextSpan(
            text: glyph,
            style: TextStyle(
              fontSize: 13,
              color: Color.fromRGBO(0, 255, 156, alpha),
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        painter.paint(canvas, Offset(c * colWidth + 6, y));
      }
    }
  }

  @override
  bool shouldRepaint(covariant _RainPainter oldDelegate) =>
      oldDelegate.t != t || oldDelegate.opacity != opacity;
}
