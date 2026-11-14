import 'package:binary_lab/widgets/animated_entrance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/converter_provider.dart';
import '../providers/language_provider.dart';
import '../utils/app_colors.dart';
import '../utils/feedback.dart';
import '../widgets/binary_text.dart';
import '../widgets/bit_card.dart';

/// Screen 1 — the interactive 8-bit converter.
class ConverterScreen extends StatefulWidget {
  const ConverterScreen({super.key});

  @override
  State<ConverterScreen> createState() => _ConverterScreenState();
}

class _ConverterScreenState extends State<ConverterScreen> {
  final TextEditingController _controller = TextEditingController(text: '0');
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus && mounted) {
        final value = context.read<ConverterProvider>().value;
        final parsed = int.tryParse(_controller.text);
        if (parsed == null || parsed < 0 || parsed > 255) {
          _controller.text = value.toString();
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged(String text) {
    final parsed = int.tryParse(text);
    if (parsed != null) {
      context.read<ConverterProvider>().setValue(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final conv = context.watch<ConverterProvider>();
    final lang = context.watch<LanguageProvider>();

    // Keep the text field in sync when the value changes from cards/slider.
    final parsed = int.tryParse(_controller.text);
    final isClearingWhileFocused =
        _focusNode.hasFocus && _controller.text.isEmpty;
    if (!isClearingWhileFocused && parsed != conv.value) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.text = conv.value.toString();
      });
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
      children: [
        _ReadoutCard(value: conv.value, binary: conv.binary8, lang: lang),
        const SizedBox(height: 14),
        _SumCard(expression: conv.sumExpression, value: conv.value, lang: lang),
        const SizedBox(height: 22),
        Text(
          lang.t('converterHint'),
          textAlign: TextAlign.center,
          style: const TextStyle(
              color: AppColors.textDim,
              fontSize: 13.5,
              fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 14),
        _bitGrid(conv),
        const SizedBox(height: 24),
        _sliderCard(conv, lang),
        const SizedBox(height: 14),
        _inputRow(conv, lang),
      ],
    );
  }

  /// 4 columns on phones, one row of 8 on tablets. Always LTR so the
  /// card order matches the written binary string.
  Widget _bitGrid(ConverterProvider conv) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cols = constraints.maxWidth >= 620 ? 8 : 4;
          return GridView.count(
            crossAxisCount: cols,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: cols == 8 ? 0.78 : 0.62,
            children: [
              for (var power = 7; power >= 0; power--)
                AnimatedEntrance(
                  delayMs: (7 - power) * 45, // cascade 128 → 1
                  child: BitCard(
                    power: power,
                    isOn: conv.isBitOn(power),
                    onTap: () {
                      FeedbackFx.toggle(on: !conv.isBitOn(power));
                      conv.toggleBit(power);
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sliderCard(ConverterProvider conv, LanguageProvider lang) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonCyan.withValues(alpha: 0.04),
            blurRadius: 14,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.tune, size: 18, color: AppColors.neonCyan),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  lang.t('slider'),
                  style: const TextStyle(
                      fontSize: 13.5,
                      color: AppColors.textDim,
                      fontWeight: FontWeight.w500),
                ),
              ),
              Text(
                '${conv.value} / 255',
                style: AppFonts.jetBrainsMono(
                    fontSize: 12.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Slider(
            value: conv.value.toDouble(),
            min: 0,
            max: 255,
            divisions: 255,
            label: '${conv.value}',
            onChanged: (v) => conv.setValue(v.round()),
          ),
        ],
      ),
    );
  }

  Widget _inputRow(ConverterProvider conv, LanguageProvider lang) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onTextChanged,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(3),
            ],
            textAlign: TextAlign.center,
            style: AppFonts.jetBrainsMono(
                fontSize: 18,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600),
            decoration: InputDecoration(
              hintText: lang.t('enterNumber'),
              hintStyle:
                  const TextStyle(color: AppColors.textDim, fontSize: 13),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide:
                    const BorderSide(color: AppColors.neonGreen, width: 1.8),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        _iconAction(Icons.refresh, lang.t('reset'), () {
          FeedbackFx.tap();
          conv.reset();
        }),
        const SizedBox(width: 10),
        _iconAction(Icons.shuffle, lang.t('random'), () {
          FeedbackFx.tap();
          conv.random();
        }),
      ],
    );
  }

  Widget _iconAction(IconData icon, String tooltip, VoidCallback onTap) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.cardBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.neonCyan.withValues(alpha: 0.05),
                blurRadius: 10,
              ),
            ],
          ),
          child: Icon(icon, size: 22, color: AppColors.neonCyan),
        ),
      ),
    );
  }
}

Widget _labelChip(String text) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
    decoration: BoxDecoration(
      color: AppColors.neonGreen.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(999),
      border: Border.all(color: AppColors.neonGreen.withValues(alpha: 0.3)),
    ),
    child: Text(
      text.toUpperCase(),
      style: AppFonts.jetBrainsMono(
        fontSize: 12,
        letterSpacing: 1.2,
        color: AppColors.neonGreen,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _ReadoutCard extends StatelessWidget {
  const _ReadoutCard(
      {required this.value, required this.binary, required this.lang});

  final int value;
  final String binary;
  final LanguageProvider lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.08),
            blurRadius: 32,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          _labelChip(lang.t('decimal')),
          const SizedBox(height: 8),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (child, animation) => ScaleTransition(
                  scale: animation,
                  child: FadeTransition(opacity: animation, child: child),
                ),
                child: Text(
                  '$value',
                  key: ValueKey<int>(value),
                  style: AppFonts.orbitron(
                    fontSize: 74,
                    fontWeight: FontWeight.w700,
                    color: AppColors.neonGreen,
                    shadows: [
                      Shadow(
                        color: AppColors.neonGreen.withValues(alpha: 0.5),
                        blurRadius: 26,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.cardBorder, height: 1, thickness: 1.2),
          const SizedBox(height: 16),
          Row(
            children: [
              _labelChip(lang.t('binary')),
              const SizedBox(width: 14),
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerEnd,
                  child: BinaryText(binary, fontSize: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SumCard extends StatelessWidget {
  const _SumCard(
      {required this.expression, required this.value, required this.lang});

  final String expression;
  final int value;
  final LanguageProvider lang;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.neonGreen.withValues(alpha: 0.03),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          _labelChip(lang.t('sum')),
          const SizedBox(width: 14),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Directionality(
                textDirection: TextDirection.ltr,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: expression,
                        style: const TextStyle(
                            color: AppColors.textDim, fontSize: 16),
                      ),
                      TextSpan(
                        text: '  =  $value',
                        style: const TextStyle(
                          color: AppColors.neonGreen,
                          fontSize: 18.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  style: AppFonts.jetBrainsMono(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
