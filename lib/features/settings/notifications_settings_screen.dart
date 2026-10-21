import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/platform/platform_features.dart';
import '../../core/widgets/app_surfaces.dart';
import '../../data/database.dart';
import '../../data/providers.dart';
import '../../l10n/generated/app_localizations.dart';

/// Notifications — the master switch, the daily expense reminder, and quick
/// add straight from a notification's reply field.
class NotificationsSettingsScreen extends ConsumerWidget {
  const NotificationsSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final trailingStyle = theme.textTheme.bodyMedium?.copyWith(
      color: cs.onSurfaceVariant,
    );

    final settingsAsync = ref.watch(settingsProvider);
    // Never crash while settings are still loading — fall back to a safe default.
    final notificationsEnabled =
        settingsAsync.valueOrNull?.notificationsEnabled ?? false;
    final expenseReminder = ref.watch(expenseReminderProvider);
    final notificationQuickAddEnabled = ref.watch(
      notificationQuickAddEnabledProvider,
    );

    return Scaffold(
      appBar: AppTopBar(title: Text(l10n.notificationsTitle)),
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
            child: AppSwitchListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              secondary: const AppIcon(Icons.notifications_outlined),
              title: Text(l10n.notificationsTitle),
              subtitle: Text(
                l10n.notificationSettingsDescription,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              value: notificationsEnabled,
              onChanged: (v) => _toggleNotifications(ref, v),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                AppSwitchListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  secondary: const AppIcon(Icons.edit_note_rounded),
                  title: Text(l10n.dailyReminderSettingsTitle),
                  subtitle: Text(
                    expenseReminder.enabled
                        ? l10n.dailyReminderEnabledDescription(
                            _timeLabel(context, expenseReminder.hour, expenseReminder.minute))
                        : l10n.dailyReminderDisabledDescription,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  value: expenseReminder.enabled,
                  onChanged: (v) => _setExpenseReminder(
                    ref,
                    enabled: v,
                    hour: expenseReminder.hour,
                    minute: expenseReminder.minute,
                  ),
                ),
                if (expenseReminder.enabled) ...[
                  Divider(height: 1, indent: 60, color: cs.outline),
                  AppListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    leading: const AppIcon(Icons.schedule_outlined),
                    title: Text(l10n.timeTitle),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _timeLabel(
                            context,
                            expenseReminder.hour,
                            expenseReminder.minute,
                          ),
                          style: trailingStyle,
                        ),
                        const SizedBox(width: 4),
                        AppIcon(
                          Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant,
                        ),
                      ],
                    ),
                    onTap: () =>
                        _pickExpenseReminderTime(context, ref, expenseReminder),
                  ),
                ],
              ],
            ),
          ),
          if (PlatformFeatures.quickAddNotification) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                children: [
                  AppSwitchListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    secondary: const AppIcon(Icons.flash_on_outlined),
                    title: Text(l10n.quickAddFromNotificationTitle),
                    subtitle: Text(
                      notificationsEnabled
                          ? l10n.quickAddFromNotificationDescription
                          : l10n.enableNotificationsFirst,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    value: notificationQuickAddEnabled,
                    onChanged: notificationsEnabled
                        ? (v) => _toggleQuickAdd(ref, v)
                        : null,
                  ),
                  if (notificationQuickAddEnabled) ...[
                    Divider(height: 1, indent: 60, color: cs.outline),
                    _QuickAddAccountTile(trailingStyle: trailingStyle),
                  ],
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _toggleNotifications(WidgetRef ref, bool value) async {
    await ref.read(dbProvider).setNotificationsEnabled(value);
    if (value) {
      await ref.read(notificationServiceProvider).requestPermission();
    }
    // Quick add rides on this master switch — reflect an "off" immediately
    // rather than leaving the shortcut up until the next resume.
    await ref.read(notificationServiceProvider).syncQuickAddNotification();
  }

  Future<void> _toggleQuickAdd(WidgetRef ref, bool value) async {
    await ref.read(dbProvider).setNotificationQuickAddEnabled(value);
    await ref.read(notificationServiceProvider).syncQuickAddNotification();
  }

  Future<void> _setExpenseReminder(
    WidgetRef ref, {
    required bool enabled,
    required int hour,
    required int minute,
  }) async {
    await ref
        .read(dbProvider)
        .setExpenseReminder(enabled: enabled, hour: hour, minute: minute);
    await ref.read(notificationServiceProvider).syncExpenseReminder();
  }

  Future<void> _pickExpenseReminderTime(
    BuildContext context,
    WidgetRef ref,
    ExpenseReminderSettings current,
  ) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked == null) return;
    await _setExpenseReminder(
      ref,
      enabled: true,
      hour: picked.hour,
      minute: picked.minute,
    );
  }

  String _timeLabel(BuildContext context, int hour, int minute) =>
      TimeOfDay(hour: hour, minute: minute).format(context);
}

/// Which account a quick-add reply posts to — "First account" (the default,
/// no explicit choice made) or a specific one, picked from the same list
/// [AppDatabase.resolveQuickAddAccountId] falls back to.
class _QuickAddAccountTile extends ConsumerWidget {
  const _QuickAddAccountTile({required this.trailingStyle});

  final TextStyle? trailingStyle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final cs = Theme.of(context).colorScheme;
    final accounts = ref.watch(balanceAccountsProvider).valueOrNull ?? const [];
    final chosenId = ref.watch(quickAddAccountIdProvider);
    final chosen = accounts.where((a) => a.id == chosenId).firstOrNull;

    return AppListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      leading: const AppIcon(Icons.account_balance_wallet_outlined),
      title: Text(l10n.postsToTitle),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(chosen?.name ?? l10n.firstAccount, style: trailingStyle),
          const SizedBox(width: 4),
          AppIcon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
        ],
      ),
      onTap: () => _pick(context, ref, accounts, chosenId),
    );
  }

  Future<void> _pick(
    BuildContext context,
    WidgetRef ref,
    List<AccountRow> accounts,
    int? chosenId,
  ) async {
    // A record, not a bare `int?`: "First account" is a real pick whose
    // value is null, which a bare `int?` return can't tell apart from the
    // sheet being dismissed with no pick at all (also null) — that
    // ambiguity would silently reset an explicit choice back to "First
    // account" on every accidental dismiss.
    final result = await showAppSheet<({int? accountId})>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Text(
                AppLocalizations.of(sheetContext).postToTitle,
                style: Theme.of(sheetContext).textTheme.titleLarge,
              ),
            ),
            RadioListTile<int?>(
              title: Text(AppLocalizations.of(sheetContext).firstAccount),
              subtitle: Text(AppLocalizations.of(sheetContext).firstAccountDescription),
              value: null,
              // ignore: deprecated_member_use
              groupValue: chosenId,
              // ignore: deprecated_member_use
              onChanged: (v) => Navigator.of(sheetContext).pop((accountId: v)),
            ),
            for (final a in accounts)
              RadioListTile<int?>(
                title: Text(a.name),
                value: a.id,
                // ignore: deprecated_member_use
                groupValue: chosenId,
                // ignore: deprecated_member_use
                onChanged: (v) =>
                    Navigator.of(sheetContext).pop((accountId: v)),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
    if (!context.mounted || result == null) return;
    if (result.accountId != chosenId) {
      await ref.read(dbProvider).setQuickAddAccount(result.accountId);
    }
  }
}
