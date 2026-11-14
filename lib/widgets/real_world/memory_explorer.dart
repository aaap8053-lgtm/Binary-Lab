import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/real_world_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/binary_utils.dart';

/// Explains why 1 KB = 1024 bytes and why phones ship in 64/128/256/512 GB.
class MemoryExplorer extends StatelessWidget {
  const MemoryExplorer({super.key});

  static const _storageOptions = [64, 128, 256, 512];
  static const _ladder = [1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024];

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Consumer<RealWorldProvider>(
      builder: (context, p, _) {
        final gb = p.storageGb;
        final bytes = gb * 1073741824; // gb × 2³⁰

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              lang.t('why1024'),
              style: const TextStyle(
                  fontSize: 13.5, height: 1.6, color: AppColors.textDim),
            ),
            const SizedBox(height: 16),
            // The doubling ladder 1 → 2 → 4 → … → 1024
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Row(
                    children: [
                      for (var i = 0; i < _ladder.length; i++) ...[
                        if (i > 0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '×2',
                              style: AppFonts.jetBrainsMono(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color:
                                    AppColors.neonCyan.withValues(alpha: 0.7),
                              ),
                            ),
                          ),
                        _ladderChip(
                          '${_ladder[i]}',
                          highlight: _ladder[i] == 1024,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              lang.t('phoneStorage'),
              style: AppFonts.orbitron(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final option in _storageOptions)
                  _StorageChip(
                    gb: option,
                    selected: option == gb,
                    onTap: () => p.setStorageGb(option),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: Container(
                key: ValueKey<int>(gb),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.4)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.05),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Directionality(
                  textDirection: TextDirection.ltr,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$gb GB  =  ${BinaryUtils.powerLabel(BinaryUtils.log2(gb))} GB',
                        style: AppFonts.orbitron(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonCyan,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '= ${BinaryUtils.formatInt(bytes)} ${lang.t('bytes')}',
                        style: AppFonts.jetBrainsMono(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '= ${BinaryUtils.formatInt(bytes * 8)} ${lang.t('bits')}',
                        style: AppFonts.jetBrainsMono(
                          fontSize: 13,
                          color: AppColors.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _ladderChip(String text, {bool highlight = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: highlight
            ? AppColors.neonCyan.withValues(alpha: 0.15)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: highlight ? AppColors.neonCyan : AppColors.cardBorder,
          width: highlight ? 1.4 : 1,
        ),
      ),
      child: Text(
        text,
        style: AppFonts.jetBrainsMono(
          fontSize: 12.5,
          fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
          color: highlight ? AppColors.neonCyan : AppColors.textDim,
        ),
      ),
    );
  }
}

/// Selectable "64 GB" style chip.
class _StorageChip extends StatelessWidget {
  const _StorageChip(
      {required this.gb, required this.selected, required this.onTap});

  final int gb;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.neonGreen.withValues(alpha: 0.15)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.neonGreen : AppColors.cardBorder,
            width: selected ? 1.6 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: AppColors.neonGreen.withValues(alpha: 0.15),
                    blurRadius: 10,
                  )
                ]
              : null,
        ),
        child: Text(
          '$gb GB',
          style: AppFonts.jetBrainsMono(
            fontSize: 13.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? AppColors.neonGreen : AppColors.textDim,
          ),
        ),
      ),
    );
  }
}
