# Translating XPENC

XPENC uses Flutter's official **gen-l10n** / ARB localization pipeline.

## Add a language

1. Choose a valid language code (e.g. `fr`, `es`, `pt_BR`).
2. Run `python3 scripts/new_locale.py fr` to create `lib/l10n/app_fr.arb`.
3. Translate **values**, not IDs. Respect the meaning in the financial UI; do
   not translate money symbols, placeholders, brand names or user-entered data.
4. Preserve `{placeholders}` exactly; do not translate their names. Where an
   ICU plural or select is used, preserve ICU structure.
5. Run `python3 scripts/check_l10n.py` to check missing keys, locale metadata,
   placeholders and forbidden obvious leftovers.
6. Run `flutter pub get`, `flutter gen-l10n`, `flutter analyze` and
   `flutter test`. Then inspect the UI at small screen sizes and larger fonts.
7. Check notifications and Android widgets: the separate Android text resources
   under `android/app/src/main/res/values-<language>/strings.xml` must be
   translated when the feature uses platform strings.

**No Dart code changes are needed just to register a language.** The language
selector reads `AppLocalizations.supportedLocales` generated from the ARB files.

## Design and quality requirements

- English ARB is the source of truth for message IDs, context and placeholders.
- Use Arabic written for finance, not word-by-word translation.
- Correct RTL directionality is managed by Flutter localization delegates. Test
  mixed LTR inputs such as card IDs, numbers, currency codes and URLs.
- Use Unicode-safe typography; avoid forced left/right placement for UI elements.
- Keep widget semantics, labels, validation, accessibility and errors localized.
- Resolve plural, gender, dates and numbers with locale-aware ICU formatting.
- Don't localize stored user content, transaction descriptors, export column
  identifiers or audit data.
- Android's notification channel names may remain in the device's original
  language after creation; changing them may require user action or versioning.
- Translation completeness and runtime coverage are separate concerns: new
  strings must be **used by the Dart UI**, not merely present in ARB.
- Do not submit a PR until full code integration and Flutter checks succeed.

## Review checklist

- [ ] All target-language ARB messages translated in context
- [ ] Notifications, dialogs, errors, accessibility and exports reviewed
- [ ] Android home widgets have locale resource equivalents
- [ ] Layout looks right in both RTL and LTR
- [ ] Currency and numeric data retains meaning
- [ ] Generator, static checks, tests and Android build pass
