import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';

import '../utils/app_colors.dart';
import '../utils/binary_utils.dart';

/// One tappable bit card. Fills whatever cell the (adaptive) grid gives it.
class BitCard extends StatelessWidget {
  const BitCard({
    super.key,
    required this.power,
    required this.isOn,
    required this.onTap,
  });

  final int power; // 0..7
  final bool isOn;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final value = 1 << power;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: isOn ? 1.0 : 0.96,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: isOn
                ? LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.neonGreen.withValues(alpha: 0.18),
                      AppColors.card,
                    ],
                  )
                : null,
            color: isOn ? null : AppColors.card,
            border: Border.all(
              color: isOn ? AppColors.neonGreen : AppColors.cardBorder,
              width: isOn ? 1.6 : 1,
            ),
            boxShadow: isOn
                ? [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.10),
                      blurRadius: 40,
                      spreadRadius: 4,
                    ),
                  ]
                : const [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                BinaryUtils.powerLabel(power),
                style: AppFonts.jetBrainsMono(
                  fontSize: 11,
                  color: isOn ? AppColors.neonCyan : AppColors.textDim,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '$value',
                  style: AppFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isOn ? AppColors.neonGreen : AppColors.textDim,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                width: 38,
                height: 20,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isOn ? AppColors.neonGreen : Colors.transparent,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isOn ? AppColors.neonGreen : AppColors.cardBorder,
                  ),
                ),
                child: Text(
                  isOn ? '1' : '0',
                  style: AppFonts.jetBrainsMono(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isOn ? const Color(0xFF03231A) : AppColors.textDim,
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
