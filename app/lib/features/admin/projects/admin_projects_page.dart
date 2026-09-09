/// Project list (§20): published + drafts, edit/delete.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../shared/widgets/async_view.dart';
import '../widgets/admin_scaffold.dart';

class AdminProjectsPage extends StatefulWidget {
  const AdminProjectsPage({super.key});

  @override
  State<AdminProjectsPage> createState() => _AdminProjectsPageState();
}

class _AdminProjectsPageState extends State<AdminProjectsPage> {
  int _refresh = 0;

  Future<void> _delete(String id, String title) async {
    final admin = AdminRepository(auth: AuthScope.of(context));
    if (!await confirmDelete(context, title)) return;
    try {
      await admin.delete('/api/projects/$id');
      if (mounted) setState(() => _refresh++);
    } catch (e) {
      if (mounted) showAdminError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    return AdminScaffold(
      title: 'Projects',
      action: FilledButton.icon(
        onPressed: () => context.go('/admin/projects/new'),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Add'),
      ),
      body: AsyncView(
        key: ValueKey(_refresh),
        load: () => AdminRepository(auth: auth).allProjects(),
        builder: (context, projects) => Column(
          children: [
            for (final p in projects)
              Card(
                child: ListTile(
                  title: Text('${p['title']}'),
                  subtitle: Text('${p['status']} · order ${p['display_order']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if ((p['featured'] as int? ?? 0) == 1)
                        const Padding(
                          padding: EdgeInsets.only(right: 4),
                          child: Icon(Icons.star, size: 18),
                        ),
                      IconButton(
                        tooltip: 'Edit',
                        onPressed: () => context.go('/admin/projects/${p['id']}/edit'),
                        icon: const Icon(Icons.edit_outlined, size: 20),
                      ),
                      IconButton(
                        tooltip: 'Delete',
                        onPressed: () => _delete('${p['id']}', '${p['title']}'),
                        icon: const Icon(Icons.delete_outline, size: 20),
                      ),
                    ],
                  ),
                  onTap: () => context.go('/admin/projects/${p['id']}/edit'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
