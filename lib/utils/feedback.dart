
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';

import 'sound_synth.dart';

/// Central feedback: haptics + synthesized sounds.
/// Respects the sound toggle in Settings; never throws.
class FeedbackFx {
  FeedbackFx._();

  /// Mirrors the user's setting (see SettingsProvider).
  static bool soundEnabled = true;

  // Small pool so sounds can overlap (tap while a chime rings).
  static final List<AudioPlayer> _players = [
    AudioPlayer(),
    AudioPlayer(),
    AudioPlayer(),
  ];
  static int _next = 0;

  static Future<void> _play(Uint8List wav) async {
    if (!soundEnabled) return;
    try {
      _next = (_next + 1) % _players.length;
      final player = _players[_next];
      await player.stop();
      await player.play(BytesSource(wav, mimeType: 'audio/wav'));
    } catch (_) {
      // Audio must never crash the app — fall back to a system click.
      SystemSound.play(SystemSoundType.click);
    }
  }

  static void tap() {
    HapticFeedback.selectionClick();
    _play(GameSounds.tap);
  }

  static void toggle({required bool on}) {
    HapticFeedback.selectionClick();
    _play(on ? GameSounds.toggleOn : GameSounds.toggleOff);
  }

  static void success() {
    HapticFeedback.mediumImpact();
    _play(GameSounds.correct);
  }

  static void error() {
    HapticFeedback.heavyImpact();
    _play(GameSounds.wrong);
  }

  static void win() {
    HapticFeedback.mediumImpact();
    _play(GameSounds.win);
  }

  static void star() => _play(GameSounds.star);

  static void blip() => _play(GameSounds.blip);
}
