/// Admin home (§18): counts, recent projects, section links.
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/admin_repository.dart';
import '../../../core/api/auth_service.dart';
import '../../../core/api/portfolio_repository.dart';
import '../../../shared/widgets/async_view.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  Future<({int projects, int skills, int experience, List recent})> _load(
      PortfolioRepository repo, AdminRepository admin) async {
    final results = await Future.wait([
      admin.allProjects(),
      repo.skills(),
      repo.experience(),
    ]);
    final projects = results[0] as List;
    return (
      projects: projects.length,
      skills: (results[1] as List).length,
      experience: (results[2] as List).length,
      recent: projects.take(5).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = AuthScope.of(context);
    final admin = AdminRepository(auth: auth);
    final repo = PortfolioScope.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'View site',
            onPressed: () => context.go('/'),
            icon: const Icon(Icons.public),
          ),
          IconButton(
            tooltip: 'Log out',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) context.go('/admin/login');
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: AsyncView(
        load: () => _load(repo, admin),
        builder: (context, data) => Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Signed in as ${auth.email ?? 'admin'}',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _CountCard(label: 'Projects', value: data.projects, route: '/admin/projects'),
                      const SizedBox(width: 12),
                      _CountCard(label: 'Skills', value: data.skills, route: '/admin/skills'),
                      const SizedBox(width: 12),
                      _CountCard(label: 'Experience', value: data.experience, route: '/admin/experience'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Manage', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _Link(label: 'Profile', icon: Icons.person_outline, route: '/admin/profile'),
                      _Link(label: 'Projects', icon: Icons.folder_outlined, route: '/admin/projects'),
                      _Link(label: 'Skills', icon: Icons.code, route: '/admin/skills'),
                      _Link(label: 'Experience', icon: Icons.work_outline, route: '/admin/experience'),
                      _Link(label: 'Education', icon: Icons.school_outlined, route: '/admin/education'),
                      _Link(label: 'Social Links', icon: Icons.link, route: '/admin/socials'),
                      _Link(label: 'Appearance', icon: Icons.palette_outlined, route: '/admin/appearance'),
                      _Link(label: 'Settings', icon: Icons.settings_outlined, route: '/admin/settings'),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text('Recent Projects', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  for (final p in data.recent)
                    Card(
                      child: ListTile(
                        title: Text('${p['title']}'),
                        subtitle: Text('${p['status']} · order ${p['display_order']}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/admin/projects/${p['id']}/edit'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CountCard extends StatelessWidget {
  final String label;
  final int value;
  final String route;
  const _CountCard({required this.label, required this.value, required this.route});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: InkWell(
          onTap: () => context.go(route),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Text('$value', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                Text(label),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Link extends StatelessWidget {
  final String label;
  final IconData icon;
  final String route;
  const _Link({required this.label, required this.icon, required this.route});

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: () => context.go(route),
    );
  }
}
