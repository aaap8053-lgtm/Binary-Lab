import 'package:binary_lab/widgets/animated_entrance.dart';
import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../models/quiz_models.dart';
import '../../providers/language_provider.dart';
import '../../providers/progress_provider.dart';
import '../../providers/quiz_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/feedback.dart';

/// Idle state of the Quiz tab: daily challenge, difficulties, Finger Binary.
class QuizMenu extends StatelessWidget {
  const QuizMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        AnimatedEntrance(
          child: Text(
            lang.t('quizMenuTitle'),
            textAlign: TextAlign.center,
            style:
                AppFonts.orbitron(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 16),
        const AnimatedEntrance(delayMs: 60, child: _DailyCard()),
        const SizedBox(height: 12),
        for (var i = 0; i < Difficulty.values.length; i++) ...[
          AnimatedEntrance(
            delayMs: 130 + i * 70,
            child: _DifficultyCard(difficulty: Difficulty.values[i]),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 8),
        AnimatedEntrance(delayMs: 350, child: _FingerGameBanner()),
      ],
    );
  }
}

/// 📅 Once per day · seeded questions · +25 bonus.
class _DailyCard extends StatelessWidget {
  const _DailyCard();

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final progress = context.watch<ProgressProvider>();
    final quiz = context.read<QuizProvider>();
    final available = progress.dailyAvailable;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: available
          ? () {
              FeedbackFx.tap();
              quiz.startDailyChallenge();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: available
              ? LinearGradient(
                  colors: [
                    AppColors.neonAmber.withValues(alpha: 0.16),
                    AppColors.card,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: available ? null : AppColors.surface,
          border: Border.all(
            color: available
                ? AppColors.neonAmber.withValues(alpha: 0.55)
                : AppColors.cardBorder,
          ),
          boxShadow: available
              ? [
                  BoxShadow(
                    color: AppColors.neonAmber.withValues(alpha: 0.15),
                    blurRadius: 22,
                  ),
                ]
              : const [],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.neonAmber.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                    color: AppColors.neonAmber.withValues(alpha: 0.5)),
              ),
              child: Icon(
                available ? Icons.calendar_month : Icons.check_circle,
                color: AppColors.neonAmber,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('dailyTitle'),
                    style: AppFonts.orbitron(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    available
                        ? lang.t('dailyDesc')
                        : lang.t('dailyDone', {'x': '${progress.dailyBest}'}),
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textDim),
                  ),
                ],
              ),
            ),
            Icon(
              available ? Icons.play_arrow_rounded : Icons.lock_clock,
              color: available ? AppColors.neonAmber : AppColors.textDim,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyCard extends StatelessWidget {
  const _DifficultyCard({required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final quiz = context.read<QuizProvider>();
    final color = difficulty.color;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        FeedbackFx.tap();
        quiz.startQuiz(difficulty);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35)),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withValues(alpha: 0.5)),
              ),
              child: Icon(difficulty.icon, color: color, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t(difficulty.nameKey),
                    style: AppFonts.orbitron(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${lang.t(difficulty.descKey)} · ${lang.t('questionsCount', {
                          'n': '${QuizProvider.questionCounts[difficulty]}',
                        })}',
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textDim),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_arrow_rounded, color: color, size: 30),
          ],
        ),
      ),
    );
  }
}

class _FingerGameBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final quiz = context.read<QuizProvider>();

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        FeedbackFx.tap();
        quiz.openFingerGame();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              AppColors.neonGreen.withValues(alpha: 0.14),
              AppColors.neonCyan.withValues(alpha: 0.10),
            ],
          ),
          border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.5)),
        ),
        child: Row(
          children: [
            const Icon(Icons.front_hand, color: AppColors.neonGreen, size: 34),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.t('fingerGameName'),
                    style: AppFonts.orbitron(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    lang.t('fingerGameDesc'),
                    style:
                        const TextStyle(fontSize: 12, color: AppColors.textDim),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.neonGreen),
          ],
        ),
      ),
    );
  }
}
