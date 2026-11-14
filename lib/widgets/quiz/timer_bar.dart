import 'package:flutter/material.dart';

import '../../utils/app_colors.dart';

/// Animated countdown bar: green → amber → red as time runs out.
class TimerBar extends StatelessWidget {
  const TimerBar({super.key, required this.timeLeft, required this.totalTime});

  final int timeLeft;
  final int totalTime;

  @override
  Widget build(BuildContext context) {
    final fraction =
        totalTime <= 0 ? 0.0 : (timeLeft / totalTime).clamp(0.0, 1.0);
    final color = timeLeft <= 3
        ? AppColors.neonRed
        : timeLeft <= (totalTime / 2).ceil()
            ? AppColors.neonAmber
            : AppColors.neonGreen;

    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 8,
        child: LayoutBuilder(
          builder: (context, constraints) => Stack(
            children: [
              Container(color: AppColors.cardBorder),
              Align(
                // Flips automatically in RTL.
                alignment: AlignmentDirectional.centerStart,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 900),
                  curve: Curves.linear,
                  width: constraints.maxWidth * fraction,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                          color: color.withValues(alpha: 0.5), blurRadius: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
