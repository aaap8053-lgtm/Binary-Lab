import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Flutter's flutter_localizations package does not ship Kurdish ('ku')
/// Material strings. Without a fallback, switching the app to Badini removes
/// MaterialLocalizations from the tree entirely and every Material widget
/// (NavigationRail, TextField, sheets…) crashes with
/// "No MaterialLocalizations found".
///
/// This delegate plugs that hole:
///  - locales supported by flutter_localizations (en, ar, …) → handled there;
///  - everything else (ku) → served the built-in English Material strings.
///
/// All *visible* app text still comes from AppStrings in proper Badini;
/// this only covers Flutter-internal strings (tooltips, semantics, etc.).
class AppMaterialLocalizationsDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  const AppMaterialLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      // We only step in where the global delegate has a gap.
      !GlobalMaterialLocalizations.delegate.isSupported(locale);

  @override
  Future<MaterialLocalizations> load(Locale locale) async {
    // Prefer Arabic-script internal strings for Kurdish users instead?
    // Then return this line:
    //   return GlobalMaterialLocalizations.delegate.load(const Locale('ar'));
    return const DefaultMaterialLocalizations();
  }

  @override
  bool shouldReload(AppMaterialLocalizationsDelegate old) => false;
}
