import 'package:flutter/material.dart';
import 'package:binary_lab/utils/app_fonts.dart';
import 'package:provider/provider.dart';

import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_localizations.dart';
import '../utils/feedback.dart';

/// Settings sheet: language switcher + sound toggle.
Future<void> showLanguageSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (sheetContext) {
      return Consumer<LanguageProvider>(
        builder: (context, lang, _) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 26),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.cardBorder,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      const Icon(Icons.settings_outlined,
                          size: 20, color: AppColors.neonCyan),
                      const SizedBox(width: 8),
                      Text(
                        lang.t('settings'),
                        style: AppFonts.orbitron(
                            fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // -------- Language --------
                  for (final language in AppLanguage.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            FeedbackFx.tap();
                            lang.setLanguage(language);
                            Navigator.of(sheetContext).pop();
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(
                              color: language == lang.language
                                  ? AppColors.neonGreen.withValues(alpha: 0.08)
                                  : AppColors.card,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: language == lang.language
                                    ? AppColors.neonGreen
                                    : AppColors.cardBorder,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  language == lang.language
                                      ? Icons.radio_button_checked
                                      : Icons.radio_button_off,
                                  size: 20,
                                  color: language == lang.language
                                      ? AppColors.neonGreen
                                      : AppColors.textDim,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    language.nativeName,
                                    style: const TextStyle(
                                        fontSize: 16,
                                        color: AppColors.textPrimary),
                                  ),
                                ),
                                if (language == lang.language)
                                  const Icon(Icons.check,
                                      size: 18, color: AppColors.neonGreen),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  const Divider(color: AppColors.cardBorder, height: 24),
                  // -------- Sound toggle --------
                  Consumer<SettingsProvider>(
                    builder: (context, settings, _) => Row(
                      children: [
                        Icon(
                          settings.soundEnabled
                              ? Icons.volume_up_rounded
                              : Icons.volume_off_rounded,
                          color: AppColors.neonCyan,
                          size: 22,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            lang.t('sound'),
                            style: const TextStyle(
                                fontSize: 15, color: AppColors.textPrimary),
                          ),
                        ),
                        Switch(
                          value: settings.soundEnabled,
                          activeThumbColor: AppColors.neonGreen,
                          onChanged: (_) => settings.toggleSound(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
