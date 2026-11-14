import 'package:binary_lab/widgets/count_up.dart';
import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../models/achievement.dart';
import '../models/quiz_models.dart';
import '../providers/language_provider.dart';
import '../providers/progress_provider.dart';
import '../utils/app_colors.dart';

/// Screen 4 — level, points, badges and quiz history (all persisted).
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  String _formatDate(int ms) {
    final d = DateTime.fromMillisecondsSinceEpoch(ms);
    String two(int n) => n.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)} · ${two(d.hour)}:${two(d.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressProvider>();
    final lang = context.watch<LanguageProvider>();
    final info = progress.levelInfo;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        // ---------------- Level header ----------------
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.08),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              // Level badge
              Container(
                width: 82,
                height: 82,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.neonGreen.withValues(alpha: 0.1),
                  border: Border.all(color: AppColors.neonGreen, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonGreen.withValues(alpha: 0.4),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${info.level}',
                      style: AppFonts.orbitron(
                        fontSize: 28,
                        fontWeight: FontWeight.normal,
                        color: AppColors.neonGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: info.needed == 0 ? 0 : info.into / info.needed,
                      ),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (context, v, _) => ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: v,
                          minHeight: 12,
                          borderRadius: BorderRadius.circular(999),
                          backgroundColor: AppColors.cardBorder,
                          valueColor:
                              const AlwaysStoppedAnimation(AppColors.neonGreen),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      lang.t('xpToNext', {'x': '${info.needed - info.into}'}),
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.textDim,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // ---------------- Stat tiles ----------------
        Row(
          children: [
            Expanded(
              child: _StatTile(
                icon: Icons.stars,
                label: lang.t('totalPoints'),
                value: progress.totalPoints,
                color: AppColors.neonGreen,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.star,
                label: lang.t('starsLabel'),
                value: progress.totalStars,
                color: AppColors.neonAmber,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _StatTile(
                icon: Icons.local_fire_department,
                label: lang.t('bestStreakLabel'),
                value: progress.bestStreak,
                color: AppColors.neonCyan,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // ---------------- Achievements ----------------
        _SectionTitle(text: lang.t('achievementsTitle')),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 3.1,
          children: [
            for (final badge in Achievements.all)
              _AchievementCard(
                  badge: badge, unlocked: progress.isUnlocked(badge.id)),
          ],
        ),
        const SizedBox(height: 24),
        // ---------------- History ----------------
        _SectionTitle(text: lang.t('historyTitle')),
        const SizedBox(height: 12),
        if (progress.history.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Text(
              lang.t('noHistory'),
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textDim, fontSize: 13.5),
            ),
          )
        else
          for (final result in progress.history) ...[
            _HistoryTile(result: result, date: _formatDate(result.timestamp)),
            const SizedBox(height: 10),
          ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4.5,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.neonGreen,
            borderRadius: BorderRadius.circular(99),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonGreen.withValues(alpha: 0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: AppFonts.orbitron(
            fontSize: 15,
            fontWeight: FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final int value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: CountUp(
              value: value,
              style: AppFonts.orbitron(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textDim,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({required this.badge, required this.unlocked});

  final Achievement badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final color = unlocked ? AppColors.neonAmber : AppColors.textDim;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: unlocked ? 1 : 0.5,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: unlocked
              ? AppColors.neonAmber.withValues(alpha: 0.08)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: unlocked
                ? AppColors.neonAmber.withValues(alpha: 0.5)
                : AppColors.cardBorder,
          ),
          boxShadow: unlocked
              ? [
                  BoxShadow(
                    color: AppColors.neonAmber.withValues(alpha: 0.1),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(badge.icon, color: color, size: 26),
                if (!unlocked)
                  const Positioned(
                    bottom: -4,
                    right: -6,
                    child: Icon(Icons.lock, size: 12, color: AppColors.textDim),
                  ),
              ],
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    lang.t(badge.nameKey),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.normal,
                      color:
                          unlocked ? AppColors.textPrimary : AppColors.textDim,
                    ),
                  ),
                  const SizedBox(height: 1.5),
                  Text(
                    lang.t(badge.descKey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 13,
                        color: Color.fromARGB(255, 159, 178, 187),
                        height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.result, required this.date});

  final QuizResult result;
  final String date;

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final color = result.difficulty.color;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.04),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Icon(result.difficulty.icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${result.score} ${lang.t('pointsEarned')} · ${result.correct}/${result.total}',
                  style: AppFonts.jetBrainsMono(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: AppFonts.jetBrainsMono(
                      fontSize: 11, color: AppColors.textDim),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < 3; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 1),
                  child: Icon(
                    i < result.stars ? Icons.star : Icons.star_border,
                    size: 16,
                    color: i < result.stars
                        ? AppColors.neonAmber
                        : AppColors.cardBorder,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
