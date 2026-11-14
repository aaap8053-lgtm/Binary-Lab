import 'package:binary_lab/utils/feedback.dart';
import 'package:binary_lab/widgets/shake.dart';
import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/quiz_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/quiz/finger_game.dart';
import '../widgets/quiz/question_card.dart';
import '../widgets/quiz/quiz_menu.dart';
import '../widgets/quiz/result_view.dart';
import '../widgets/quiz/timer_bar.dart';

/// Screen 3 — Quiz & Games. A tiny state machine driven by QuizProvider.
class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();

    return switch (quiz.phase) {
      QuizPhase.menu => const QuizMenu(),
      QuizPhase.playing => const _PlayView(),
      QuizPhase.results => const ResultView(),
      QuizPhase.fingerGame => FingerGame(onExit: quiz.backToMenu),
    };
  }
}

/// The active quiz: header, countdown bar, question + options.
class _PlayView extends StatelessWidget {
  const _PlayView();

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizProvider>();
    final lang = context.watch<LanguageProvider>();
    final question = quiz.currentQuestion;

    if (question == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      child: Column(
        children: [
          // Header row: exit · progress · streak · score
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: IconButton(
                  tooltip: lang.t('backToMenu'),
                  icon: const Icon(Icons.close,
                      color: AppColors.textDim, size: 20),
                  onPressed: quiz.backToMenu,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  lang.t('questionProgress', {
                    'a': '${quiz.index + 1}',
                    'b': '${quiz.questions.length}',
                  }),
                  style: const TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textDim,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
              if (quiz.streak >= 2) ...[
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.neonAmber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                        color: AppColors.neonAmber.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    '🔥 ${quiz.streak}',
                    style: AppFonts.jetBrainsMono(
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                      color: AppColors.neonAmber,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                      color: AppColors.neonGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.stars,
                        size: 16, color: AppColors.neonGreen),
                    const SizedBox(width: 6),
                    Text(
                      '${quiz.score}',
                      style: AppFonts.jetBrainsMono(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Countdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer_outlined,
                  size: 18,
                  color: quiz.timeLeft <= 3
                      ? AppColors.neonRed
                      : AppColors.neonCyan,
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 36,
                  child: Text(
                    '${quiz.timeLeft}s',
                    style: AppFonts.jetBrainsMono(
                      fontSize: 13.5,
                      fontWeight: FontWeight.normal,
                      color: quiz.timeLeft <= 3
                          ? AppColors.neonRed
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TimerBar(
                      timeLeft: quiz.timeLeft, totalTime: quiz.totalTime),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Question + answers
          Expanded(
            child: ShakeWidget(
              trigger: (quiz.answered &&
                      quiz.selectedOption != null &&
                      quiz.selectedOption != question.correctIndex)
                  ? quiz.index + 1
                  : 0,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, anim) => SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0.08, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                      parent: anim, curve: Curves.easeOutCubic)),
                  child: FadeTransition(opacity: anim, child: child),
                ),
                child: QuestionCard(
                  key: ValueKey(quiz.index),
                  question: question,
                  answered: quiz.answered,
                  selectedIndex: quiz.selectedOption,
                  onAnswer: (i) {
                    if (!quiz.answered) {
                      if (i == question.correctIndex) {
                        FeedbackFx.success();
                      } else {
                        FeedbackFx.error();
                      }
                    }
                    quiz.answer(i);
                  },
                ),
              ),
            ),
          ),
          // Fixed-height feedback slot so the layout never jumps.
          SizedBox(
            height: 28,
            child: quiz.timedOut
                ? Center(
                    child: Text(
                      '⏰ ${lang.t('timeUp')}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                        color: AppColors.neonRed,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
