import 'dart:math' as math;
import 'dart:typed_data';

/// Tiny runtime WAV synthesizer → real game sounds with ZERO asset files.
enum Wave { sine, square, triangle }

class Note {
  const Note(
    this.freq,
    this.startSec,
    this.durSec, {
    this.vol = 0.25,
    this.sweepTo,
    this.wave = Wave.sine,
  });

  final double freq;
  final double startSec;
  final double durSec;
  final double vol;
  final double? sweepTo; // frequency glide target
  final Wave wave;
}

/// Mixes [notes] into 16-bit mono PCM and wraps it in a WAV container.
Uint8List synthWav(List<Note> notes, {int sampleRate = 44100}) {
  double total = 0;
  for (final n in notes) {
    total = math.max(total, n.startSec + n.durSec);
  }
  final count = (total * sampleRate).ceil() + 1;
  final samples = Float64List(count);

  for (final n in notes) {
    final start = (n.startSec * sampleRate).floor();
    final len = (n.durSec * sampleRate).floor();
    for (var i = 0; i < len && start + i < count; i++) {
      final t = i / sampleRate;
      final progress = i / len;
      final f = n.sweepTo == null
          ? n.freq
          : n.freq + (n.sweepTo! - n.freq) * progress;
      final phase = 2 * math.pi * f * t;

      final double v = switch (n.wave) {
        Wave.sine => math.sin(phase),
        Wave.square => math.sin(phase) >= 0 ? 0.6 : -0.6,
        Wave.triangle => 2 / math.pi * math.asin(math.sin(phase)),
      };

      // Fast attack, smooth decay envelope.
      final double env = math.min(1.0, i / (sampleRate * 0.008)) *
          math.pow(1 - progress, 1.8).toDouble();
      samples[start + i] += v * n.vol * env;
    }
  }

  for (var i = 0; i < count; i++) {
    samples[i] = samples[i].clamp(-0.95, 0.95); // soft clip
  }
  return _encodeWav(samples, sampleRate);
}

Uint8List _encodeWav(Float64List samples, int sampleRate) {
  final dataBytes = samples.length * 2;
  final bytes = ByteData(44 + dataBytes);

  void putStr(int offset, String s) {
    for (var i = 0; i < s.length; i++) {
      bytes.setUint8(offset + i, s.codeUnitAt(i));
    }
  }

  putStr(0, 'RIFF');
  bytes.setUint32(4, 36 + dataBytes, Endian.little);
  putStr(8, 'WAVE');
  putStr(12, 'fmt ');
  bytes.setUint32(16, 16, Endian.little);
  bytes.setUint16(20, 1, Endian.little); // PCM
  bytes.setUint16(22, 1, Endian.little); // mono
  bytes.setUint32(24, sampleRate, Endian.little);
  bytes.setUint32(28, sampleRate * 2, Endian.little);
  bytes.setUint16(32, 2, Endian.little);
  bytes.setUint16(34, 16, Endian.little);
  putStr(36, 'data');
  bytes.setUint32(40, dataBytes, Endian.little);

  for (var i = 0; i < samples.length; i++) {
    bytes.setInt16(44 + i * 2, (samples[i] * 32767).round(), Endian.little);
  }
  return bytes.buffer.asUint8List();
}

/// The app's sound palette, generated once at startup.
class GameSounds {
  GameSounds._();

  static final Uint8List tap = synthWav(const [Note(880, 0, 0.05, vol: 0.15)]);
  static final Uint8List toggleOn =
      synthWav(const [Note(520, 0, 0.09, vol: 0.22, sweepTo: 1040)]);
  static final Uint8List toggleOff =
      synthWav(const [Note(980, 0, 0.09, vol: 0.20, sweepTo: 420)]);
  static final Uint8List correct = synthWav(const [
    Note(784, 0, 0.09, vol: 0.22),
    Note(1174.7, 0.09, 0.14, vol: 0.22),
  ]);
  static final Uint8List wrong = synthWav(const [
    Note(196, 0, 0.20, vol: 0.25, wave: Wave.square),
    Note(147, 0.06, 0.18, vol: 0.20, wave: Wave.square),
  ]);
  static final Uint8List win = synthWav(const [
    Note(523.3, 0, 0.12),
    Note(659.3, 0.11, 0.12),
    Note(784, 0.22, 0.12),
    Note(1046.5, 0.33, 0.22, vol: 0.30),
  ]);
  static final Uint8List star = synthWav(const [
    Note(1568, 0, 0.07, vol: 0.18),
    Note(2093, 0.06, 0.10, vol: 0.15),
  ]);
  static final Uint8List blip =
      synthWav(const [Note(1320, 0, 0.03, vol: 0.10)]);
}
