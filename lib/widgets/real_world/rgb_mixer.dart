import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/real_world_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/binary_utils.dart';
import '../binary_text.dart';

/// RGB color mixer: 3 sliders, live glowing preview, binary per channel.
class RgbMixer extends StatelessWidget {
  const RgbMixer({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Consumer<RealWorldProvider>(
      builder: (context, p, _) {
        final color = Color.fromARGB(255, p.r, p.g, p.b);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Live preview + hex readout card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Row(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2)),
                      boxShadow: [
                        BoxShadow(
                          color: color.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          BinaryUtils.hexColor(p.r, p.g, p.b),
                          style: AppFonts.jetBrainsMono(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(99),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Text(
                              'R ${p.r}  ·  G ${p.g}  ·  B ${p.b}',
                              style: AppFonts.jetBrainsMono(
                                fontSize: 11.5,
                                color: AppColors.textDim,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            _ChannelSlider(
              name: lang.t('red'),
              label: 'R',
              value: p.r,
              color: AppColors.neonRed,
              onValueChanged: p.setRed,
            ),
            const SizedBox(height: 6),
            _ChannelSlider(
              name: lang.t('green'),
              label: 'G',
              value: p.g,
              color: AppColors.neonGreen,
              onValueChanged: p.setGreen,
            ),
            const SizedBox(height: 6),
            _ChannelSlider(
              name: lang.t('blue'),
              label: 'B',
              value: p.b,
              color: AppColors.neonBlue,
              onValueChanged: p.setBlue,
            ),
          ],
        );
      },
    );
  }
}

/// One labeled, colored channel slider with its 8-bit binary below.
class _ChannelSlider extends StatelessWidget {
  const _ChannelSlider({
    required this.name,
    required this.label,
    required this.value,
    required this.color,
    required this.onValueChanged,
  });

  final String name;
  final String label;
  final int value;
  final Color color;
  final ValueChanged<int> onValueChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: color.withValues(alpha: 0.6)),
                ),
                alignment: Alignment.center,
                child: Text(
                  label,
                  style: AppFonts.orbitron(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    thumbShape:
                        const RoundSliderThumbShape(enabledThumbRadius: 6),
                  ),
                  child: Slider(
                    activeColor: color,
                    inactiveColor: color.withValues(alpha: 0.15),
                    thumbColor: color,
                    value: value.toDouble(),
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: '$value',
                    onChanged: (v) => onValueChanged(v.round()),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                alignment: Alignment.centerRight,
                child: Text(
                  '$value',
                  style: AppFonts.jetBrainsMono(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          // This channel as one byte.
          Row(
            children: [
              Expanded(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: BinaryText(BinaryUtils.toBinary8(value), fontSize: 13),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
