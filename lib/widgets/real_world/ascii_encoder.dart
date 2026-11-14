import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/binary_utils.dart';
import '../binary_text.dart';

/// Type a name and watch every character become a number, then bits.
class AsciiEncoder extends StatefulWidget {
  const AsciiEncoder({super.key});

  @override
  State<AsciiEncoder> createState() => _AsciiEncoderState();
}

class _AsciiEncoderState extends State<AsciiEncoder> {
  final TextEditingController _controller = TextEditingController();
  String _text = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    // runes = correct Unicode code points (handles emoji & Arabic script).
    final runes = _text.runes.take(20).toList();

    return Column(
      children: [
        TextField(
          controller: _controller,
          onChanged: (v) => setState(() => _text = v),
          style: const TextStyle(
              fontSize: 16,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500),
          decoration: InputDecoration(
            hintText: lang.t('asciiHint'),
            hintStyle:
                const TextStyle(color: AppColors.textDim, fontSize: 13.5),
            prefixIcon: const Icon(Icons.alternate_email,
                color: AppColors.neonCyan, size: 20),
            filled: true,
            fillColor: AppColors.background.withValues(alpha: 0.5),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.neonGreen, width: 1.8),
            ),
          ),
        ),
        const SizedBox(height: 14),
        if (_text.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    'A  →  65  →  01000001',
                    style: AppFonts.jetBrainsMono(
                        fontSize: 13.5,
                        color: AppColors.textDim,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          )
        else
          ...runes.map((rune) => _charRow(rune, lang)),
      ],
    );
  }

  Widget _charRow(int codePoint, LanguageProvider lang) {
    final char = String.fromCharCode(codePoint);
    final binary = BinaryUtils.toBinary(codePoint, minBits: 8);
    final needsMoreThan8Bits = codePoint > 255;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.03),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          // The character itself
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.neonGreen.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
            ),
            alignment: Alignment.center,
            child: Text(char,
                style: const TextStyle(
                    fontSize: 19,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 14),
          // Its decimal code point
          SizedBox(
            width: 60,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$codePoint',
                style: AppFonts.jetBrainsMono(
                    fontSize: 15,
                    color: AppColors.neonGreen,
                    fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Icon(Icons.arrow_right_alt,
              size: 18, color: AppColors.neonCyan),
          const SizedBox(width: 10),
          // …in binary
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              reverse:
                  true, // keeps the LSB visible if the row overflows in RTL
              child: BinaryText(binary, fontSize: 13.5),
            ),
          ),
          if (needsMoreThan8Bits) ...[
            const SizedBox(width: 8),
            Tooltip(
              message: lang.t('unicodeNote'),
              child: const Icon(Icons.info_outline,
                  size: 18, color: AppColors.neonAmber),
            ),
          ],
        ],
      ),
    );
  }
}
