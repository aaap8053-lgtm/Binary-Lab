import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Central typography facade.
///
/// By default the app uses Google Fonts (Orbitron / Space Grotesk /
/// JetBrains Mono). To use fonts from YOUR computer:
///
///  1. Copy the .ttf/.otf files into  assets/fonts/
///  2. Declare them in pubspec.yaml (see the commented block there)
///  3. Put the family names in [customFamily] / [kurdishFamily] below
///  4. flutter pub get  →  full restart
///
/// [kurdishFamily] is especially useful: the Google Fonts used here have no
/// Arabic-script glyphs, so Badini/Arabic text falls back to it automatically.
class AppFonts {
  AppFonts._();

  /// '' = keep Google Fonts. Set to your pubspec family name to override
  /// every display/body/mono style in the app.
  static const String customFamily = 'MyFont';

  /// '' = none. Font used for Arabic-script / Kurdish glyphs that the
  /// primary font doesn't contain.
  static const String kurdishFamily = 'MyKurdishFont';

  static List<String>? get fallbackList =>
      kurdishFamily.isEmpty ? null : [kurdishFamily];

  // ---------------------------------------------------------------- public
  static TextStyle orbitron({
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    List<Shadow>? shadows,
    TextDecoration? decoration,
  }) =>
      _resolve(
        textStyle: textStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        shadows: shadows,
        decoration: decoration,
        google: () => GoogleFonts.orbitron(
          textStyle: textStyle,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          color: color,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          height: height,
          shadows: shadows,
          decoration: decoration,
        ),
      );

  static TextStyle spaceGrotesk({
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    List<Shadow>? shadows,
    TextDecoration? decoration,
  }) =>
      _resolve(
        textStyle: textStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        shadows: shadows,
        decoration: decoration,
        google: () => GoogleFonts.spaceGrotesk(
          textStyle: textStyle,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          color: color,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          height: height,
          shadows: shadows,
          decoration: decoration,
        ),
      );

  static TextStyle jetBrainsMono({
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    List<Shadow>? shadows,
    TextDecoration? decoration,
  }) =>
      _resolve(
        textStyle: textStyle,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        shadows: shadows,
        decoration: decoration,
        google: () => GoogleFonts.jetBrainsMono(
          textStyle: textStyle,
          fontSize: fontSize,
          fontWeight: fontWeight,
          fontStyle: fontStyle,
          color: color,
          letterSpacing: letterSpacing,
          wordSpacing: wordSpacing,
          height: height,
          shadows: shadows,
          decoration: decoration,
        ),
      );

  static TextTheme spaceGroteskTextTheme(TextTheme base) =>
      customFamily.isNotEmpty
          ? base.apply(fontFamily: customFamily)
          : GoogleFonts.spaceGroteskTextTheme(base);

  // --------------------------------------------------------------- private
  static TextStyle _resolve({
    TextStyle? textStyle,
    double? fontSize,
    FontWeight? fontWeight,
    FontStyle? fontStyle,
    Color? color,
    double? letterSpacing,
    double? wordSpacing,
    double? height,
    List<Shadow>? shadows,
    TextDecoration? decoration,
    required TextStyle Function() google,
  }) {
    if (customFamily.isNotEmpty) {
      // Your uploaded font, with automatic glyph fallback for Kurdish.
      return (textStyle ?? const TextStyle()).copyWith(
        fontFamily: customFamily,
        fontFamilyFallback: fallbackList,
        fontSize: fontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle,
        color: color,
        letterSpacing: letterSpacing,
        wordSpacing: wordSpacing,
        height: height,
        shadows: shadows,
        decoration: decoration,
      );
    }
    // Google Fonts + Kurdish glyph fallback.
    return google().copyWith(fontFamilyFallback: fallbackList);
  }
}
