/// Responsive shell (§42): sidebar ≥1024px, rail ≥700px, drawer below.
/// Hidden sections (§27) render a disabled notice instead of content.
/// Pull-to-refresh on mobile reloads the page.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/api/portfolio_repository.dart';
import '../../core/config/site_config.dart';
import '../../core/theme/app_tokens.dart';
import '../../core/theme/theme_controller.dart';
import '../widgets/app_sidebar.dart';

class ResponsiveShell extends StatelessWidget {
  final String location;
  final Widget child;
  const ResponsiveShell({super.key, required this.location, required this.child});

  @override
  Widget build(BuildContext context) {
    final gated = _GatedChild(location: location, child: child);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1024) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(width: 264, child: AppSidebar(location: location)),
                VerticalDivider(width: 1, color: context.tokens.border),
                Expanded(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 1080),
                      child: gated,
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        if (constraints.maxWidth >= 700) {
          return Scaffold(
            body: Row(
              children: [
                SizedBox(width: 76, child: AppSidebar(location: location, compact: true)),
                VerticalDivider(width: 1, color: context.tokens.border),
                Expanded(child: gated),
              ],
            ),
          );
        }
        final theme = ThemeScope.of(context);
        return Scaffold(
          appBar: AppBar(
            title: Text(_titleFor(location)),
            actions: [
              ListenableBuilder(
                listenable: theme,
                builder: (context, _) => IconButton(
                  tooltip: 'Toggle light/dark',
                  onPressed: theme.toggleLightDark,
                  icon: Icon(theme.mode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode),
                ),
              ),
            ],
          ),
          drawer: Drawer(child: AppSidebar(location: location)),
          body: RefreshIndicator(
            onRefresh: () async => context.go(location),
            child: gated,
          ),
        );
      },
    );
  }

  String _titleFor(String location) {
    for (final item in navItems) {
      if (item.path == '/') {
        if (location == '/') return item.label;
      } else if (location == item.path || location.startsWith('${item.path}/')) {
        return item.path == '/projects' && location != '/projects' ? 'Project' : item.label;
      }
    }
    if (location.startsWith('/projects/')) return 'Project';
    return 'Portfolio';
  }
}

class _GatedChild extends StatelessWidget {
  final String location;
  final Widget child;
  const _GatedChild({required this.location, required this.child});

  static const _titles = {
    'home': 'Home',
    'about': 'About',
    'projects': 'Projects',
    'skills': 'Skills',
    'experience': 'Experience',
    'education': 'Education',
    'contact': 'Contact',
  };

  @override
  Widget build(BuildContext context) {
    // Admin routes are never gated.
    if (location.startsWith('/admin')) return child;
    final title = '${_titles[sectionForPath(location)] ?? 'Portfolio'} | Portfolio';
    return Title(
      title: title,
      color: Theme.of(context).colorScheme.primary,
      child: FutureBuilder<SiteConfig>(
      future: PortfolioScope.of(context).siteConfig(),
      builder: (context, snap) {
        final config = snap.data ?? SiteConfig.defaults();
        if (snap.connectionState != ConnectionState.done || config.isVisible(sectionForPath(location))) {
          return child;
        }
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.visibility_off_outlined, size: 40),
                const SizedBox(height: 12),
                const Text('This section is disabled by the portfolio owner.'),
                const SizedBox(height: 4),
                TextButton(
                  onPressed: () => context.go('/'),
                  child: const Text('Go home'),
                ),
              ],
            ),
          ),
        );
      },
      ),
    );
  }
}
