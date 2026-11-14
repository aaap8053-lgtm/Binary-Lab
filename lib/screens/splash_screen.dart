import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/background/binary_rain.dart';
import '../widgets/neon_logo.dart';
import 'home_shell.dart';

/// A BIOS-style boot sequence, then a glowing logo reveal, then fade into app.
/// Tap anywhere to skip.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  // Terminals are authentic in English — kept on purpose, even in RTL.
  static const List<String> _bootLines = [
    '> BINARY LAB BIOS v2.0',
    '> checking bits 0–7 ............... OK',
    '> loading powers of 2 ............. OK',
    '> mounting /dev/knowledge ......... OK',
    '> injecting neon .................. OK',
    '> system ready.',
  ];

  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2100),
  )..repeat(reverse: true);

  int _visibleLines = 0;
  bool _showIdentity = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();

    // Staggered boot lines.
    for (var i = 0; i < _bootLines.length; i++) {
      Future.delayed(Duration(milliseconds: 340 * (i + 1)), () {
        if (mounted) setState(() => _visibleLines = i + 1);
      });
    }

    final afterLines = 340 * (_bootLines.length + 1) + 400;
    Future.delayed(Duration(milliseconds: afterLines), () {
      if (mounted) setState(() => _showIdentity = true);
    });
    Future.delayed(Duration(milliseconds: afterLines + 2400), _enter);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _enter() {
    if (_leaving || !mounted) return;
    _leaving = true;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const HomeShell(),
        transitionDuration: const Duration(milliseconds: 650),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: _enter, // tap to skip
        child: Stack(
          children: [
            const Positioned.fill(child: BinaryRain(opacity: 0.13)),
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 1.0,
                      colors: [
                        AppColors.neonGreen.withValues(alpha: 0.1),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Boot log (always LTR).
                    Directionality(
                      textDirection: TextDirection.ltr,
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.card.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var i = 0; i < _visibleLines; i++)
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: 1),
                                duration: const Duration(milliseconds: 220),
                                builder: (context, v, child) => Opacity(
                                  opacity: v,
                                  child: Transform.translate(
                                    offset: Offset(0, 6 * (1 - v)),
                                    child: child,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Text(
                                    _bootLines[i],
                                    style: AppFonts.jetBrainsMono(
                                      fontSize: 12.5,
                                      color: i == 0
                                          ? AppColors.neonCyan
                                          : AppColors.neonGreen
                                              .withValues(alpha: 0.9),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Identity reveal.
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 500),
                      opacity: _showIdentity ? 1 : 0,
                      child: AnimatedScale(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeOutBack,
                        scale: _showIdentity ? 1 : 0.8,
                        child: Center(
                          child: Column(
                            children: [
                              AnimatedBuilder(
                                animation: _pulse,
                                builder: (context, _) => Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neonGreen.withValues(
                                            alpha: 0.25 * _pulse.value),
                                        blurRadius: 32,
                                        spreadRadius: 8,
                                      ),
                                    ],
                                  ),
                                  child: NeonLogo(
                                    size: 96,
                                    glow: 0.4 + _pulse.value * 0.6,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    AppColors.neonGreen,
                                    AppColors.neonCyan
                                  ],
                                ).createShader(bounds),
                                child: Text(
                                  lang.t('appName'),
                                  style: AppFonts.orbitron(
                                    fontSize: 32,
                                    fontWeight: FontWeight.normal,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                lang.t('tagline'),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13.5,
                                  color: AppColors.textDim,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              const SizedBox(height: 16),
                              // --------------------------------------------------
                              // Custom Author Badge / Developer Credit Animation
                              // --------------------------------------------------
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0.0, end: 1.0),
                                duration: const Duration(milliseconds: 800),
                                curve: Curves.easeOutCubic,
                                builder: (context, value, child) {
                                  return Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Opacity(
                                      opacity: value,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.card.withValues(alpha: 0.7),
                                    borderRadius: BorderRadius.circular(999),
                                    border: Border.all(
                                      color: AppColors.neonCyan
                                          .withValues(alpha: 0.4),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.neonCyan
                                            .withValues(alpha: 0.1),
                                        blurRadius: 12,
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.code,
                                        size: 14,
                                        color: AppColors.neonCyan,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'دروستکرنا پروژەی ژ لایێ احمد غریب ڤە',
                                        style: AppFonts.jetBrainsMono(
                                          fontSize: 14,
                                          fontWeight: FontWeight.normal,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              // --------------------------------------------------
                              const SizedBox(height: 24),
                              const SizedBox(
                                width: 180,
                                child: LinearProgressIndicator(
                                  minHeight: 5,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(99)),
                                  backgroundColor: AppColors.cardBorder,
                                  valueColor: AlwaysStoppedAnimation(
                                      AppColors.neonGreen),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                lang.t('tapToSkip'),
                                style: AppFonts.jetBrainsMono(
                                  fontSize: 11,
                                  color:
                                      AppColors.textDim.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
