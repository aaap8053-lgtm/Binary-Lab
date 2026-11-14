import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/quiz_models.dart';
import '../../providers/language_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/binary_utils.dart';
import '../binary_text.dart';

/// The prompt + the 4 answer buttons for the current question.
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.question,
    required this.answered,
    required this.selectedIndex,
    required this.onAnswer,
  });

  final Question question;
  final bool answered;
  final int? selectedIndex;
  final ValueChanged<int> onAnswer;

  String _prompt(LanguageProvider lang) {
    return switch (question.type) {
      QuestionType.decimalToBinary =>
        lang.t('qDecToBin', {'x': '${question.decimalValue}'}),
      QuestionType.binaryToDecimal =>
        lang.t('qBinToDec', {'x': question.binaryText}),
      QuestionType.powerOfTwo =>
        lang.t('qPower', {'x': BinaryUtils.powerLabel(question.power)}),
      QuestionType.hexToDecimal => lang.t(
          'qHexToDec', {'x': '0x${BinaryUtils.hex2(question.decimalValue)}'}),
      QuestionType.sequence => lang.t('qSequence'),
    };
  }

  Widget _promptValue() {
    return switch (question.type) {
      QuestionType.decimalToBinary => Text(
          '${question.decimalValue}',
          style: AppFonts.orbitron(
            fontSize: 46,
            fontWeight: FontWeight.w700,
            color: AppColors.neonGreen,
            shadows: [
              Shadow(
                  color: AppColors.neonGreen.withValues(alpha: 0.4),
                  blurRadius: 20),
            ],
          ),
        ),
      QuestionType.binaryToDecimal =>
        BinaryText(question.binaryText, fontSize: 28, letterSpacing: 6),
      QuestionType.powerOfTwo => Text(
          '${BinaryUtils.powerLabel(question.power)} = ?',
          style: AppFonts.orbitron(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: AppColors.neonCyan,
            shadows: [
              Shadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.4),
                  blurRadius: 20),
            ],
          ),
        ),
      QuestionType.hexToDecimal => Text(
          '0x${BinaryUtils.hex2(question.decimalValue)}',
          style: AppFonts.jetBrainsMono(
            fontSize: 42,
            fontWeight: FontWeight.w700,
            color: AppColors.neonCyan,
            shadows: [
              Shadow(
                  color: AppColors.neonCyan.withValues(alpha: 0.4),
                  blurRadius: 20),
            ],
          ),
        ),
      QuestionType.sequence => () {
          final s = question.decimalValue;
          return Text(
            '$s, ${s * 2}, ${s * 4}, ${s * 8}, ?',
            style: AppFonts.orbitron(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.neonGreen,
              shadows: [
                Shadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.4),
                    blurRadius: 18),
              ],
            ),
          );
        }(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: Column(
            children: [
              Text(
                _prompt(lang),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.textDim),
              ),
              const SizedBox(height: 12),
              FittedBox(fit: BoxFit.scaleDown, child: _promptValue()),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: [
            for (var i = 0; i < question.options.length; i++)
              _OptionButton(
                text: question.options[i],
                isBinary: question.type == QuestionType.decimalToBinary,
                state: _stateFor(i),
                onTap: answered ? null : () => onAnswer(i),
              ),
          ],
        ),
      ],
    );
  }

  _OptionState _stateFor(int i) {
    if (!answered) return _OptionState.idle;
    if (i == question.correctIndex) return _OptionState.correct;
    if (i == selectedIndex) return _OptionState.wrong;
    return _OptionState.dimmed;
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.text,
    required this.isBinary,
    required this.state,
    required this.onTap,
  });

  final String text;
  final bool isBinary;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final (Color border, Color background) = switch (state) {
      _OptionState.idle => (AppColors.cardBorder, AppColors.card),
      _OptionState.correct => (
          AppColors.neonGreen,
          AppColors.neonGreen.withValues(alpha: 0.12)
        ),
      _OptionState.wrong => (
          AppColors.neonRed,
          AppColors.neonRed.withValues(alpha: 0.10)
        ),
      _OptionState.dimmed => (AppColors.cardBorder, AppColors.surface),
    };

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: border, width: state == _OptionState.idle ? 1 : 1.6),
          boxShadow: state == _OptionState.correct
              ? [
                  BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.3),
                      blurRadius: 16)
                ]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: isBinary
                    ? BinaryText(text, fontSize: 15)
                    : Text(
                        text,
                        style: AppFonts.jetBrainsMono(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: state == _OptionState.dimmed
                              ? AppColors.textDim
                              : AppColors.textPrimary,
                        ),
                      ),
              ),
            ),
            if (state == _OptionState.correct) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check_circle,
                  size: 18, color: AppColors.neonGreen),
            ],
            if (state == _OptionState.wrong) ...[
              const SizedBox(width: 8),
              const Icon(Icons.cancel, size: 18, color: AppColors.neonRed),
            ],
          ],
        ),
      ),
    );
  }
}
