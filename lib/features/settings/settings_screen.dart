import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/branding/app_info.dart';
import '../../core/branding/brand_mark.dart';
import '../../core/platform/platform_features.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../core/widgets/app_surfaces.dart';

/// Settings' front door — a menu of modules, each its own page. Splitting it
/// this way (instead of one long scrolling list of every toggle) keeps each
/// page short enough to scan and keeps this menu itself from growing every
/// time a new setting is added.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppTopBar(title: Text(l10n.settingsTitle)),
      body: ListView(
        // Explicit padding drops ListView's nav-bar inset; re-add it (#137).
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          32 + MediaQuery.of(context).padding.bottom,
        ),
        children: [
          _ModuleTile(
            icon: Icons.tune_rounded,
            title: l10n.generalTitle,
            subtitle: l10n.generalSubtitle,
            onTap: () => context.push('/more/settings/general'),
          ),
          _ModuleTile(
            icon: Icons.savings_outlined,
            title: l10n.budgetSettingsTitle,
            subtitle: l10n.budgetSettingsSubtitle,
            onTap: () => context.push('/more/settings/mode-budgeting'),
          ),
          _ModuleTile(
            icon: Icons.people_outline,
            title: l10n.personsTitle,
            subtitle: l10n.personsSubtitle,
            onTap: () => context.push('/more/settings/persons'),
          ),
          _ModuleTile(
            icon: Icons.security_outlined,
            title: l10n.securityPrivacyTitle,
            subtitle: PlatformFeatures.screenshotBlocking
                ? l10n.securityPrivacySubtitle
                : l10n.securityPrivacySubtitleBasic,
            onTap: () => context.push('/more/settings/security'),
          ),
          if (PlatformFeatures.permissionsScreen)
            _ModuleTile(
              icon: Icons.verified_user_outlined,
              title: l10n.permissionsTitle,
              subtitle: l10n.permissionsSubtitle,
              onTap: () => context.push('/more/settings/permissions'),
            ),
          _ModuleTile(
            icon: Icons.notifications_outlined,
            title: l10n.notificationsTitle,
            subtitle: PlatformFeatures.quickAddNotification
                ? l10n.notificationsSubtitle
                : l10n.remindersTitle,
            onTap: () => context.push('/more/settings/notifications'),
          ),
          _ModuleTile(
            icon: Icons.flash_on_outlined,
            title: l10n.quickActionsTitle,
            subtitle: PlatformFeatures.homeWidgets
                ? l10n.quickActionsSubtitle
                : l10n.quickActionsSubtitleBasic,
            onTap: () => context.push('/more/settings/quick-actions'),
          ),
          _ModuleTile(
            icon: Icons.storage_outlined,
            title: l10n.dataTitle,
            subtitle: l10n.dataSubtitle,
            onTap: () => context.push('/more/settings/data'),
          ),
          AppCard(
            child: AppListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const BrandMark(size: 34),
              title: const Text('${AppInfo.name} · ${AppInfo.version}'),
              subtitle: Text(
                l10n.aboutSubtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: const AppIcon(Icons.chevron_right_rounded),
              onTap: () => context.push('/more/about'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return AppCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: AppListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: AppIcon(icon),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: AppIcon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        onTap: onTap,
      ),
    );
  }
}
