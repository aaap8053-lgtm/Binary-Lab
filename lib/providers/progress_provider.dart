import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';
import '../models/quiz_models.dart';

/// Everything persistent about the student. Backed by shared_preferences.
class ProgressProvider extends ChangeNotifier {
  ProgressProvider(this._prefs) {
    _load();
  }

  final SharedPreferences _prefs;

  static const _kPoints = 'bl_points';
  static const _kStars = 'bl_stars';
  static const _kBestStreak = 'bl_best_streak';
  static const _kQuizzes = 'bl_quizzes';
  static const _kFingerRounds = 'bl_finger_rounds';
  static const _kHistory = 'bl_history';
  static const _kAchievements = 'bl_achievements';
  static const _kDailyDate = 'bl_daily_date';
  static const _kDailyBest = 'bl_daily_best';
  static const _kDailyCount = 'bl_daily_count';

  int totalPoints = 0;
  int totalStars = 0;
  int bestStreak = 0;
  int quizzesCompleted = 0;
  int fingerRounds = 0;
  List<QuizResult> history = [];
  final Set<String> unlockedIds = {};

  // ---- Daily challenge state ----
  String? lastDailyDate;
  int dailyBest = 0;
  int dailyCompletedCount = 0;

  /// "2026-11-14" — resets at midnight, local time.
  String get todayKey {
    final n = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${n.year}-${two(n.month)}-${two(n.day)}';
  }

  bool get dailyAvailable => lastDailyDate != todayKey;

  // ---------------------------------------------------------------- loading
  void _load() {
    totalPoints = _prefs.getInt(_kPoints) ?? 0;
    totalStars = _prefs.getInt(_kStars) ?? 0;
    bestStreak = _prefs.getInt(_kBestStreak) ?? 0;
    quizzesCompleted = _prefs.getInt(_kQuizzes) ?? 0;
    fingerRounds = _prefs.getInt(_kFingerRounds) ?? 0;
    lastDailyDate = _prefs.getString(_kDailyDate);
    dailyBest = _prefs.getInt(_kDailyBest) ?? 0;
    dailyCompletedCount = _prefs.getInt(_kDailyCount) ?? 0;

    try {
      final rawHistory = _prefs.getString(_kHistory);
      if (rawHistory != null) {
        final list = jsonDecode(rawHistory) as List<dynamic>;
        history = [
          for (final e in list) QuizResult.fromJson(e as Map<String, dynamic>),
        ];
      }
      final rawBadges = _prefs.getString(_kAchievements);
      if (rawBadges != null) {
        unlockedIds
            .addAll((jsonDecode(rawBadges) as List<dynamic>).cast<String>());
      }
    } catch (_) {
      // Corrupt storage should never crash the app.
    }
  }

  Future<void> _save() async {
    await _prefs.setInt(_kPoints, totalPoints);
    await _prefs.setInt(_kStars, totalStars);
    await _prefs.setInt(_kBestStreak, bestStreak);
    await _prefs.setInt(_kQuizzes, quizzesCompleted);
    await _prefs.setInt(_kFingerRounds, fingerRounds);
    await _prefs.setString(
        _kHistory, jsonEncode([for (final r in history) r.toJson()]));
    await _prefs.setString(_kAchievements, jsonEncode(unlockedIds.toList()));
    await _prefs.setString(_kDailyDate, lastDailyDate ?? '');
    await _prefs.setInt(_kDailyBest, dailyBest);
    await _prefs.setInt(_kDailyCount, dailyCompletedCount);
  }

  // ---------------------------------------------------------------- levels
  ({int level, int into, int needed}) get levelInfo {
    var pts = totalPoints;
    var lvl = 1;
    var need = 100;
    while (pts >= need) {
      pts -= need;
      lvl++;
      need += 50;
    }
    return (level: lvl, into: pts, needed: need);
  }

  bool isUnlocked(String id) => unlockedIds.contains(id);

  // -------------------------------------------------------------- recording
  List<Achievement> recordQuiz({
    required Difficulty difficulty,
    required int score,
    required int correct,
    required int total,
    required int stars,
    required int bestRoundStreak,
  }) {
    _applyQuizStats(
      score: score,
      correct: correct,
      total: total,
      stars: stars,
      difficulty: difficulty,
      bestRoundStreak: bestRoundStreak,
    );
    final newly = _checkAchievements(
      perfect: correct == total,
      hardDone: difficulty == Difficulty.hard,
      roundStars: stars,
      roundStreak: bestRoundStreak,
    );
    _save();
    notifyListeners();
    return newly;
  }

  /// Records a completed Daily Challenge (call once per day).
  List<Achievement> completeDaily({
    required int score,
    required int correct,
    required int total,
    required int stars,
    required int bestRoundStreak,
  }) {
    lastDailyDate = todayKey;
    dailyCompletedCount++;
    if (score > dailyBest) dailyBest = score;

    _applyQuizStats(
      score: score,
      correct: correct,
      total: total,
      stars: stars,
      difficulty: Difficulty.hard,
      bestRoundStreak: bestRoundStreak,
    );
    final newly = _checkAchievements(
      perfect: correct == total,
      hardDone: true,
      roundStars: stars,
      roundStreak: bestRoundStreak,
    );
    _save();
    notifyListeners();
    return newly;
  }

  void _applyQuizStats({
    required int score,
    required int correct,
    required int total,
    required int stars,
    required Difficulty difficulty,
    required int bestRoundStreak,
  }) {
    totalPoints += score;
    totalStars += stars;
    quizzesCompleted++;
    if (bestRoundStreak > bestStreak) bestStreak = bestRoundStreak;

    history.insert(
      0,
      QuizResult(
        difficulty: difficulty,
        score: score,
        correct: correct,
        total: total,
        stars: stars,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (history.length > 20) history = history.sublist(0, 20);
  }

  List<Achievement> recordFingerRound() {
    fingerRounds++;
    final newly = _checkAchievements();
    _save();
    notifyListeners();
    return newly;
  }

  // -------------------------------------------------------- achievements
  List<Achievement> _checkAchievements({
    bool perfect = false,
    bool hardDone = false,
    int roundStars = 0,
    int roundStreak = 0,
  }) {
    final newly = <Achievement>[];
    for (final achievement in Achievements.all) {
      if (unlockedIds.contains(achievement.id)) continue;
      if (_isMet(
        achievement.id,
        perfect: perfect,
        hardDone: hardDone,
        roundStars: roundStars,
        roundStreak: roundStreak,
      )) {
        unlockedIds.add(achievement.id);
        newly.add(achievement);
      }
    }
    return newly;
  }

  bool _isMet(
    String id, {
    required bool perfect,
    required bool hardDone,
    required int roundStars,
    required int roundStreak,
  }) =>
      switch (id) {
        'first_quiz' => quizzesCompleted >= 1,
        'perfect' => perfect,
        'streak_5' => roundStreak >= 5 || bestStreak >= 5,
        'streak_10' => roundStreak >= 10 || bestStreak >= 10,
        'hard_finish' => hardDone,
        'three_stars' => roundStars == 3,
        'daily_first' => dailyCompletedCount >= 1,
        'daily_5' => dailyCompletedCount >= 5,
        'ten_quizzes' => quizzesCompleted >= 10,
        'points_500' => totalPoints >= 500,
        'points_1000' => totalPoints >= 1000,
        'finger_5' => fingerRounds >= 5,
        _ => false,
      };
}
