/// Pure binary-math helpers. No Flutter state, fully unit-testable.
class BinaryUtils {
  BinaryUtils._();

  /// Values of the 8 bits, most-significant first.
  static const List<int> bitValues = [128, 64, 32, 16, 8, 4, 2, 1];

  /// 13 -> "00001101"
  static String toBinary8(int value) => toBinary(value, minBits: 8);

  /// Binary string padded to at least [minBits] characters.
  static String toBinary(int value, {int minBits = 8}) {
    final raw = value.toRadixString(2);
    return raw.length >= minBits ? raw : raw.padLeft(minBits, '0');
  }

  static int fromBinary(String bits) => int.parse(bits, radix: 2);

  static bool isBitOn(int value, int power) => ((value >> power) & 1) == 1;

  static int toggleBit(int value, int power) => value ^ (1 << power);

  /// 13 -> "8 + 4 + 1"
  static String sumExpression(int value) {
    final parts = [
      for (final v in bitValues)
        if ((value & v) != 0) '$v'
    ];
    return parts.isEmpty ? '0' : parts.join(' + ');
  }

  /// 7 -> "2⁷" using unicode superscripts.
  static String powerLabel(int power) {
    const sup = ['⁰', '¹', '²', '³', '⁴', '⁵', '⁶', '⁷', '⁸', '⁹'];
    final digits = power.toString().split('').map((d) => sup[int.parse(d)]);
    return '2${digits.join()}';
  }

  /// log2 for exact powers of two (64 -> 6, 128 -> 7 …).
  static int log2(int value) {
    var v = value;
    var p = 0;
    while (v > 1) {
      v >>= 1;
      p++;
    }
    return p;
  }

  static String hex2(int v) =>
      v.toRadixString(16).toUpperCase().padLeft(2, '0');

  static String hexColor(int r, int g, int b) =>
      '#${hex2(r)}${hex2(g)}${hex2(b)}';

  /// 137438953472 -> "137,438,953,472" (avoids pulling in intl).
  static String formatInt(int value) {
    final s = value.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      buffer.write(s[i]);
      final remaining = s.length - i - 1;
      if (remaining > 0 && remaining % 3 == 0) buffer.write(',');
    }
    return buffer.toString();
  }
}
