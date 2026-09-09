/// Owner default theme (§§14–16): stored in portfolio_settings,
/// applied as the site default. Visitor overrides stay local.
library;

import 'package:flutter/material.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/config/site_config.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class AppearancePage extends StatefulWidget {
  const AppearancePage({super.key});

  @override
  State<AppearancePage> createState() => _AppearancePageState();
}

class _AppearancePageState extends State<AppearancePage> {
  String _accent = 'blue';
  String _brightness = 'dark';
  Map<String, bool> _visible = {for (final s in defaultSectionOrder) s: true};
  List<String> _order = [...defaultSectionOrder];
  bool _saving = false;
  bool _loaded = false;

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AdminRepository(auth: AuthScope.of(context)).updateSettings({
        'default_theme': _accent,
        'default_brightness': _brightness,
        ...SiteConfig(visible: _visible, order: _order).toSettings(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Appearance saved.')));
      }
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _move(String section, int delta) {
    final i = _order.indexOf(section);
    final j = i + delta;
    if (i < 0 || j < 0 || j >= _order.length) return;
    setState(() {
      final next = [..._order];
      final tmp = next[i];
      next[i] = next[j];
      next[j] = tmp;
      _order = next;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return AdminScaffold(
      title: 'Appearance',
      action: FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
      body: AsyncView(
        load: () => AdminRepository(auth: auth).getSettings(),
        builder: (context, settings) {
          if (!_loaded) {
            _loaded = true;
            _accent = settings['default_theme'] ?? 'blue';
            _brightness = settings['default_brightness'] ?? 'dark';
            final config = SiteConfig.fromSettings(settings);
            _visible = Map.of(config.visible);
            _order = [...config.order];
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Accent Theme', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'blue', label: Text('Blue')),
                  ButtonSegment(value: 'purple', label: Text('Purple')),
                  ButtonSegment(value: 'emerald', label: Text('Emerald')),
                ],
                selected: {_accent},
                onSelectionChanged: (s) => setState(() => _accent = s.first),
              ),
              const SizedBox(height: 20),
              Text('Default Brightness', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'light', label: Text('Light')),
                  ButtonSegment(value: 'dark', label: Text('Dark')),
                ],
                selected: {_brightness},
                onSelectionChanged: (s) => setState(() => _brightness = s.first),
              ),
              const SizedBox(height: 12),
              const Text('Visitors can still override this temporarily in their own browser.'),
              const SizedBox(height: 20),
              Text('Sections', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Unticked sections are hidden from the public site. Use ↑ ↓ to reorder navigation.'),
              const SizedBox(height: 8),
              for (final section in _order)
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    title: Text(section[0].toUpperCase() + section.substring(1)),
                    value: _visible[section] ?? true,
                    onChanged: (v) => setState(() => _visible[section] = v ?? true),
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Move up',
                          onPressed: () => _move(section, -1),
                          icon: const Icon(Icons.arrow_upward, size: 20),
                        ),
                        IconButton(
                          tooltip: 'Move down',
                          onPressed: () => _move(section, 1),
                          icon: const Icon(Icons.arrow_downward, size: 20),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
