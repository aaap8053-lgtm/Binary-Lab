import 'package:flutter/material.dart';

/// Animates a number from its previous value to [value] (count up/down).
class CountUp extends StatefulWidget {
  const CountUp({
    super.key,
    required this.value,
    required this.style,
    this.durationMs = 700,
  });

  final int value;
  final TextStyle style;
  final int durationMs;

  @override
  State<CountUp> createState() => _CountUpState();
}

class _CountUpState extends State<CountUp> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.durationMs),
  );

  double _from = 0;
  double _to = 0;

  @override
  void initState() {
    super.initState();
    _to = widget.value.toDouble();
    _controller.forward();
  }

  @override
  void didUpdateWidget(CountUp oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _from = _current();
      _to = widget.value.toDouble();
      _controller.forward(from: 0);
    }
  }

  double _current() =>
      _from + (_to - _from) * Curves.easeOutCubic.transform(_controller.value);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) =>
          Text('${_current().round()}', style: widget.style),
    );
  }
}
