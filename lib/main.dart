import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/app_material_localizations.dart';

import 'providers/converter_provider.dart';
import 'providers/language_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/quiz_provider.dart';
import 'providers/real_world_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/splash_screen.dart';
import 'utils/app_localizations.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted data (language, settings, progress) before first frame.
  final prefs = await SharedPreferences.getInstance();

  runApp(BinaryLabApp(prefs: prefs));
}

/// Root widget: global providers + MaterialApp.
class BinaryLabApp extends StatelessWidget {
  const BinaryLabApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => LanguageProvider(
            AppLanguage.fromCode(prefs.getString('language')),
            prefs,
          ),
        ),
        ChangeNotifierProvider(create: (_) => SettingsProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ProgressProvider(prefs)),
        ChangeNotifierProvider(create: (_) => ConverterProvider()),
        ChangeNotifierProvider(create: (_) => RealWorldProvider()),
        ChangeNotifierProvider(
          create: (context) =>
              QuizProvider(progress: context.read<ProgressProvider>()),
        ),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, lang, _) => MaterialApp(
          title: 'Binary Lab',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.dark(),
          locale: lang.locale,
          supportedLocales: const [Locale('en'), Locale('ar'), Locale('ku')],
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            AppMaterialLocalizationsDelegate(),
          ],
          builder: (context, child) => Directionality(
            textDirection: lang.isRtl ? TextDirection.rtl : TextDirection.ltr,
            child: child ?? const SizedBox.shrink(),
          ),
          // The app now boots like a machine. 🖥️
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
