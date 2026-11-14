import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/achievement.dart';
import '../../providers/language_provider.dart';
import '../../providers/progress_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/binary_utils.dart';
import '../binary_text.dart';

/// "Finger Binary": 5 fingers = bits 16/8/4/2/1.
/// The student raises fingers to build the target number.
class FingerGame extends StatefulWidget {
  const FingerGame({super.key, required this.onExit});

  final VoidCallback onExit;

  @override
  State<FingerGame> createState() => _FingerGameState();
}

class _FingerGameState extends State<FingerGame> {
  static const List<int> _values = [16, 8, 4, 2, 1];

  final Random _rng = Random();
  final List<bool> _raised = List.filled(5, false);

  late int _target = _newTarget();
  int _score = 0;
  bool _solved = false;
  String? _feedback; // 'correct' | 'wrong'

  int get _sum {
    var sum = 0;
    for (var i = 0; i < 5; i++) {
      if (_raised[i]) sum += _values[i];
    }
    return sum;
  }

  int _newTarget() => 1 + _rng.nextInt(31);

  void _toggle(int i) {
    if (_solved) return;
    HapticFeedback.selectionClick();
    setState(() {
      _raised[i] = !_raised[i];
      _feedback = null;
    });
  }

  void _check() {
    if (_solved) return;
    if (_sum == _target) {
      HapticFeedback.mediumImpact();
      setState(() {
        _solved = true;
        _feedback = 'correct';
        _score += 10;
      });
      final newly = context.read<ProgressProvider>().recordFingerRound();
      _announceBadges(newly);
      // Move to the next round after a short celebration pause.
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (mounted) _nextRound();
      });
    } else {
      HapticFeedback.lightImpact();
      setState(() => _feedback = 'wrong');
    }
  }

  void _nextRound() {
    setState(() {
      _target = _newTarget();
      _raised.fillRange(0, 5, false);
      _solved = false;
      _feedback = null;
    });
  }

  void _announceBadges(List<Achievement> newly) {
    if (newly.isEmpty || !mounted) return;
    final lang = context.read<LanguageProvider>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text('🏆 ${lang.t('newBadge')} ${lang.t(newly.first.nameKey)}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
      child: Column(
        children: [
          // Top bar
          Row(
            children: [
              IconButton(
                tooltip: lang.t('fingerBack'),
                icon: const Icon(Icons.close, color: AppColors.textDim),
                onPressed: widget.onExit,
              ),
              Expanded(
                child: Text(
                  lang.t('fingerGameName'),
                  style: AppFonts.orbitron(
                      fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.3)),
                ),
                child: Text(
                  '$_score',
                  style: AppFonts.jetBrainsMono(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neonGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Target
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Column(
              children: [
                Text(
                  lang.t('fingerTarget', {'x': '$_target'}),
                  style:
                      const TextStyle(color: AppColors.textDim, fontSize: 13.5),
                ),
                const SizedBox(height: 6),
                Text(
                  '$_target',
                  style: AppFonts.orbitron(
                    fontSize: 46,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neonCyan,
                    shadows: [
                      Shadow(
                          color: AppColors.neonCyan.withValues(alpha: 0.4),
                          blurRadius: 20),
                    ],
                  ),
                ),
                if (_solved) ...[
                  const SizedBox(height: 6),
                  // Learning moment: reveal the answer in binary.
                  BinaryText(BinaryUtils.toBinary(_target, minBits: 5),
                      fontSize: 15),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            lang.t('fingerTapHint'),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.textDim, fontSize: 12.5),
          ),
          const SizedBox(height: 8),
          // The hand (bits always read left → right).
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  _Finger(
                    value: _values[i],
                    raised: _raised[i],
                    onTap: () => _toggle(i),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Live readout of the student's current number.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${lang.t('fingerYourSum')}: ',
                  style:
                      const TextStyle(fontSize: 13, color: AppColors.textDim),
                ),
                Text(
                  '$_sum',
                  style: AppFonts.jetBrainsMono(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neonGreen,
                  ),
                ),
                const SizedBox(width: 12),
                BinaryText(BinaryUtils.toBinary(_sum, minBits: 5),
                    fontSize: 13),
              ],
            ),
          ),
          // Feedback
          SizedBox(
            height: 28,
            child: _feedback == null
                ? null
                : Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      _feedback == 'correct'
                          ? lang.t('fingerCorrect')
                          : lang.t('fingerWrong'),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _feedback == 'correct'
                            ? AppColors.neonGreen
                            : AppColors.neonRed,
                      ),
                    ),
                  ),
          ),
          const Spacer(),
          // Actions
          Row(
            children: [
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: _solved ? null : _check,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: _solved
                          ? AppColors.neonGreen.withValues(alpha: 0.35)
                          : AppColors.neonGreen,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _solved
                          ? const []
                          : [
                              BoxShadow(
                                color:
                                    AppColors.neonGreen.withValues(alpha: 0.35),
                                blurRadius: 18,
                              ),
                            ],
                    ),
                    child: Center(
                      child: Text(
                        lang.t('fingerCheck'),
                        style: AppFonts.spaceGrotesk(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF03231A),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: _nextRound,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.6),
                      width: 1.5,
                    ),
                  ),
                  child: Text(
                    lang.t('fingerNew'),
                    style: AppFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.neonCyan,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One tappable finger. Raised = tall + glowing green.
class _Finger extends StatelessWidget {
  const _Finger(
      {required this.value, required this.raised, required this.onTap});

  final int value;
  final bool raised;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          SizedBox(
            width: 42,
            height: 122,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                width: 38,
                height: raised ? 108 : 52,
                decoration: BoxDecoration(
                  gradient: raised
                      ? const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [AppColors.neonGreen, Color(0xFF00C97B)],
                        )
                      : null,
                  color: raised ? null : AppColors.card,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(19),
                    bottom: Radius.circular(8),
                  ),
                  border: Border.all(
                    color: raised ? AppColors.neonGreen : AppColors.cardBorder,
                  ),
                  boxShadow: raised
                      ? [
                          BoxShadow(
                            color: AppColors.neonGreen.withValues(alpha: 0.4),
                            blurRadius: 16,
                          ),
                        ]
                      : const [],
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$value',
            style: AppFonts.jetBrainsMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: raised ? AppColors.neonGreen : AppColors.textDim,
            ),
          ),
        ],
      ),
    );
  }
}
