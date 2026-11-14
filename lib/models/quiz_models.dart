import 'package:flutter/material.dart';

import '../utils/app_colors.dart';

/// Quiz difficulty. Each one changes number range, bit width, timer and points.
enum Difficulty { easy, medium, hard }

extension DifficultyMeta on Difficulty {
  int get maxValue => switch (this) {
        Difficulty.easy => 31,
        Difficulty.medium => 127,
        Difficulty.hard => 255,
      };

  int get minBits => switch (this) {
        Difficulty.easy => 5,
        Difficulty.medium => 7,
        Difficulty.hard => 8,
      };

  int get maxPower => switch (this) {
        Difficulty.easy => 5,
        Difficulty.medium => 7,
        Difficulty.hard => 8,
      };

  String get nameKey => switch (this) {
        Difficulty.easy => 'easyName',
        Difficulty.medium => 'mediumName',
        Difficulty.hard => 'hardName',
      };

  String get descKey => switch (this) {
        Difficulty.easy => 'easyDesc',
        Difficulty.medium => 'mediumDesc',
        Difficulty.hard => 'hardDesc',
      };

  Color get color => switch (this) {
        Difficulty.easy => AppColors.neonGreen,
        Difficulty.medium => AppColors.neonAmber,
        Difficulty.hard => AppColors.neonRed,
      };

  IconData get icon => switch (this) {
        Difficulty.easy => Icons.sentiment_satisfied_alt,
        Difficulty.medium => Icons.speed,
        Difficulty.hard => Icons.local_fire_department,
      };
}

/// All question kinds. Hex + sequences added in Part 3.
enum QuestionType {
  decimalToBinary,
  binaryToDecimal,
  powerOfTwo,
  hexToDecimal,
  sequence,
}

/// One quiz question with 4 shuffled options.
class Question {
  const Question({
    required this.type,
    required this.decimalValue,
    required this.binaryText,
    required this.power,
    required this.options,
    required this.correctIndex,
  });

  final QuestionType type;

  /// decimal→binary: the prompt value · hex→decimal: the value behind 0x.. ·
  /// sequence: the starting number of the doubling series.
  final int decimalValue;

  /// Used by binary→decimal prompts.
  final String binaryText;

  /// Used by "2^n = ?" prompts.
  final int power;

  final List<String> options;
  final int correctIndex;
}

/// A finished quiz, stored in the local history.
class QuizResult {
  const QuizResult({
    required this.difficulty,
    required this.score,
    required this.correct,
    required this.total,
    required this.stars,
    required this.timestamp,
  });

  final Difficulty difficulty;
  final int score;
  final int correct;
  final int total;
  final int stars;
  final int timestamp;

  Map<String, dynamic> toJson() => {
        'd': difficulty.index,
        's': score,
        'c': correct,
        't': total,
        'st': stars,
        'ts': timestamp,
      };

  factory QuizResult.fromJson(Map<String, dynamic> json) => QuizResult(
        difficulty: Difficulty.values[json['d'] as int],
        score: json['s'] as int,
        correct: json['c'] as int,
        total: json['t'] as int,
        stars: json['st'] as int,
        timestamp: json['ts'] as int,
      );
}
