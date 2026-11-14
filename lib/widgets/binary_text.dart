import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';

import '../utils/app_colors.dart';

/// Renders a binary string with colored digits:
/// 1 = neon green, 0 = dim, anything else (e.g. ".") = cyan.
class BinaryText extends StatelessWidget {
  const BinaryText(this.bits,
      {super.key, this.fontSize = 16, this.letterSpacing});

  final String bits;
  final double fontSize;
  final double? letterSpacing;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      // Binary is always read most-significant-bit first, left → right,
      // even when the surrounding UI is RTL.
      textDirection: TextDirection.ltr,
      child: Text.rich(
        TextSpan(
          children: [
            for (final ch in bits.split(''))
              TextSpan(
                text: ch,
                style: TextStyle(
                  color: switch (ch) {
                    '1' => AppColors.neonGreen,
                    '0' => AppColors.textDim,
                    _ => AppColors.neonCyan,
                  },
                  fontWeight: ch == '1' ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
          ],
        ),
        style: AppFonts.jetBrainsMono(
          fontSize: fontSize,
          letterSpacing: letterSpacing ?? fontSize * 0.18,
        ),
      ),
    );
  }
}
