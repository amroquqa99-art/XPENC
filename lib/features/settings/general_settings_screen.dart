import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/platform/platform_features.dart';
import '../../core/localization/app_locale_controller.dart';
import '../../core/localization/language_picker.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/widgets/app_surfaces.dart';
import '../../data/providers.dart';
import 'more_screen_layout_sheet.dart';
import 'settings_common.dart';
import 'theme_picker_sheet.dart';

/// General — currency, theme, font and layout. The settings that shape how
/// XPENC looks and reads, independent of app mode or any one feature.
class GeneralSettingsScreen extends ConsumerWidget {
  const GeneralSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final locale = ref.watch(appLocaleProvider).locale;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final trailingStyle = settingsTrailingStyle(context);

    final themeChoice = ref.watch(themeChoiceProvider);
    final currency = ref.watch(currencyProvider);
    final showSymbol = ref.watch(showCurrencySymbolProvider);
    final moreScreenViewMode = ref.watch(moreScreenViewModeProvider);
    final showCalendarDayTotals = ref.watch(showCalendarDayTotalsProvider);

    return Scaffold(
      appBar: AppTopBar(title: Text(l10n.generalTitle)),
      body: ListView(
        // Explicit padding drops ListView's nav-bar inset; re-add it (#137).
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          32 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          AppCard(
            child: Column(
              children: [
                AppListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const AppIcon(Icons.payments_outlined),
                  title: Text(l10n.currencyTitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currency.symbol} ${currency.code}',
                        style: trailingStyle,
                      ),
                      const SizedBox(width: 4),
                      AppIcon(
                        Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                  onTap: () => context.push('/more/settings/currency'),
                ),
                Divider(height: 1, indent: 60, color: cs.outline),
                AppListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const AppIcon(Icons.language_rounded),
                  title: Text(l10n.languageTitle),
                  subtitle: Text(l10n.languageSubtitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        locale == null
                            ? l10n.followSystemLanguage
                            : nativeLocaleLabel(locale),
                        style: trailingStyle,
                      ),
                      const SizedBox(width: 4),
                      AppIcon(Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant),
                    ],
                  ),
                  onTap: () => showLanguagePicker(context),
                ),
                Divider(height: 1, indent: 60, color: cs.outline),
                AppSwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: const AppIcon(Icons.attach_money_rounded),
                  title: Text(l10n.showCurrencySymbolTitle),
                  subtitle: Text(
                    showSymbol
                        ? l10n.showCurrencySymbolOn(currency.symbol)
                        : l10n.showCurrencySymbolOff,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  value: showSymbol,
                  onChanged: (v) =>
                      ref.read(dbProvider).setShowCurrencySymbol(v),
                ),
                Divider(height: 1, indent: 60, color: cs.outline),
                AppListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: AppIcon(themeChoice.style.icon),
                  title: Text(l10n.themeTitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(themeChoice.style.label, style: trailingStyle),
                      const SizedBox(width: 4),
                      AppIcon(
                        Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                  onTap: () => ThemePickerSheet.show(context),
                ),
                Divider(height: 1, indent: 60, color: cs.outline),
                AppListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const AppIcon(Icons.text_fields_rounded),
                  title: Text(l10n.fontTitle),
                  subtitle: Text(
                    l10n.fontSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: AppIcon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                  ),
                  onTap: () => context.push('/more/settings/font'),
                ),
                Divider(height: 1, indent: 60, color: cs.outline),
                AppListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const AppIcon(Icons.dashboard_outlined),
                  title: Text(l10n.moreScreenLayoutTitle),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        MoreScreenLayoutSheet.label(moreScreenViewMode),
                        style: trailingStyle,
                      ),
                      const SizedBox(width: 4),
                      AppIcon(
                        Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                  onTap: () => MoreScreenLayoutSheet.show(context),
                ),
              ],
            ),
          ),

          settingsSectionLabel(context, l10n.dashboardTitle),
          AppCard(
            child: AppListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const AppIcon(Icons.dashboard_customize_outlined),
              title: Text(l10n.customizeDashboardTitle),
              subtitle: Text(
                l10n.customizeDashboardSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: const AppIcon(Icons.chevron_right_rounded),
              onTap: () => context.push('/more/settings/dashboard'),
            ),
          ),

          settingsSectionLabel(context, l10n.calendarTitle),
          AppCard(
            child: AppSwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const AppIcon(Icons.calendar_month_outlined),
              title: Text(l10n.showDayTotalsTitle),
              subtitle: Text(
                l10n.showDayTotalsSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              value: showCalendarDayTotals,
              onChanged: (v) =>
                  ref.read(dbProvider).setShowCalendarDayTotals(v),
            ),
          ),

          settingsSectionLabel(context, l10n.layoutTitle),
          AppCard(
            child: AppListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const AppIcon(Icons.dashboard_customize_outlined),
              title: Text(l10n.customizeBottomNavTitle),
              subtitle: Text(
                l10n.customizeBottomNavSubtitle,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              trailing: const AppIcon(Icons.chevron_right_rounded),
              onTap: () => context.push('/more/bottom-nav'),
            ),
          ),

          settingsSectionLabel(context, l10n.messageCaptureTitle),
          AppCard(
            child: Column(
              children: [
                AppListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: const AppIcon(Icons.sms_outlined),
                  title: Text(l10n.bankSmsCaptureTitle),
                  subtitle: Text(
                    l10n.bankSmsCaptureSubtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  trailing: const AppIcon(Icons.chevron_right_rounded),
                  onTap: () => context.push('/more/capture'),
                ),
                if (PlatformFeatures.ocr) ...[
                  Divider(height: 1, indent: 60, color: cs.outline),
                  AppListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: const AppIcon(Icons.rate_review_outlined),
                    title: Text(l10n.ocrCorrectionsTitle),
                    subtitle: Text(
                      l10n.ocrCorrectionsSubtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    trailing: const AppIcon(Icons.chevron_right_rounded),
                    onTap: () => context.push('/more/capture/ocr-feedback'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
