import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/feedback.dart';

/// App settings (currently: sound on/off), persisted locally.
class SettingsProvider extends ChangeNotifier {
  SettingsProvider(this._prefs) {
    soundEnabled = _prefs.getBool(_kSound) ?? true;
    FeedbackFx.soundEnabled = soundEnabled;
  }

  final SharedPreferences _prefs;
  static const _kSound = 'bl_sound';

  bool soundEnabled = true;

  Future<void> toggleSound() async {
    soundEnabled = !soundEnabled;
    FeedbackFx.soundEnabled = soundEnabled;
    notifyListeners();
    await _prefs.setBool(_kSound, soundEnabled);
  }
}
