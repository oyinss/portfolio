/// Site configuration (§§27–28, §36): section visibility + order.
/// Stored as portfolio_settings keys; absent keys fall back to defaults.
library;

import 'dart:convert';

const defaultSectionOrder = [
  'home',
  'about',
  'projects',
  'skills',
  'experience',
  'education',
  'contact',
];

/// Section key for a public route path.
String sectionForPath(String path) {
  if (path == '/') return 'home';
  if (path == '/about') return 'about';
  if (path == '/projects' || path.startsWith('/projects/')) return 'projects';
  if (path == '/skills') return 'skills';
  if (path == '/experience') return 'experience';
  if (path == '/education') return 'education';
  if (path == '/contact') return 'contact';
  return 'home';
}

class SiteConfig {
  final Map<String, bool> visible;
  final List<String> order;

  const SiteConfig({required this.visible, required this.order});

  factory SiteConfig.defaults() => SiteConfig(
        visible: {for (final s in defaultSectionOrder) s: true},
        order: [...defaultSectionOrder],
      );

  factory SiteConfig.fromSettings(Map<String, String> settings) {
    final defaults = SiteConfig.defaults();
    Map<String, bool> visible = Map.of(defaults.visible);
    List<String> order = [...defaults.order];
    final visRaw = settings['sections'];
    if (visRaw != null && visRaw.isNotEmpty) {
      try {
        final decoded = Map<String, dynamic>.from(jsonDecode(visRaw) as Map);
        for (final key in defaults.visible.keys) {
          if (decoded[key] is bool) visible[key] = decoded[key] as bool;
        }
      } catch (_) {}
    }
    final orderRaw = settings['section_order'];
    if (orderRaw != null && orderRaw.isNotEmpty) {
      try {
        final decoded = (jsonDecode(orderRaw) as List).map((e) => '$e').toList();
        final known = decoded.where((e) => defaults.visible.containsKey(e)).toList();
        if (known.isNotEmpty) {
          order = [...known, ...defaults.order.where((e) => !known.contains(e))];
        }
      } catch (_) {}
    }
    return SiteConfig(visible: visible, order: order);
  }

  bool isVisible(String section) => visible[section] ?? true;

  Map<String, dynamic> toSettings() => {
        'sections': jsonEncode(visible),
        'section_order': jsonEncode(order),
      };
}
