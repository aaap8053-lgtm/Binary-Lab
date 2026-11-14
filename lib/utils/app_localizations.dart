import 'package:flutter/material.dart';

/// The three supported languages.
enum AppLanguage {
  english('en', 'English'),
  arabic('ar', 'العربية'),
  kurdish('ku', 'کوردی (بادینی)');

  const AppLanguage(this.code, this.nativeName);

  final String code;
  final String nativeName;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) =>
      values.firstWhere((e) => e.code == code, orElse: () => english);
}

/// All UI strings. Missing keys fall back to English, then to the key itself.
class AppStrings {
  AppStrings._();

  static const Map<String, Map<String, String>> _values = {
    // ---------------- App shell & splash ----------------
    'appName': {
      'en': 'Binary Lab',
      'ar': 'مختبر الباينري',
      'ku': 'تاقیگەها باینەری'
    },
    'tagline': {
      'en': 'See why computers speak in 0s and 1s',
      'ar': 'شاهد لماذا تتحدث الحواسيب بالصفر والواحد',
      'ku': 'بینەریا کمپیوتەرێ بکە چاوا ب 0 و 1 کاردکەت',
    },
    'tapToSkip': {
      'en': 'tap to skip',
      'ar': 'اضغط للتخطي',
      'ku': 'کلیک بکە بۆ دەربازبوونێ'
    },
    'settings': {'en': 'Settings', 'ar': 'الإعدادات', 'ku': 'ڕێکخستن'},
    'sound': {
      'en': 'Sound effects',
      'ar': 'المؤثرات الصوتية',
      'ku': 'دەنگێن کاریگەر'
    },
    'language': {'en': 'Language', 'ar': 'اللغة', 'ku': 'زمان'},
    'tabConverter': {'en': 'Converter', 'ar': 'المحوّل', 'ku': 'گوهورین'},
    'tabRealWorld': {
      'en': 'Real World',
      'ar': 'العالم الحقيقي',
      'ku': 'دنیایا راستەقینە'
    },
    'tabQuiz': {
      'en': 'Quiz & Games',
      'ar': 'اختبار وألعاب',
      'ku': 'پسیار و یاری'
    },
    'tabProgress': {'en': 'Progress', 'ar': 'التقدّم', 'ku': 'پێشکەڤتن'},

    // ---------------- Converter ----------------
    'converterHint': {
      'en': 'Tap a card to flip its bit between 0 and 1',
      'ar': 'اضغط على البطاقة لتبديل البت بين 0 و 1',
      'ku': 'کلیکێ لسەر کارتەکێ بکە بوو دیتنا گوهورینێ',
    },
    'decimal': {'en': 'Decimal', 'ar': 'عشري', 'ku': 'دەهى'},
    'binary': {'en': 'Binary', 'ar': 'ثنائي', 'ku': 'باینەری'},
    'sum': {'en': 'Sum', 'ar': 'المجموع', 'ku': 'کۆم'},
    'reset': {'en': 'Reset', 'ar': 'تصفير', 'ku': 'نوی کرن'},
    'random': {'en': 'Random', 'ar': 'عشوائي', 'ku': 'هەرەمەکی'},
    'enterNumber': {
      'en': 'Enter a number (0–255)',
      'ar': 'أدخل رقمًا (0–255)',
      'ku': 'ژمارەکێ بنڤیسە ( ژ 0 بۆ 255 )',
    },
    'slider': {
      'en': 'Drag to set the number',
      'ar': 'اسحب لتعيين الرقم',
      'ku': 'دیارکرنا ژمارەیان',
    },

    // ---------------- Real world ----------------
    'rgbTitle': {
      'en': 'RGB Color Mixer',
      'ar': 'مزيج الألوان RGB',
      'ku': 'تێکەلکرنا ڕەنگان RGB'
    },
    'rgbDesc': {
      'en': 'Every color is 3 numbers from 0 to 255 — one byte each.',
      'ar': 'كل لون مكوّن من 3 أرقام (0–255) — كل رقم بايت واحد.',
      'ku':
          'هەر ڕەنگەک ژ سێ ژماران پێک دهێت (0–255) و هەر ژمارەیەک یەک بايتەکە.',
    },
    'red': {'en': 'Red', 'ar': 'أحمر', 'ku': 'سۆر'},
    'green': {'en': 'Green', 'ar': 'أخضر', 'ku': 'کەسک'},
    'blue': {'en': 'Blue', 'ar': 'أزرق', 'ku': 'شین'},
    'ipTitle': {
      'en': 'IP Address Visualizer',
      'ar': 'عارض عنوان IP',
      'ku': 'نیشاندەرێ ناڤونیشانێ IP'
    },
    'ipDesc': {
      'en': "Your device's address is 4 numbers, each one byte (8 bits).",
      'ar': 'عنوان جهازك مكوّن من 4 أرقام، كل رقم بايت واحد (8 بت).',
      'ku':
          'ناڤونیشانێن ئامێرێ تە ژ 4 ژماران پێک دهێت، هەر ئێک بايتەکە کو د بیت (8 بت).',
    },
    'ipTry': {
      'en': 'Try an address:',
      'ar': 'جرّب عنوانًا:',
      'ku': 'ناڤونیشانەکێ هەلبژێرە'
    },
    'memoryTitle': {
      'en': 'Memory Explorer',
      'ar': 'مستكشف الذاكرة',
      'ku': 'ڤەکۆلەرێ بیرگەهێ'
    },
    'memoryDesc': {
      'en': 'Memory doubles: 2, 4, 8, 16… that is why 1 KB = 1024 bytes.',
      'ar': 'الذاكرة تتضاعف: 2، 4، 8، 16… لهذا 1 كيلوبايت = 1024 بايت.',
      'ku':
          'بیرگەهە هەر دەم توانی دوو دبیت: 2، 4، 8، 16… ژبەر کو 1 کیلۆبايت = 1024 بايت.',
    },
    'why1024': {
      'en':
          '1 KB = 1024 bytes because 2¹⁰ = 1024. Memory chips double in size, so phone capacities follow powers of two: 64, 128, 256, 512 GB.',
      'ar':
          '1 كيلوبايت = 1024 بايت لأنّ 2 أُس 10 تساوي 1024. رقاقات الذاكرة تتضاعف، لذلك سعات الهواتف قوى للعدد 2: 64، 128، 256، 512 جيجابايت.',
      'ku':
          '1 کیلۆبايت = 1024 بايت، ژبەر کو 2 توانی 10 دبیتە 1024. چیپێن بیرگەهێ هەر دەم توانی 2 دبن، ژبەر کو قەبارەیێن موبایلان دچنە لدویڤ هێزێن 64، 128، 256، 512 گیگابايت.',
    },
    'phoneStorage': {
      'en': 'Phone storage',
      'ar': 'سعة هاتفك',
      'ku': 'بیرگەها موبایلێ'
    },
    'bytes': {'en': 'bytes', 'ar': 'بايت', 'ku': 'بايت'},
    'bits': {'en': 'bits', 'ar': 'بت', 'ku': 'بت'},
    'asciiTitle': {
      'en': 'ASCII — Your Name in Binary',
      'ar': 'ASCII — اسمك بالثنائي',
      'ku': 'ASCII — ناڤێ تە ب باینەری'
    },
    'asciiDesc': {
      'en': 'Computers number every letter: A = 65, B = 66 …',
      'ar': 'الحاسوب يرقّم كل حرف: A = 65، B = 66 …',
      'ku': 'کمپیوتەر هەر تیپەکێ ب ژمارەیەکێ دناسیت: A = 65، B = 66 …',
    },
    'asciiHint': {
      'en': 'Type your name here…',
      'ar': 'اكتب اسمك هنا…',
      'ku': 'ناڤێ خۆ ل ڤیرە بنڤیسە…'
    },
    'unicodeNote': {
      'en': 'Needs more than 8 bits (Unicode)',
      'ar': 'يحتاج أكثر من 8 بت (Unicode)',
      'ku': 'پێدڤی ب زێدەتر ژ 8 بتان هەیە (Unicode)',
    },

    // ---------------- Quiz menu & daily ----------------
    'quizMenuTitle': {
      'en': 'Choose your challenge',
      'ar': 'اختر تحديك',
      'ku': 'تاقیکرنا خۆ هەلبژێرە'
    },
    'dailyTitle': {
      'en': 'Daily Challenge',
      'ar': 'تحدي اليوم',
      'ku': 'تاقیکرنا ڕۆژێ'
    },
    'dailyDesc': {
      'en': '5 questions · one try · +25 bonus points',
      'ar': '5 أسئلة · محاولة واحدة · +25 نقطة إضافية',
      'ku': '5 پرسیار · ئێک هەول · +25 خالێن زێدە',
    },
    'dailyDone': {
      'en': 'Completed · best: {x}',
      'ar': 'اكتمل · الأفضل: {x}',
      'ku': 'هاتە تەمامکرن · باشترین: {x}'
    },
    'easyName': {'en': 'Easy', 'ar': 'سهل', 'ku': 'بساناهی'},
    'mediumName': {'en': 'Medium', 'ar': 'متوسط', 'ku': 'ناڤنجی'},
    'hardName': {'en': 'Hard', 'ar': 'صعب', 'ku': 'ب زەحمەت'},
    'easyDesc': {
      'en': 'Numbers 0–31 · 20s per question',
      'ar': 'أرقام 0–31 · 20 ثانية لكل سؤال',
      'ku': 'ژمارە 0–31 · 20 چرکە بۆ هەر پرسیارەکێ'
    },
    'mediumDesc': {
      'en': 'Numbers 0–127 · 15s per question',
      'ar': 'أرقام 0–127 · 15 ثانية لكل سؤال',
      'ku': 'ژمارە 0–127 · 15 چرکە بۆ هەر پرسیارەکێ'
    },
    'hardDesc': {
      'en': 'Numbers 0–255 · 10s per question',
      'ar': 'أرقام 0–255 · 10 ثوانٍ لكل سؤال',
      'ku': 'ژمارە 0–255 · 10 چرکە بۆ هەر پرسیارەکێ'
    },
    'questionsCount': {
      'en': '{n} questions',
      'ar': '{n} أسئلة',
      'ku': '{n} پرسیار'
    },
    'fingerGameName': {
      'en': 'Finger Binary',
      'ar': 'الباينري بالأصابع',
      'ku': 'باینەری ب تبلان'
    },
    'fingerGameDesc': {
      'en': '5 fingers = 5 bits. Can you count to 31?',
      'ar': '5 أصابع = 5 بتات. هل تستطيع العد إلى 31؟',
      'ku': '5 تلێن دەستی = 5 بت. ئەرێ توو د شێی هەتا 31 هەژمێری ؟',
    },

    // ---------------- Quiz play ----------------
    'questionProgress': {
      'en': 'Question {a} of {b}',
      'ar': 'السؤال {a} من {b}',
      'ku': 'پرسیارا {a} ژ {b}'
    },
    'timeUp': {
      'en': "Time's up!",
      'ar': 'انتهى الوقت!',
      'ku': 'دەم ب دوماهیک هات!'
    },
    'qDecToBin': {
      'en': 'What is {x} in binary?',
      'ar': 'ما هو {x} بالنظام الثنائي؟',
      'ku': 'ژمارا {x} ب باینەری چيە؟'
    },
    'qBinToDec': {
      'en': 'What is {x} in decimal?',
      'ar': 'كم يساوي {x} بالنظام العشري؟',
      'ku': '{x} ب دهشى چەندە؟'
    },
    'qPower': {'en': 'What is {x}?', 'ar': 'كم تساوي {x}؟', 'ku': '{x} چەندە؟'},
    'qHexToDec': {
      'en': 'What is {x} in decimal?',
      'ar': 'كم يساوي {x} بالنظام العشري؟',
      'ku': '{x} ب دهشى چەندە؟'
    },
    'qSequence': {
      'en': 'What number comes next?',
      'ar': 'ما الرقم التالي؟',
      'ku': 'ژمارا داهاتڤ چيە؟'
    },

    // ---------------- Results ----------------
    'quizResults': {'en': 'Results', 'ar': 'النتائج', 'ku': 'ئەنجام'},
    'correctAnswers': {
      'en': '{a} / {b} correct',
      'ar': '{a} / {b} إجابة صحيحة',
      'ku': '{a} ژ {b} ڕاست'
    },
    'pointsEarned': {'en': 'points', 'ar': 'نقطة', 'ku': 'خال'},
    'bestStreakLabel': {
      'en': 'Best streak',
      'ar': 'أفضل تتابع',
      'ku': 'باشترین زنجیرە'
    },
    'accuracy': {'en': 'Accuracy', 'ar': 'الدقة', 'ku': 'ڕێژەی ڕاستی'},
    'playAgain': {
      'en': 'Play again',
      'ar': 'العب مجددًا',
      'ku': 'دووبارە یاری بکە'
    },
    'backToMenu': {'en': 'Menu', 'ar': 'القائمة', 'ku': 'لیستا یاریا'},
    'newBadge': {
      'en': 'New badge unlocked!',
      'ar': 'وسام جديد!',
      'ku': 'نیشانەکا نوی ڤەبوو!'
    },

    // ---------------- Finger game ----------------
    'fingerTarget': {
      'en': 'Make the number {x}',
      'ar': 'كوّن الرقم {x}',
      'ku': 'ژمارا {x} دروست بکە'
    },
    'fingerTapHint': {
      'en': 'Tap a finger to raise or lower it',
      'ar': 'اضغط على إصبع لرفعه أو إنزاله',
      'ku': 'دەست ل تلییەکێ بکە بۆ بلندکرن یان دانین',
    },
    'fingerCheck': {'en': 'Check', 'ar': 'تحقق', 'ku': 'کۆنترۆل بکە'},
    'fingerNew': {'en': 'New number', 'ar': 'رقم جديد', 'ku': 'ژمارەکا نوی'},
    'fingerCorrect': {'en': 'Correct! 🎉', 'ar': 'صحيح! 🎉', 'ku': 'ڕاستە! 🎉'},
    'fingerWrong': {
      'en': 'Not yet — check your bits',
      'ar': 'ليس بعد — راجع البتات',
      'ku': 'هێشتا نە — بیتێن خۆ کۆنترۆل بکە'
    },
    'fingerYourSum': {'en': 'Your number', 'ar': 'رقمك', 'ku': 'ژمارا تە'},
    'fingerBack': {
      'en': 'Exit game',
      'ar': 'الخروج من اللعبة',
      'ku': 'دەرکەتن ژ یاریێ'
    },

    // ---------------- Progress ----------------
    'totalPoints': {'en': 'Points', 'ar': 'النقاط', 'ku': 'خال'},
    'starsLabel': {'en': 'Stars', 'ar': 'النجوم', 'ku': 'ستێر'},
    'achievementsTitle': {
      'en': 'Achievements',
      'ar': 'الإنجازات',
      'ku': 'دەستکەفتی'
    },
    'historyTitle': {
      'en': 'Quiz history',
      'ar': 'سجل الاختبارات',
      'ku': 'مێژویا تاقیکرنان'
    },
    'noHistory': {
      'en': 'Play a quiz to see your history here.',
      'ar': 'العب اختبارًا لترى سجلك هنا.',
      'ku': 'تاقیکرنەکێ بکە بۆ دیتنا مێژویا خۆ.',
    },
    'xpToNext': {
      'en': '{x} points to next level',
      'ar': '{x} نقطة للمستوى التالي',
      'ku': '{x} خال بۆ ئاستێ داهاتڤ'
    },

    // ---------------- Achievements ----------------
    'achFirstQuiz': {
      'en': 'First Steps',
      'ar': 'الخطوات الأولى',
      'ku': 'گەنگێن پێشی'
    },
    'achFirstQuizD': {
      'en': 'Complete your first quiz',
      'ar': 'أكمل أول اختبار لك',
      'ku': 'ئێکەم تاقیکرنا خۆ تەمام بکە'
    },
    'achPerfect': {'en': 'Flawless', 'ar': 'بلا خطأ', 'ku': 'بێ کێماسی'},
    'achPerfectD': {
      'en': 'Every answer correct in one quiz',
      'ar': 'كل الإجابات صحيحة في اختبار واحد',
      'ku': 'هەمی بەرسڤێن تاقیکرنێ دڤێت ڕاست بن'
    },
    'achStreak5': {'en': 'On Fire', 'ar': 'مشتعل', 'ku': 'ئاگرین'},
    'achStreak5D': {
      'en': '5 correct answers in a row',
      'ar': '5 إجابات صحيحة متتالية',
      'ku': '5 بەرسڤێن ڕاست ب دووڤ هەڤ'
    },
    'achStreak10': {'en': 'Unstoppable', 'ar': 'لا يُوقف', 'ku': 'نەهێلانبار'},
    'achStreak10D': {
      'en': '10 correct answers in a row',
      'ar': '10 إجابات صحيحة متتالية',
      'ku': '10 بەرسڤێن ڕاست ب دووڤ هەڤ'
    },
    'achHard': {'en': 'Brave Hacker', 'ar': 'هاكر شجاع', 'ku': 'هاکەرێ بوێر'},
    'achHardD': {
      'en': 'Finish a Hard quiz',
      'ar': 'أنهِ اختبارًا صعبًا',
      'ku': 'تاقیکرنا سەخت تەمام بکە'
    },
    'achStars3': {
      'en': 'Star Collector',
      'ar': 'جامع النجوم',
      'ku': 'کۆمکەرێ ستێران'
    },
    'achStars3D': {
      'en': 'Earn 3 stars in one quiz',
      'ar': 'احصل على 3 نجوم في اختبار واحد',
      'ku': '3 ستێران د تاقیکرنەکێ دا'
    },
    'achDaily': {'en': 'Early Bird', 'ar': 'بطل اليوم', 'ku': 'پالەوانێ ڕۆژێ'},
    'achDailyD': {
      'en': 'Complete a Daily Challenge',
      'ar': 'أكمل تحدي اليوم',
      'ku': 'تاقیکرنا ڕۆژێ تەمام بکە'
    },
    'achDaily5': {'en': 'Committed', 'ar': 'مواظب', 'ku': 'بەردەوام'},
    'achDaily5D': {
      'en': 'Complete 5 Daily Challenges',
      'ar': 'أكمل 5 تحديات يومية',
      'ku': '5 تاقیکرنێن ڕۆژێ تەمام بکە'
    },
    'achTenQuizzes': {'en': 'Scholar', 'ar': 'عالِم', 'ku': 'زانا'},
    'achTenQuizzesD': {
      'en': 'Complete 10 quizzes',
      'ar': 'أكمل 10 اختبارات',
      'ku': '10 تاقیکرنان تەمام بکە'
    },
    'achPoints500': {
      'en': 'Rising Star',
      'ar': 'نجم صاعد',
      'ku': 'ستێرکا هەلدەکێ'
    },
    'achPoints500D': {
      'en': 'Earn 500 total points',
      'ar': 'اجمع 500 نقطة إجمالًا',
      'ku': 'بگەهە 500 خالان ب گشتی'
    },
    'achPoints1000': {
      'en': 'Binary Master',
      'ar': 'سيد الباينري',
      'ku': 'ماستەرێ باینەری'
    },
    'achPoints1000D': {
      'en': 'Earn 1000 total points',
      'ar': 'اجمع 1000 نقطة إجمالًا',
      'ku': 'بگەهە 1000 خالان ب گشتی'
    },
    'achFinger5': {
      'en': 'Handy Calculator',
      'ar': 'حاسبة يدوية',
      'ku': 'حاسبەتا دەستی'
    },
    'achFinger5D': {
      'en': 'Play Finger Binary 5 times',
      'ar': 'العب الباينري بالأصابع 5 مرات',
      'ku': 'یاریا تلییان 5 جاران بکە'
    },
  };

  static String get(String key, String languageCode) {
    final entry = _values[key];
    if (entry == null) return key;
    return entry[languageCode] ?? entry['en'] ?? key;
  }
}
