import 'package:binary_lab/utils/feedback.dart';
import 'package:binary_lab/widgets/count_up.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/app_colors.dart';

/// Score summary with confetti, popping stars and newly unlocked badges.
class ResultView extends StatefulWidget {
  const ResultView({super.key});

  @override
  State<ResultView> createState() => _ResultViewState();
}

class _ResultViewState extends State<ResultView> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(seconds: 4));
  int _shownStars = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final quiz = context.read<QuizProvider>();
      if (!mounted) return;
      if (quiz.stars > 0) _confetti.play();
      if (quiz.stars > 0) FeedbackFx.win();
      // Reveal stars one by one.
      for (var i = 0; i < quiz.stars; i++) {
        Future.delayed(Duration(milliseconds: 400 + i * 400), () {
          if (mounted) setState(() => _shownStars = i + 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final lang = context.watch<LanguageProvider>();
    final accuracy = quiz.questions.isEmpty
        ? 0
        : (quiz.correctCount / quiz.questions.length * 100).round();

    return Stack(
      children: [
        // Confetti rain (never blocks touches).
        Positioned.fill(
          child: IgnorePointer(
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.neonGreen,
                AppColors.neonCyan,
                Colors.white,
                AppColors.neonAmber,
              ],
              gravity: 0.12,
              numberOfParticles: 22,
              emissionFrequency: 0.05,
            ),
          ),
        ),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    lang.t('quizResults'),
                    style: AppFonts.orbitron(
                        fontSize: 22, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 18),
                  _StarsRow(stars: quiz.stars, shown: _shownStars),
                  const SizedBox(height: 18),
                  CountUp(
                    value: quiz.score,
                    style: AppFonts.orbitron(
                      fontSize: 56,
                      fontWeight: FontWeight.w700,
                      color: AppColors.neonGreen,
                      shadows: [
                        Shadow(
                          color: AppColors.neonGreen.withValues(alpha: 0.45),
                          blurRadius: 26,
                        ),
                      ],
                    ),
                  ),
                  Text(
                    lang.t('pointsEarned'),
                    style:
                        const TextStyle(color: AppColors.textDim, fontSize: 13),
                  ),
                  const SizedBox(height: 18),
                  // Stats row
                  Row(
                    children: [
                      Expanded(
                        child: _StatBox(
                          label: lang.t('accuracy'),
                          value: '$accuracy%',
                          color: AppColors.neonCyan,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(
                          label: lang.t('correctAnswers', {
                            'a': '${quiz.correctCount}',
                            'b': '${quiz.questions.length}',
                          }),
                          value:
                              '${quiz.correctCount}/${quiz.questions.length}',
                          color: AppColors.neonGreen,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _StatBox(
                          label: lang.t('bestStreakLabel'),
                          value: '🔥 ${quiz.bestRoundStreak}',
                          color: AppColors.neonAmber,
                        ),
                      ),
                    ],
                  ),
                  if (quiz.newlyUnlocked.isNotEmpty) ...[
                    const SizedBox(height: 18),
                    Text(
                      '🏆 ${lang.t('newBadge')}',
                      style: const TextStyle(
                          color: AppColors.neonAmber, fontSize: 13.5),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final badge in quiz.newlyUnlocked)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 7),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.neonAmber.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(999),
                              border: Border.all(
                                  color: AppColors.neonAmber
                                      .withValues(alpha: 0.5)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(badge.icon,
                                    size: 15, color: AppColors.neonAmber),
                                const SizedBox(width: 6),
                                Text(
                                  lang.t(badge.nameKey),
                                  style: const TextStyle(
                                      fontSize: 12, color: AppColors.neonAmber),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      Expanded(
                        child: _NeonButton(
                          label: lang.t('playAgain'),
                          icon: Icons.replay,
                          filled: true,
                          onTap: quiz.playAgain,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _NeonButton(
                          label: lang.t('backToMenu'),
                          icon: Icons.list,
                          onTap: quiz.backToMenu,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow({required this.stars, required this.shown});

  final int stars;
  final int shown;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < 3; i++)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: AnimatedScale(
              scale: i < shown ? 1.0 : 0.5,
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutBack,
              child: Icon(
                i < stars ? Icons.star : Icons.star_border,
                size: 54,
                color: i < stars ? AppColors.neonAmber : AppColors.cardBorder,
                shadows: i < stars && i < shown
                    ? [
                        Shadow(
                            color: AppColors.neonAmber.withValues(alpha: 0.5),
                            blurRadius: 18)
                      ]
                    : const [],
              ),
            ),
          ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: AppFonts.jetBrainsMono(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textDim),
          ),
        ],
      ),
    );
  }
}

class _NeonButton extends StatelessWidget {
  const _NeonButton({
    required this.label,
    required this.icon,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: filled ? AppColors.neonGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: filled
                ? AppColors.neonGreen
                : AppColors.neonCyan.withValues(alpha: 0.6),
            width: 1.5,
          ),
          boxShadow: filled
              ? [
                  BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.35),
                      blurRadius: 18)
                ]
              : const [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 18,
                color: filled ? const Color(0xFF03231A) : AppColors.neonCyan),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppFonts.spaceGrotesk(
                fontSize: 14.5,
                fontWeight: FontWeight.w700,
                color: filled ? const Color(0xFF03231A) : AppColors.neonCyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
