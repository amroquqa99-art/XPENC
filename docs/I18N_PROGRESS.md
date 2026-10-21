# Localization work in progress (NOT READY FOR UPSTREAM PR)

## Completed on this branch
- Added Flutter gen-l10n configuration and ARB catalogs for `en` and `ar`.
- Added a persistent in-app language selector (system / Arabic / English) with RTL/LTR automatically handled by Flutter delegates. Newly added ARB locales appear automatically.
- Created locale scaffolding and validation tools; see `docs/TRANSLATING.md` and `docs/TRANSLATING_AR.md`.
- Localized the root/general/notification settings screens, core navigation labels, major local notification content and Android home-screen widget resources.
- Added basic l10n widget tests and a localization validation GitHub workflow.
- Preserved existing stored transaction identifiers and data (presentation-only localization).

## Outstanding: must finish before an upstream PR
- Audit and migrate **every** user-facing hardcoded string in remaining Flutter screens (the project has over 200 `lib/` Dart files).
- Cover every snackbar/dialog, validation message, empty state, screen-reader label, financial report, PDF/export heading and onboarding copy.
- Translate Android notification channel names, native widgets and platform resources comprehensively; verify iOS permission prompts and other native text.
- Verify formatting and direction for numbers, dates, amounts, mixed Latin IDs and links.
- Audit localization of background tasks and notifications after changing the app language.
- Run the full Android build, widget/integration tests and visual review of Arabic RTL and English LTR, including small screens and accessibility.
- Remove any validation workflow that exists only for the fork branch or generalize it before upstream submission.
- Run `python3 scripts/check_l10n.py` and review `python3 scripts/audit_unlocalized.py` results; no missed user-facing strings.
- Submit PR **only when all checks are green and coverage has been verified**.

## Important limitation
Having every ARB key translated is not proof that the full application is translated.
Each user-facing literal still needs to be routed through the generated
`AppLocalizations` API. Do not label this branch as a complete Arabic translation.
