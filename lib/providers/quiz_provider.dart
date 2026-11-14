import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/achievement.dart';
import '../models/quiz_models.dart';
import '../utils/quiz_generator.dart';
import 'progress_provider.dart';

/// Where the Quiz & Games screen currently is.
enum QuizPhase { menu, playing, results, fingerGame }

/// The quiz engine: questions, countdown timer, scoring, streaks, stars.
class QuizProvider extends ChangeNotifier {
  QuizProvider({required this.progress});

  final ProgressProvider progress;

  static const Map<Difficulty, int> questionCounts = {
    Difficulty.easy: 8,
    Difficulty.medium: 10,
    Difficulty.hard: 12,
  };
  static const Map<Difficulty, int> secondsPerQuestion = {
    Difficulty.easy: 20,
    Difficulty.medium: 15,
    Difficulty.hard: 10,
  };
  static const Map<Difficulty, int> basePoints = {
    Difficulty.easy: 10,
    Difficulty.medium: 15,
    Difficulty.hard: 20,
  };

  /// Flat bonus for completing the Daily Challenge.
  static const int dailyBonus = 25;

  QuizPhase phase = QuizPhase.menu;
  Difficulty difficulty = Difficulty.easy;
  bool isDaily = false;

  List<Question> questions = const [];
  int index = 0;
  int score = 0;
  int correctCount = 0;
  int streak = 0;
  int bestRoundStreak = 0;

  int timeLeft = 0;
  int totalTime = 0;

  int? selectedOption;
  bool answered = false;
  bool timedOut = false;

  int stars = 0;
  List<Achievement> newlyUnlocked = const [];

  Timer? _timer;

  Question? get currentQuestion =>
      (phase == QuizPhase.playing && index < questions.length)
          ? questions[index]
          : null;

  // ---------------------------------------------------------------- start
  void startQuiz(Difficulty d) {
    isDaily = false;
    difficulty = d;
    questions = QuizGenerator.generate(d, count: questionCounts[d]!);
    _begin();
  }

  /// One attempt per day; questions are seeded by the date.
  void startDailyChallenge() {
    if (!progress.dailyAvailable) return;
    isDaily = true;
    difficulty = Difficulty.medium; // medium timer & base points
    questions = QuizGenerator.daily();
    _begin();
  }

  void _begin() {
    index = 0;
    score = 0;
    correctCount = 0;
    streak = 0;
    bestRoundStreak = 0;
    selectedOption = null;
    answered = false;
    timedOut = false;
    stars = 0;
    newlyUnlocked = const [];
    phase = QuizPhase.playing;
    _startTimer();
    notifyListeners();
  }

  void openFingerGame() {
    phase = QuizPhase.fingerGame;
    notifyListeners();
  }

  void backToMenu() {
    _timer?.cancel();
    phase = QuizPhase.menu;
    notifyListeners();
  }

  void playAgain() => startQuiz(difficulty);

  // ---------------------------------------------------------------- timer
  void _startTimer() {
    _timer?.cancel();
    totalTime = secondsPerQuestion[difficulty]!;
    timeLeft = totalTime;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (answered || phase != QuizPhase.playing) return;
      timeLeft--;
      if (timeLeft <= 0) {
        timeLeft = 0;
        _onTimeout();
      }
      notifyListeners();
    });
  }

  void _onTimeout() {
    _timer?.cancel();
    answered = true;
    timedOut = true;
    selectedOption = null;
    streak = 0;
    notifyListeners();
    _scheduleNext();
  }

  // -------------------------------------------------------------- answers
  void answer(int optionIndex) {
    if (answered || phase != QuizPhase.playing) return;
    _timer?.cancel();
    answered = true;
    selectedOption = optionIndex;

    final question = questions[index];
    if (optionIndex == question.correctIndex) {
      correctCount++;
      streak++;
      if (streak > bestRoundStreak) bestRoundStreak = streak;

      final timeBonus = timeLeft;
      final streakBonus = streak >= 3 ? 5 : 0;
      score += basePoints[difficulty]! + timeBonus + streakBonus;
    } else {
      streak = 0;
    }
    notifyListeners();
    _scheduleNext();
  }

  void _scheduleNext() {
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (phase != QuizPhase.playing) return;
      if (index + 1 >= questions.length) {
        _finish();
      } else {
        index++;
        selectedOption = null;
        answered = false;
        timedOut = false;
        _startTimer();
        notifyListeners();
      }
    });
  }

  // -------------------------------------------------------------- results
  void _finish() {
    _timer?.cancel();
    final ratio = questions.isEmpty ? 0.0 : correctCount / questions.length;
    stars = ratio == 1
        ? 3
        : ratio >= 0.75
            ? 2
            : ratio >= 0.5
                ? 1
                : 0;

    if (isDaily) score += dailyBonus;

    phase = QuizPhase.results;
    newlyUnlocked = isDaily
        ? progress.completeDaily(
            score: score,
            correct: correctCount,
            total: questions.length,
            stars: stars,
            bestRoundStreak: bestRoundStreak,
          )
        : progress.recordQuiz(
            difficulty: difficulty,
            score: score,
            correct: correctCount,
            total: questions.length,
            stars: stars,
            bestRoundStreak: bestRoundStreak,
          );
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
