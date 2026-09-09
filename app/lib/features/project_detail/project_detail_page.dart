library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/portfolio_repository.dart';
import '../../models/project.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/tech_chip.dart';

class ProjectDetailPage extends StatelessWidget {
  final String slug;
  const ProjectDetailPage({super.key, required this.slug});

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AsyncView(
      load: () => repo.projectBySlug(slug),
      builder: (context, project) {
        if (project == null) {
          return PageContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Project not found', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 8),
                const Text('It may be a draft or the link is wrong.'),
                const SizedBox(height: 16),
                FilledButton(onPressed: () => context.go('/projects'), child: const Text('Back to Projects')),
              ],
            ),
          );
        }
        return _DetailBody(project: project);
      },
    );
  }
}

class _DetailBody extends StatelessWidget {
  final Project project;
  const _DetailBody({required this.project});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                project.title.toUpperCase(),
                style: text.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('${project.type} · ${project.dateLabel}', style: text.bodySmall),
          Text(project.title, style: text.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(project.description, style: text.bodyLarge),
          const SizedBox(height: 20),
          _Block(title: 'Problem', body: project.problem),
          _Block(title: 'Solution', body: project.solution),
          if (project.features.isNotEmpty) ...[
            Text('Features', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            for (final f in project.features)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [const Text('•  '), Expanded(child: Text(f))],
                ),
              ),
            const SizedBox(height: 16),
          ],
          Text('Technologies', style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [for (final t in project.technologies) TechChip(label: t)],
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 12,
            children: [
              if (project.liveUrl != null)
                FilledButton(onPressed: () {}, child: const Text('Visit Website')),
              if (project.githubUrl != null)
                OutlinedButton(onPressed: () {}, child: const Text('View GitHub')),
            ],
          ),
        ],
      ),
    );
  }
}

class _Block extends StatelessWidget {
  final String title;
  final String body;
  const _Block({required this.title, required this.body});

  @override
  Widget build(BuildContext context) {
    if (body.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(body),
        ],
      ),
    );
  }
}
