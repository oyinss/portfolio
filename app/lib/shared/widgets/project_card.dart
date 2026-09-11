library;

import 'package:flutter/material.dart';

import '../../core/utils/file_url.dart';
import '../../models/project.dart';
import 'tech_chip.dart';

/// Fixed-height card for grids: single Column (no nested flex) with the
/// action pinned to the bottom via Spacer — safe because grid tiles impose
/// tight height constraints. Text is capped so content never overflows.
class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = resolveFileUrl(project.imageUrl);
    final extraTechs = project.technologies.length - 4;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              Image.network(
                imageUrl,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (project.featured)
                    const Tooltip(message: 'Featured', child: Icon(Icons.star, size: 18)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                '${project.type} · ${project.dateLabel}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Text(
                project.shortDescription,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final t in project.technologies.take(4)) TechChip(label: t),
                  if (extraTechs > 0) TechChip(label: '+$extraTechs'),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onTap,
                  child: const Text('Open →'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
