/// Permanent left sidebar (§5): profile header, nav, appearance, socials.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/api/portfolio_repository.dart';
import '../../core/config/site_config.dart';
import '../../core/theme/accent_theme.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../../core/utils/file_url.dart';
import '../../models/portfolio_profile.dart';
import '../widgets/social_icon.dart';

/// Extra item not in the main nav — shown at the bottom of the sidebar.
const _adminItem = NavItem('/admin/login', 'Admin', Icons.admin_panel_settings_outlined);

class AppSidebar extends StatelessWidget {
  final String location;
  final bool compact;
  const AppSidebar({super.key, required this.location, this.compact = false});

  bool _selected(String path) {
    if (path == '/') return location == '/';
    return location == path || location.startsWith('$path/');
  }

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    final theme = ThemeScope.of(context);
    return Container(
      color: tokens.sidebar,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            FutureBuilder<PortfolioProfile>(
              future: PortfolioScope.of(context).profile(),
              builder: (context, snap) {
                final profile = snap.data;
                final photoUrl = resolveFileUrl(profile?.profileImageUrl);
                final initials = initialsOf(profile?.name ?? '');
                return Column(
                  children: [
                    if (photoUrl != null)
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.transparent,
                        child: ClipOval(
                          child: Image.network(
                            photoUrl,
                            width: 72,
                            height: 72,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => CircleAvatar(
                              radius: 36,
                              child: Text(initials, style: const TextStyle(fontSize: 22)),
                            ),
                          ),
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 36,
                        child: Text(initials, style: const TextStyle(fontSize: 22)),
                      ),
                    if (!compact) ...[
                      const SizedBox(height: 12),
                      Text(
                        profile?.name ?? '…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: tokens.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 17),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile?.title ?? '',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: tokens.textSecondary, fontSize: 13),
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FutureBuilder<SiteConfig>(
                future: PortfolioScope.of(context).siteConfig(),
                builder: (context, snap) {
                  final config = snap.data ?? SiteConfig.defaults();
                  final items = [
                  for (final key in config.order)
                    for (final item in navItems)
                      if (sectionForPath(item.path) == key && config.isVisible(key)) item,
                  _adminItem,
                  ];
                  return ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    children: [
                      for (final item in items)
                        compact
                            ? IconButton(
                                tooltip: item.label,
                                isSelected: _selected(item.path),
                                onPressed: () => context.go(item.path),
                                icon: Icon(item.icon),
                              )
                            : ListTile(
                                dense: true,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                selected: _selected(item.path),
                                selectedTileColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                                leading: Icon(item.icon, size: 20),
                                title: Text(item.label),
                                onTap: () => context.go(item.path),
                              ),
                    ],
                  );
                },
              ),
            ),
            if (!compact) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Appearance', style: TextStyle(color: tokens.textSecondary, fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    ListenableBuilder(
                      listenable: theme,
                      builder: (context, _) => SegmentedButton<ThemeMode>(
                        style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                        segments: const [
                          ButtonSegment(value: ThemeMode.light, icon: Icon(Icons.light_mode, size: 16)),
                          ButtonSegment(value: ThemeMode.dark, icon: Icon(Icons.dark_mode, size: 16)),
                          ButtonSegment(value: ThemeMode.system, icon: Icon(Icons.settings_suggest, size: 16)),
                        ],
                        selected: {theme.mode},
                        onSelectionChanged: (s) => theme.setMode(s.first),
                        showSelectedIcon: false,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ListenableBuilder(
                      listenable: theme,
                      builder: (context, _) => Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          for (final accent in AccentTheme.values)
                            Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Tooltip(
                                message: accent.label,
                                child: InkWell(
                                  onTap: () => theme.setAccent(accent),
                                  customBorder: const CircleBorder(),
                                  child: Container(
                                    width: 26,
                                    height: 26,
                                    decoration: BoxDecoration(
                                      color: accent.seed,
                                      shape: BoxShape.circle,
                                      border: theme.accent == accent
                                          ? Border.all(color: tokens.textPrimary, width: 2.5)
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: PortfolioScope.of(context).socials(),
                      builder: (context, snap) {
                        final socials = snap.data ?? [];
                        if (socials.isEmpty) return const SizedBox.shrink();
                        return Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: [
                            for (final s in socials)
                              Tooltip(
                                message: s.platform,
                                child: InkWell(
                                  onTap: () {},
                                  customBorder: const CircleBorder(),
                                  child: SocialIcon(platform: s.platform, size: 20),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
