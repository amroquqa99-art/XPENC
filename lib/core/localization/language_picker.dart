import 'dart:io';

import 'package:flutter/material.dart';

import '../../l10n/generated/app_localizations.dart';
import 'app_locale_controller.dart';

/// Reads available languages from generated ARB catalogs, not from a hardcoded
/// menu. A new app_xx.arb appears here automatically after flutter gen-l10n.
Future<void> showLanguagePicker(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final selected = appLocaleController.languageCode ?? 'system';
  final choice = await showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Text(
              l10n.chooseLanguageTitle,
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
          ),
          RadioGroup<String>(
            groupValue: selected,
            onChanged: (value) {
              if (value != null) Navigator.pop(sheetContext, value);
            },
            child: Column(
              children: [
                RadioListTile<String>(
                  title: Text(l10n.followSystemLanguage),
                  value: 'system',
                ),
                for (final locale in AppLocalizations.supportedLocales)
                  RadioListTile<String>(
                    title: Text(nativeLocaleLabel(locale)),
                    value: localeIdentifier(locale),
                  ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
  if (choice == null) return;
  if (!context.mounted) return;
  try {
    await appLocaleController.setLanguage(
      choice == 'system' ? null : choice,
    );
  } on FileSystemException catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context).languageSaveFailed)),
    );
  }
}
