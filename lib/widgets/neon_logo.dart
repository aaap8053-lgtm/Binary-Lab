import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';

import '../utils/app_colors.dart';

/// The app mark: a glowing chip with "01" at its core.
class NeonLogo extends StatelessWidget {
  const NeonLogo({super.key, this.size = 32, this.glow = 1});

  final double size;

  /// 0..1 — animate this for a pulsing glow (splash screen).
  final double glow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.neonGreen.withValues(alpha: 0.20),
            AppColors.card,
          ],
        ),
        border: Border.all(
          color: AppColors.neonGreen,
          width: size > 60 ? 2 : 1.4,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.18 + 0.30 * glow),
            blurRadius: 6 + 16 * glow,
          ),
        ],
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            '01',
            style: AppFonts.orbitron(
              fontSize: size * 0.34,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: AppColors.neonGreen,
              shadows: [
                Shadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.6),
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
