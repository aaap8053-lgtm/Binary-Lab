import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../../providers/language_provider.dart';
import '../../providers/real_world_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/binary_utils.dart';
import '../binary_text.dart';

/// Editable IPv4 address with every octet decoded into 8 bits.
class IpVisualizer extends StatefulWidget {
  const IpVisualizer({super.key});

  @override
  State<IpVisualizer> createState() => _IpVisualizerState();
}

class _IpVisualizerState extends State<IpVisualizer> {
  static const _presets = [
    '192.168.1.1',
    '10.0.0.1',
    '172.16.254.3',
    '8.8.8.8'
  ];

  late final List<TextEditingController> _controllers = List.generate(
    4,
    (i) => TextEditingController(text: '${RealWorldProvider.defaultIp[i]}'),
  );

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onOctetChanged(int index, String text) {
    final v = int.tryParse(text);
    if (v != null && v >= 0 && v <= 255) {
      context.read<RealWorldProvider>().setOctet(index, v);
    }
  }

  void _applyPreset(String preset) {
    final octets = preset.split('.').map(int.parse).toList();
    for (var i = 0; i < 4; i++) {
      _controllers[i].text = '${octets[i]}';
    }
    context.read<RealWorldProvider>().setIp(octets);
  }

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<LanguageProvider>();

    return Consumer<RealWorldProvider>(
      builder: (context, p, _) {
        return Directionality(
          // IP addresses are conventionally written left → right.
          textDirection: TextDirection.ltr,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4 octet fields separated by dots
              Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '.',
                          style: AppFonts.orbitron(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.neonCyan,
                          ),
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _controllers[i],
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(3),
                        ],
                        onChanged: (t) => _onOctetChanged(i, t),
                        onSubmitted: (t) {
                          final clamped = (int.tryParse(t) ?? 0).clamp(0, 255);
                          _controllers[i].text = '$clamped';
                          p.setOctet(i, clamped);
                        },
                        textAlign: TextAlign.center,
                        style: AppFonts.jetBrainsMono(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.neonGreen,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor:
                              AppColors.background.withValues(alpha: 0.5),
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 14),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide:
                                const BorderSide(color: AppColors.cardBorder),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(
                                color: AppColors.neonGreen, width: 1.8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              // Each octet -> its 8 bits
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 36,
                              child: Text(
                                '${p.ip[i]}',
                                textAlign: TextAlign.right,
                                style: AppFonts.jetBrainsMono(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Icon(Icons.arrow_right_alt,
                                size: 18, color: AppColors.neonCyan),
                            const SizedBox(width: 12),
                            Expanded(
                              child: BinaryText(BinaryUtils.toBinary8(p.ip[i]),
                                  fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Full 32-bit view
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.neonCyan.withValues(alpha: 0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.neonCyan.withValues(alpha: 0.04),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.neonCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        '32-bit',
                        style: AppFonts.jetBrainsMono(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.neonCyan,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: BinaryText(p.ipBinary, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Text(
                lang.t('ipTry'),
                style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textDim,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final preset in _presets)
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => _applyPreset(preset),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(color: AppColors.cardBorder),
                        ),
                        child: Text(
                          preset,
                          style: AppFonts.jetBrainsMono(
                            fontSize: 12.5,
                            color: AppColors.neonCyan,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
