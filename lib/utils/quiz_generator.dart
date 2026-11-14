import 'dart:math';

import '../models/quiz_models.dart';
import 'binary_utils.dart';

/// Generates randomized questions. Accepts an external [Random] so the
/// Daily Challenge can be seeded by the calendar date (same quiz for
/// everyone on the same day).
class QuizGenerator {
  QuizGenerator._();

  static List<Question> generate(Difficulty difficulty, {required int count}) =>
      _build(Random(), difficulty, count);

  /// Today's challenge: 5 mixed questions over the full 8-bit range.
  static List<Question> daily() {
    final now = DateTime.now();
    final rng = Random(now.year * 372 + now.month * 31 + now.day);
    const types = [
      QuestionType.decimalToBinary,
      QuestionType.binaryToDecimal,
      QuestionType.powerOfTwo,
      QuestionType.hexToDecimal,
      QuestionType.sequence,
    ];
    return [for (final type in types) _make(type, Difficulty.hard, rng)];
  }

  // ------------------------------------------------------------------ core
  static List<Question> _build(Random rng, Difficulty d, int count) {
    final pool = _typesFor(d);
    return [
      for (var i = 0; i < count; i++)
        _make(pool[rng.nextInt(pool.length)], d, rng),
    ];
  }

  static List<QuestionType> _typesFor(Difficulty d) => switch (d) {
        Difficulty.easy => const [
            QuestionType.decimalToBinary,
            QuestionType.binaryToDecimal,
            QuestionType.powerOfTwo,
            QuestionType.sequence,
          ],
        Difficulty.medium || Difficulty.hard => const [
            QuestionType.decimalToBinary,
            QuestionType.binaryToDecimal,
            QuestionType.powerOfTwo,
            QuestionType.sequence,
            QuestionType.hexToDecimal,
          ],
      };

  static Question _make(QuestionType type, Difficulty d, Random rng) {
    return switch (type) {
      QuestionType.decimalToBinary => _decimalToBinary(d, rng),
      QuestionType.binaryToDecimal => _binaryToDecimal(d, rng),
      QuestionType.powerOfTwo => _powerOfTwo(d, rng),
      QuestionType.hexToDecimal => _hexToDecimal(d, rng),
      QuestionType.sequence => _sequence(d, rng),
    };
  }

  /// "What is 13 in binary?" — distractors are single-bit flips.
  static Question _decimalToBinary(Difficulty d, Random rng) {
    final value = rng.nextInt(d.maxValue + 1);
    final correct = BinaryUtils.toBinary(value, minBits: d.minBits);

    final wrongs = <String>{};
    var guard = 0;
    while (wrongs.length < 3 && guard++ < 200) {
      final candidate = rng.nextBool()
          ? value ^ (1 << rng.nextInt(d.minBits)) // flip one random bit
          : rng.nextInt(d.maxValue + 1);
      final text = BinaryUtils.toBinary(candidate, minBits: d.minBits);
      if (text != correct) wrongs.add(text);
    }

    return _assemble(
      type: QuestionType.decimalToBinary,
      decimalValue: value,
      binaryText: correct,
      power: 0,
      correctText: correct,
      wrongs: wrongs.toList(),
    );
  }

  /// "What is 00001101 in decimal?"
  static Question _binaryToDecimal(Difficulty d, Random rng) {
    final value = rng.nextInt(d.maxValue + 1);
    final binary = BinaryUtils.toBinary(value, minBits: d.minBits);

    final wrongs = <String>{};
    var guard = 0;
    while (wrongs.length < 3 && guard++ < 200) {
      final candidate = rng.nextInt(d.maxValue + 1);
      if (candidate != value) wrongs.add('$candidate');
    }

    return _assemble(
      type: QuestionType.binaryToDecimal,
      decimalValue: value,
      binaryText: binary,
      power: 0,
      correctText: '$value',
      wrongs: wrongs.toList(),
    );
  }

  /// "What is 2⁵?"
  static Question _powerOfTwo(Difficulty d, Random rng) {
    final power = 1 + rng.nextInt(d.maxPower);
    final correct = 1 << power;

    final wrongs = <int>{};
    var guard = 0;
    while (wrongs.length < 3 && guard++ < 200) {
      final candidate = rng.nextBool()
          ? 1 << rng.nextInt(d.maxPower + 1)
          : 1 + rng.nextInt(1 << d.maxPower);
      if (candidate != correct) wrongs.add(candidate);
    }

    return _assemble(
      type: QuestionType.powerOfTwo,
      decimalValue: correct,
      binaryText: '',
      power: power,
      correctText: '$correct',
      wrongs: wrongs.map((e) => '$e').toList(),
    );
  }

  /// "What is 0x2A in decimal?" (medium & hard only)
  static Question _hexToDecimal(Difficulty d, Random rng) {
    final value = rng.nextInt(d.maxValue + 1);

    final wrongs = <String>{};
    var guard = 0;
    while (wrongs.length < 3 && guard++ < 200) {
      final candidate = rng.nextInt(d.maxValue + 1);
      if (candidate != value) wrongs.add('$candidate');
    }

    return _assemble(
      type: QuestionType.hexToDecimal,
      decimalValue: value,
      binaryText: '',
      power: 0,
      correctText: '$value',
      wrongs: wrongs.toList(),
    );
  }

  /// "3, 6, 12, 24, ?" — the doubling idea made visible.
  static Question _sequence(Difficulty d, Random rng) {
    final starts = switch (d) {
      Difficulty.easy => const [1, 2, 4, 8],
      Difficulty.medium => const [1, 2, 3, 4, 6, 8],
      Difficulty.hard => const [1, 2, 3, 4, 5, 6, 7, 8, 10, 12],
    };
    final start = starts[rng.nextInt(starts.length)];
    final answer = start * 16; // after 4 shown terms

    final wrongs = <int>{};
    final candidates = [
      answer * 2,
      answer ~/ 2,
      answer + start * 4,
      answer - start * 4,
    ]..shuffle(rng);
    for (final c in candidates) {
      if (wrongs.length >= 3) break;
      if (c > 0 && c != answer) wrongs.add(c);
    }
    while (wrongs.length < 3) {
      final c = answer + (rng.nextInt(8) + 1) * start * 2;
      if (c != answer) wrongs.add(c);
    }

    return _assemble(
      type: QuestionType.sequence,
      decimalValue: start,
      binaryText: '',
      power: 0,
      correctText: '$answer',
      wrongs: wrongs.map((e) => '$e').toList(),
    );
  }

  /// Shuffles correct + wrong options and records the correct index.
  static Question _assemble({
    required QuestionType type,
    required int decimalValue,
    required String binaryText,
    required int power,
    required String correctText,
    required List<String> wrongs,
  }) {
    final options = [...wrongs.take(3), correctText]..shuffle();
    return Question(
      type: type,
      decimalValue: decimalValue,
      binaryText: binaryText,
      power: power,
      options: options,
      correctIndex: options.indexOf(correctText),
    );
  }
}
