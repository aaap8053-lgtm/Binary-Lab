import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/app_localizations.dart';

/// Holds the current UI language, persists it, and translates keys via [t].
class LanguageProvider extends ChangeNotifier {
  LanguageProvider(this._language, this._prefs);

  AppLanguage _language;
  final SharedPreferences _prefs;

  AppLanguage get language => _language;
  Locale get locale => _language.locale;

  /// Arabic and Kurdish (Badini) are written right-to-left.
  bool get isRtl =>
      _language == AppLanguage.arabic || _language == AppLanguage.kurdish;

  /// Translates [key]. Optional [args] replace `{placeholders}`:
  /// t('questionProgress', {'a': '3', 'b': '10'})
  String t(String key, [Map<String, String>? args]) {
    var text = AppStrings.get(key, _language.code);
    args?.forEach((k, v) => text = text.replaceAll('{$k}', v));
    return text;
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (language == _language) return;
    _language = language;
    notifyListeners();
    await _prefs.setString('language', language.code);
  }
}
