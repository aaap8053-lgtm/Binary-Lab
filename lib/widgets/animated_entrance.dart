import 'package:flutter/material.dart';

/// Fade + slide-up + scale entrance. Stagger lists by passing [delayMs].
class AnimatedEntrance extends StatefulWidget {
  const AnimatedEntrance({
    super.key,
    required this.child,
    this.delayMs = 0,
    this.slide = 22,
  });

  final Widget child;
  final int delayMs;
  final double slide;

  @override
  State<AnimatedEntrance> createState() => _AnimatedEntranceState();
}

class _AnimatedEntranceState extends State<AnimatedEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );

  @override
  void initState() {
    super.initState();
    if (widget.delayMs == 0) {
      _controller.forward();
    } else {
      Future.delayed(Duration(milliseconds: widget.delayMs), () {
        if (mounted) _controller.forward();
      });
    }
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
        final v = Curves.easeOutCubic.transform(_controller.value);
        return Opacity(
          opacity: v,
          child: Transform.translate(
            offset: Offset(0, widget.slide * (1 - v)),
            child: Transform.scale(scale: 0.96 + 0.04 * v, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}
