/// Social links admin (§13).
library;

import 'package:flutter/material.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/api/portfolio_repository.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class AdminSocialsPage extends StatefulWidget {
  const AdminSocialsPage({super.key});

  @override
  State<AdminSocialsPage> createState() => _AdminSocialsPageState();
}

class _AdminSocialsPageState extends State<AdminSocialsPage> {
  int _refresh = 0;
  void _reload() => setState(() => _refresh++);

  Future<Map<String, dynamic>> _loadSocials(PortfolioRepository repo, AdminRepository admin) async {
    final rows = ((await admin.get('/api/admin/socials')) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    return {'rows': rows};
  }

  Future<void> _edit([Map<String, dynamic>? existing]) async {
    final admin = AdminRepository(auth: AuthScope.of(context));
    final platform = TextEditingController(text: '${existing?['platform'] ?? ''}');
    final url = TextEditingController(text: '${existing?['url'] ?? ''}');
    final order = TextEditingController(text: '${existing?['display_order'] ?? 0}');
    bool enabled = ((existing?['enabled'] as int?) ?? 1) == 1;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: Text(existing == null ? 'Add Link' : 'Edit Link'),
          content: SizedBox(
            width: 360,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: platform, decoration: const InputDecoration(labelText: 'Platform *')),
                TextField(controller: url, decoration: const InputDecoration(labelText: 'URL *')),
                TextField(controller: order, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Display Order')),
                SwitchListTile(title: const Text('Enabled'), value: enabled, onChanged: (v) => setD(() => enabled = v)),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
          ],
        ),
      ),
    );
    if (saved != true || !mounted) return;
    try {
      await admin.saveSocial({
        'platform': platform.text.trim(),
        'url': url.text.trim(),
        'displayOrder': int.tryParse(order.text.trim()) ?? 0,
        'enabled': enabled,
      }, id: existing?['id'] as String?);
      _reload();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  Future<void> _delete(String id, String label) async {
    final admin = AdminRepository(auth: AuthScope.of(context));
    if (!await confirmDelete(context, label)) return;
    try {
      await admin.delete('/api/socials/$id');
      _reload();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final repo = PortfolioScope.of(context);
    return AdminScaffold(
      title: 'Social Links',
      action: FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add, size: 18), label: const Text('Add')),
      body: AsyncView(
        key: ValueKey(_refresh),
        load: () => _loadSocials(repo, AdminRepository(auth: auth)),
        builder: (context, data) {
          final rows = data['rows'] as List;
          return Column(
            children: [
              for (final s in rows)
                Card(
                  child: ListTile(
                    title: Text('${s['platform']}'),
                    subtitle: Text('${s['url']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (s['id'] == null)
                          const Chip(label: Text('public view', style: TextStyle(fontSize: 11)))
                        else ...[
                          IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _edit(Map<String, dynamic>.from(s as Map))),
                          IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _delete('${s['id']}', '${s['platform']}')),
                        ],
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
