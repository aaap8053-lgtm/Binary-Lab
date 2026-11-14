import 'package:binary_lab/widgets/animated_entrance.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../utils/app_layout.dart';
import '../widgets/real_world/ascii_encoder.dart';
import '../widgets/real_world/ip_visualizer.dart';
import '../widgets/real_world/memory_explorer.dart';
import '../widgets/real_world/rgb_mixer.dart';
import '../widgets/section_card.dart';

/// Screen 2 — binary in the real world.
class RealWorldScreen extends StatelessWidget {
  const RealWorldScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();
    final wide = AppLayout.isWide(context);

    final rgb = SectionCard(
      icon: Icons.palette_outlined,
      title: lang.t('rgbTitle'),
      subtitle: lang.t('rgbDesc'),
      child: const RgbMixer(),
    );
    final ip = SectionCard(
      icon: Icons.router_outlined,
      title: lang.t('ipTitle'),
      subtitle: lang.t('ipDesc'),
      child: const IpVisualizer(),
    );
    final memory = SectionCard(
      icon: Icons.memory_outlined,
      title: lang.t('memoryTitle'),
      subtitle: lang.t('memoryDesc'),
      child: const MemoryExplorer(),
    );
    final ascii = SectionCard(
      icon: Icons.text_fields,
      title: lang.t('asciiTitle'),
      subtitle: lang.t('asciiDesc'),
      child: const AsciiEncoder(),
    );

    const gap = SizedBox(height: 16);

    // Phones: one column. Tablets: two balanced columns.
    if (!wide) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          AnimatedEntrance(child: rgb),
          gap,
          AnimatedEntrance(delayMs: 80, child: ip),
          gap,
          AnimatedEntrance(delayMs: 160, child: memory),
          gap,
          AnimatedEntrance(delayMs: 240, child: ascii),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Column(children: [
              AnimatedEntrance(child: rgb),
              gap,
              AnimatedEntrance(delayMs: 160, child: memory)
            ])),
            const SizedBox(width: 16),
            Expanded(
                child: Column(children: [
              AnimatedEntrance(delayMs: 80, child: ip),
              gap,
              AnimatedEntrance(delayMs: 240, child: ascii)
            ])),
          ],
        ),
      ],
    );
  }
}
