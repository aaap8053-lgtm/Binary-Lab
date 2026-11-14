import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';

import '../utils/app_colors.dart';

/// Friendly placeholder used by the Quiz & Progress tabs until Part 2.
class ComingSoon extends StatelessWidget {
  const ComingSoon({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(28),
                color: AppColors.neonGreen.withValues(alpha: 0.08),
                border: Border.all(
                  color: AppColors.neonGreen.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(icon, size: 44, color: AppColors.neonGreen),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppFonts.orbitron(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 13.5, color: AppColors.textDim, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}
