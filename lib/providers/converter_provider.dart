import 'dart:math';

import 'package:flutter/foundation.dart';

import '../utils/binary_utils.dart';

/// State of the 8-bit converter screen (kept alive across tab switches).
class ConverterProvider extends ChangeNotifier {
  /// Starts at 13 so students immediately see the example 00001101.
  int _value = 13;

  int get value => _value;
  String get binary8 => BinaryUtils.toBinary8(_value);
  String get sumExpression => BinaryUtils.sumExpression(_value);

  bool isBitOn(int power) => BinaryUtils.isBitOn(_value, power);

  void toggleBit(int power) {
    _value = BinaryUtils.toggleBit(_value, power);
    notifyListeners();
  }

  void setValue(int newValue) {
    final clamped = newValue.clamp(0, 255);
    if (clamped == _value) return;
    _value = clamped;
    notifyListeners();
  }

  void reset() => setValue(0);

  void random() => setValue(Random().nextInt(256));
}
