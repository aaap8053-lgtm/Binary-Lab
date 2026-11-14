import 'package:binary_lab/utils/feedback.dart';
import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_layout.dart';
import '../widgets/background/binary_rain.dart';
import '../widgets/language_sheet.dart';
import '../widgets/neon_logo.dart';
import 'converter_screen.dart';
import 'progress_screen.dart';
import 'quiz_screen.dart';
import 'real_world_screen.dart';

/// App scaffold: ambient binary rain behind everything, custom neon header,
/// bottom bar on phones, NavigationRail on tablets/desktop.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  int _index = 0;
  late final AnimationController _logoPulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _logoPulse.dispose();
    super.dispose();
  }

  static const List<Widget> _screens = [
    ConverterScreen(),
    RealWorldScreen(),
    QuizScreen(),
    ProgressScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final wide = AppLayout.isWide(context);

    final destinations = [
      (Icons.calculate_outlined, Icons.calculate, lang.t('tabConverter')),
      (Icons.public_outlined, Icons.public, lang.t('tabRealWorld')),
      (Icons.sports_esports_outlined, Icons.sports_esports, lang.t('tabQuiz')),
      (Icons.insights_outlined, Icons.insights, lang.t('tabProgress')),
    ];

    // Content is width-capped and centered so it looks sharp on tablets.
    final Widget content = Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: wide ? 1000 : 600),
        child: IndexedStack(index: _index, children: _screens),
      ),
    );

    final Widget header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 16, 8),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _logoPulse,
            builder: (context, _) => Transform.scale(
              scale: 1 + 0.06 * _logoPulse.value,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen
                          .withValues(alpha: 0.3 * _logoPulse.value),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: NeonLogo(size: 32, glow: 0.6 + 0.4 * _logoPulse.value),
              ),
            ),
          ),
          const SizedBox(width: 12),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.neonGreen, AppColors.neonCyan],
            ).createShader(bounds),
            child: Text(
              lang.t('appName'),
              style: AppFonts.orbitron(
                fontSize: 20,
                fontWeight: FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ),
          const Spacer(),
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: IconButton(
              tooltip: lang.t('settings'),
              icon: const Icon(Icons.settings_outlined,
                  color: AppColors.neonCyan, size: 22),
              onPressed: () => showLanguageSheet(context),
            ),
          ),
        ],
      ),
    );

    // Animated developer credit footer widget
    final Widget developerFooter = TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1000),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 15),
        decoration: BoxDecoration(
          color: AppColors.card.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.neonCyan.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonCyan.withValues(alpha: 0.06),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.code_rounded, size: 14, color: AppColors.neonCyan),
            const SizedBox(width: 8),
            Text(
              'دروستکرنا پروژەی ژ لایێ احمد غریب ڤە یێ هاتی دروستکرن',
              style: AppFonts.jetBrainsMono(
                fontSize: 15,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );

    return Scaffold(
      body: Stack(
        children: [
          // 1) Ambient binary rain.
          const Positioned.fill(child: BinaryRain(opacity: 0.05)),
          // 2) Soft neon glow from the top.
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topCenter,
                    radius: 0.85,
                    colors: [
                      AppColors.neonGreen.withValues(alpha: 0.08),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // 3) Actual UI.
          Positioned.fill(
            child: SafeArea(
              child: Column(
                children: [
                  header,
                  Container(
                    height: 1.5,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          AppColors.neonGreen.withValues(alpha: 0.6),
                          AppColors.neonCyan.withValues(alpha: 0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: wide
                        ? Row(
                            children: [
                              NavigationRail(
                                selectedIndex: _index,
                                onDestinationSelected: (i) =>
                                    setState(() => _index = i),
                                minWidth: 100,
                                backgroundColor:
                                    AppColors.surface.withValues(alpha: 0.92),
                                indicatorColor:
                                    AppColors.neonGreen.withValues(alpha: 0.18),
                                labelType: NavigationRailLabelType.all,
                                selectedLabelTextStyle: const TextStyle(
                                  color: AppColors.neonGreen,
                                  fontSize: 12,
                                  fontFamily: "MyFont",
                                  fontWeight: FontWeight.normal,
                                ),
                                unselectedLabelTextStyle: const TextStyle(
                                    color: AppColors.textDim,
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal,
                                    fontFamily: "MyFont"),
                                selectedIconTheme: const IconThemeData(
                                    color: AppColors.neonGreen, size: 26),
                                unselectedIconTheme: const IconThemeData(
                                    color: AppColors.textDim, size: 22),
                                destinations: [
                                  for (final d in destinations)
                                    NavigationRailDestination(
                                      icon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Icon(d.$1),
                                      ),
                                      selectedIcon: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        child: Icon(d.$2),
                                      ),
                                      label: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 4),
                                        child: Text(
                                          d.$3,
                                          textAlign: TextAlign.center,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const VerticalDivider(
                                width: 1,
                                thickness: 1,
                                color: AppColors.cardBorder,
                              ),
                              Expanded(
                                child: Column(
                                  children: [
                                    Expanded(child: content),
                                    developerFooter,
                                  ],
                                ),
                              ),
                            ],
                          )
                        : Column(
                            children: [
                              Expanded(child: content),
                              developerFooter,
                            ],
                          ),
                  ),
                  if (!wide)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface.withValues(alpha: 0.95),
                        border: const Border(
                          top:
                              BorderSide(color: AppColors.cardBorder, width: 1),
                        ),
                      ),
                      child: NavigationBar(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        selectedIndex: _index,
                        onDestinationSelected: (i) {
                          FeedbackFx.tap();
                          setState(() => _index = i);
                        },
                        destinations: [
                          for (final d in destinations)
                            NavigationDestination(
                              icon: Icon(d.$1),
                              selectedIcon: Icon(d.$2),
                              label: d.$3,
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
