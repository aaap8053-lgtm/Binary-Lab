import 'package:flutter/material.dart';

/// A badge the student can unlock. Conditions live in ProgressProvider.
class Achievement {
  const Achievement({
    required this.id,
    required this.nameKey,
    required this.descKey,
    required this.icon,
  });

  final String id;
  final String nameKey;
  final String descKey;
  final IconData icon;
}

class Achievements {
  Achievements._();

  static const List<Achievement> all = [
    Achievement(
        id: 'first_quiz',
        nameKey: 'achFirstQuiz',
        descKey: 'achFirstQuizD',
        icon: Icons.flag),
    Achievement(
        id: 'perfect',
        nameKey: 'achPerfect',
        descKey: 'achPerfectD',
        icon: Icons.verified),
    Achievement(
        id: 'streak_5',
        nameKey: 'achStreak5',
        descKey: 'achStreak5D',
        icon: Icons.local_fire_department),
    Achievement(
        id: 'streak_10',
        nameKey: 'achStreak10',
        descKey: 'achStreak10D',
        icon: Icons.bolt),
    Achievement(
        id: 'hard_finish',
        nameKey: 'achHard',
        descKey: 'achHardD',
        icon: Icons.whatshot),
    Achievement(
        id: 'three_stars',
        nameKey: 'achStars3',
        descKey: 'achStars3D',
        icon: Icons.star),
    Achievement(
        id: 'daily_first',
        nameKey: 'achDaily',
        descKey: 'achDailyD',
        icon: Icons.today),
    Achievement(
        id: 'daily_5',
        nameKey: 'achDaily5',
        descKey: 'achDaily5D',
        icon: Icons.event_repeat),
    Achievement(
        id: 'ten_quizzes',
        nameKey: 'achTenQuizzes',
        descKey: 'achTenQuizzesD',
        icon: Icons.menu_book),
    Achievement(
        id: 'points_500',
        nameKey: 'achPoints500',
        descKey: 'achPoints500D',
        icon: Icons.trending_up),
    Achievement(
        id: 'points_1000',
        nameKey: 'achPoints1000',
        descKey: 'achPoints1000D',
        icon: Icons.diamond),
    Achievement(
        id: 'finger_5',
        nameKey: 'achFinger5',
        descKey: 'achFinger5D',
        icon: Icons.front_hand),
  ];
}
