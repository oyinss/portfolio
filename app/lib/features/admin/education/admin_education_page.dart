/// Education admin (§26).
library;

import 'package:flutter/material.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/api/portfolio_repository.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class AdminEducationPage extends StatefulWidget {
  const AdminEducationPage({super.key});

  @override
  State<AdminEducationPage> createState() => _AdminEducationPageState();
}

class _AdminEducationPageState extends State<AdminEducationPage> {
  int _refresh = 0;
  void _reload() => setState(() => _refresh++);

  Future<void> _edit([Map<String, dynamic>? existing]) async {
    final admin = AdminRepository(auth: AuthScope.of(context));
    final institution = TextEditingController(text: '${existing?['institution'] ?? ''}');
    final qualification = TextEditingController(text: '${existing?['qualification'] ?? ''}');
    final course = TextEditingController(text: '${existing?['course'] ?? ''}');
    final startYear = TextEditingController(text: '${existing?['start_year'] ?? ''}');
    final endYear = TextEditingController(text: '${existing?['end_year'] ?? ''}');
    final description = TextEditingController(text: '${existing?['description'] ?? ''}');
    final order = TextEditingController(text: '${existing?['display_order'] ?? 0}');
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(existing == null ? 'Add Education' : 'Edit Education'),
        content: SizedBox(
          width: 400,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: institution, decoration: const InputDecoration(labelText: 'Institution *')),
                TextField(controller: qualification, decoration: const InputDecoration(labelText: 'Qualification')),
                TextField(controller: course, decoration: const InputDecoration(labelText: 'Course')),
                TextField(controller: startYear, decoration: const InputDecoration(labelText: 'Start Year')),
                TextField(controller: endYear, decoration: const InputDecoration(labelText: 'End Year')),
                TextField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
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
    );
    if (saved != true || !mounted) return;
    try {
      await admin.saveEducation({
        'institution': institution.text.trim(),
        'qualification': qualification.text.trim(),
        'course': course.text.trim(),
        'startYear': startYear.text.trim(),
        'endYear': endYear.text.trim().isEmpty ? null : endYear.text.trim(),
        'description': description.text.trim(),
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
      await admin.delete('/api/education/$id');
      _reload();
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AdminScaffold(
      title: 'Education',
      action: FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add, size: 18), label: const Text('Add')),
      body: AsyncView(
        key: ValueKey(_refresh),
        load: repo.education,
        builder: (context, items) => Column(
          children: [
            for (final e in items)
              Card(
                child: ListTile(
                  title: Text('${e.qualification} · ${e.course}'),
                  subtitle: Text('${e.institution} · ${e.rangeLabel}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(icon: const Icon(Icons.edit_outlined, size: 20), onPressed: () => _edit({'id': e.id, 'institution': e.institution, 'qualification': e.qualification, 'course': e.course, 'start_year': e.startYear, 'end_year': e.endYear, 'description': e.description, 'display_order': 0})),
                      IconButton(icon: const Icon(Icons.delete_outline, size: 20), onPressed: () => _delete(e.id, e.institution)),
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
