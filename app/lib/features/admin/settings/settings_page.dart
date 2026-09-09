/// Site settings (§36): title, SEO, contact email.
library;

import 'package:flutter/material.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _fields = <String, TextEditingController>{};
  bool _saving = false;
  bool _loaded = false;

  static const _defs = [
    ('site_title', 'Site Title'),
    ('seo_description', 'SEO Description'),
    ('contact_email', 'Contact Email'),
  ];

  TextEditingController _c(String k, [String v = '']) =>
      _fields.putIfAbsent(k, () => TextEditingController(text: v));

  @override
  void dispose() {
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await AdminRepository(auth: AuthScope.of(context)).updateSettings({
        for (final (key, _) in _defs) key: _c(key).text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Settings saved.')));
      }
    } catch (e) {
      if (mounted) showAdminError(context, e);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return AdminScaffold(
      title: 'Settings',
      action: FilledButton(onPressed: _saving ? null : _save, child: Text(_saving ? 'Saving…' : 'Save')),
      body: AsyncView(
        load: () => AdminRepository(auth: auth).getSettings(),
        builder: (context, settings) {
          if (!_loaded) {
            _loaded = true;
            for (final (key, _) in _defs) {
              _c(key, settings[key] ?? '');
            }
          }
          return Column(
            children: [
              for (final (key, label) in _defs)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: TextField(
                    controller: _c(key),
                    maxLines: key == 'seo_description' ? 3 : 1,
                    decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
