import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'package:nemro/core/constants/app_constants.dart';
import 'package:nemro/core/l10n/generated/app_localizations.dart';
import 'package:nemro/core/preferences/preferences_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final localeCode =
        ref.watch(localeProvider)?.languageCode ??
        Localizations.localeOf(context).languageCode;
    final themeMode = ref.watch(themeModeProvider);

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(
            l10n.settingsTitle,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _SettingsSection(
                title: l10n.settingsLanguage,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: SegmentedButton<String>(
                    segments: [
                      ButtonSegment(
                        value: 'vi',
                        label: Text(l10n.languageVietnamese),
                      ),
                      ButtonSegment(
                        value: 'en',
                        label: Text(l10n.languageEnglish),
                      ),
                    ],
                    selected: {localeCode == 'en' ? 'en' : 'vi'},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      ref
                          .read(localeProvider.notifier)
                          .setLocale(Locale(selection.first));
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsAppearance,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                  child: SegmentedButton<ThemeMode>(
                    segments: [
                      ButtonSegment(
                        value: ThemeMode.system,
                        label: Text(l10n.settingsThemeSystem),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        label: Text(l10n.settingsThemeLight),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        label: Text(l10n.settingsThemeDark),
                      ),
                    ],
                    selected: {themeMode},
                    showSelectedIcon: false,
                    onSelectionChanged: (selection) {
                      ref
                          .read(themeModeProvider.notifier)
                          .setThemeMode(selection.first);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsPrivacy,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.shield_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(l10n.settingsPrivacyPolicy),
                      subtitle: Text(l10n.settingsPrivacyBody),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/privacy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsData,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: theme.colorScheme.error,
                      ),
                      title: Text(
                        l10n.settingsDeleteData,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      subtitle: Text(l10n.settingsDeleteDataBody),
                      onTap: () => _confirmReset(context, ref),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              _SettingsSection(
                title: l10n.settingsAbout,
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      title: Text(l10n.aboutTitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () => context.push('/about'),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.tag_rounded),
                      title: Text(l10n.settingsVersion),
                      trailing: Text(
                        AppConstants.version,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.description_outlined),
                      title: Text(l10n.settingsLicenses),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        showLicensePage(
                          context: context,
                          applicationName: l10n.appName,
                          applicationVersion: AppConstants.version,
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.homeFooter,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.settingsDeleteDataConfirm),
        content: Text(l10n.settingsDeleteDataBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.settingsCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.settingsDelete),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.clear();
    ref.invalidate(localeProvider);
    ref.invalidate(themeModeProvider);
    ref.invalidate(onboardingCompleteProvider);

    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.settingsDeleteDataDone)));
      context.go('/onboarding');
    }
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Card(
          elevation: 0,
          margin: EdgeInsets.zero,
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          clipBehavior: Clip.antiAlias,
          child: child,
        ),
      ],
    );
  }
}
