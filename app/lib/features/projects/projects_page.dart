library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/portfolio_repository.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/project_card.dart';
import '../../shared/widgets/section_header.dart';

class ProjectsPage extends StatelessWidget {
  const ProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    final wide = MediaQuery.widthOf(context) >= 800;
    return AsyncView(
      load: repo.publishedProjects,
      builder: (context, projects) => PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              title: 'Projects',
              subtitle: '${projects.length} published projects. Tap any card for the full case study.',
            ),
            const SizedBox(height: 20),
            LayoutBuilder(
              builder: (context, constraints) {
                final tileWidth =
                    wide ? (constraints.maxWidth - 12) / 2 : constraints.maxWidth;
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final p in projects)
                      SizedBox(
                        width: tileWidth,
                        child: ProjectCard(
                            project: p, onTap: () => context.go('/projects/${p.slug}')),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
