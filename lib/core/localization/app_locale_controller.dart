import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../l10n/generated/app_localizations.dart';

/// App-only language preference (does not change a person's financial data).
///
/// The supported language list is generated from ARB files: contributors do not
/// need to change Dart source code when adding another translation.
final appLocaleController = AppLocaleController();
final appLocaleProvider = ChangeNotifierProvider<AppLocaleController>(
  (ref) => appLocaleController,
);

class AppLocaleController extends ChangeNotifier {
  String? _languageCode;

  String? get languageCode => _languageCode;
  Locale? get locale {
    final selected = _languageCode;
    if (selected == null) return null;
    for (final supported in AppLocalizations.supportedLocales) {
      if (localeIdentifier(supported) == selected) return supported;
    }
    return null;
  }

  bool get followsSystem => _languageCode == null;

  Future<File> _file() async {
    final directory = await getApplicationSupportDirectory();
    return File('${directory.path}/xpenc_locale.txt');
  }

  Future<void> load() async {
    try {
      final file = await _file();
      if (!await file.exists()) return;
      final saved = (await file.readAsString()).trim();
      if (saved.isNotEmpty && _supported(saved)) {
        _languageCode = saved;
        notifyListeners();
      }
    } on FileSystemException {
      // Missing/unavailable app storage should not prevent launch.
    }
  }

  bool _supported(String code) => AppLocalizations.supportedLocales
      .any((locale) => localeIdentifier(locale) == code);

  /// Pass null to follow Android/iOS system language.
  Future<void> setLanguage(String? code) async {
    if (code != null && !_supported(code)) {
      throw ArgumentError.value(code, 'code', 'Unsupported app locale');
    }
    if (code == _languageCode) return;
    final file = await _file();
    if (code == null) {
      if (await file.exists()) await file.delete();
    } else {
      // Persist before changing the live locale, avoiding a UI choice that is
      // silently lost on restart when storage fails.
      await file.writeAsString(code, flush: true);
    }
    _languageCode = code;
    notifyListeners();
  }
}

/// Matches a platform locale to a catalog; never loads an unsupported locale.
Locale resolvedNotificationLocale() {
  final explicit = appLocaleController.locale;
  if (explicit != null) return explicit;
  final device = WidgetsBinding.instance.platformDispatcher.locale;
  for (final supported in AppLocalizations.supportedLocales) {
    if (supported.languageCode == device.languageCode) return supported;
  }
  return AppLocalizations.supportedLocales.first;
}

String localeIdentifier(Locale locale) =>
    locale.toLanguageTag().replaceAll('-', '_');

String nativeLocaleLabel(Locale locale) => switch (locale.languageCode) {
  'ar' => 'العربية',
  'en' => 'English',
  _ => locale.toLanguageTag(),
};
