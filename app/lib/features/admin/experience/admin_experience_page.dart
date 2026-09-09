/// Experience admin (§25).
library;

import 'package:flutter/material.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/api/portfolio_repository.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class AdminExperiencePage extends StatefulWidget {
  const AdminExperiencePage({super.key});

  @override
  State<AdminExperiencePage> createState() => _AdminExperiencePageState();
}

class _AdminExperiencePageState extends State<AdminExperiencePage> {
  int _refresh = 0;
  void _reload() => setState(() => _refresh++);

  Future<void> _edit([Map<String, dynamic>? existing]) async {
    final admin = AdminRepository(auth: AuthScope.of(context));
    final company = TextEditingController(text: '${existing?['company'] ?? ''}');
    final role = TextEditingController(text: '${existing?['role'] ?? ''}');
    final location = TextEditingController(text: '${existing?['location'] ?? ''}');
    final start = TextEditingController(text: '${existing?['start_date'] ?? ''}');
    final end = TextEditingController(text: '${existing?['end_date'] ?? ''}');
    final description = TextEditingController(text: '${existing?['description'] ?? ''}');
    final techs = TextEditingController(text: ((existing?['technologies'] as List?) ?? []).join(', '));
    final order = TextEditingController(text: '${existing?['display_order'] ?? 0}');
    bool current = ((existing?['current'] as int?) ?? 0) == 1;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setD) => AlertDialog(
          title: Text(existing == null ? 'Add Experience' : 'Edit Experience'),
          content: SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: company, decoration: const InputDecoration(labelText: 'Company *')),
                  TextField(controller: role, decoration: const InputDecoration(labelText: 'Role *')),
                  TextField(controller: location, decoration: const InputDecoration(labelText: 'Location')),
                  TextField(controller: start, decoration: const InputDecoration(labelText: 'Start Date')),
                  TextField(controller: end, decoration: const InputDecoration(labelText: 'End Date')),
                  SwitchListTile(title: const Text('Current position'), value: current, onChanged: (v) => setD(() => current = v)),
                  TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
                  TextField(controller: techs, decoration: const InputDecoration(labelText: 'Technologies (comma separated)')),
                  TextField(controller: order, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Display Order')),
                ],
              ),
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
      await admin.saveExperience({
        'company': company.text.trim(),
        'role': role.text.trim(),
        'location': location.text.trim(),
        'startDate': start.text.trim(),
        'endDate': end.text.trim().isEmpty ? null : end.text.trim(),
        'current': current,
        'description': description.text.trim(),
        'technologies': techs.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        'displayOrder': int.tryParse(order.text.trim()) ?? 0,
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
      await admin.delete('/api/experience/$id');
      _reload();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AdminScaffold(
      title: 'Experience',
      action: FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add, size: 18), label: const Text('Add')),
      body: AsyncView(
        key: ValueKey(_refresh),
        load: repo.experience,
        builder: (context, items) => Column(
          children: [
            for (final e in items)
              Card(
                child: ListTile(
                  title: Text(e.role),
                  subtitle: Text('${e.company} · ${e.rangeLabel}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _edit({'id': e.id, 'company': e.company, 'role': e.role, 'location': e.location, 'start_date': e.startDate, 'end_date': e.endDate, 'current': e.current ? 1 : 0, 'description': e.description, 'technologies': e.technologies, 'display_order': e.displayOrder})),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _delete(e.id, e.role)),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
