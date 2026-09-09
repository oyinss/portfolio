library;

import 'package:flutter/material.dart';

import '../../models/project.dart';
import 'tech_chip.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onTap;
  const ProjectCard({super.key, required this.project, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      project.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  if (project.featured)
                    const Tooltip(message: 'Featured', child: Icon(Icons.star, size: 18)),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${project.type} · ${project.dateLabel}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 8),
              Text(project.shortDescription),
              const SizedBox(height: 12),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [for (final t in project.technologies) TechChip(label: t)],
              ),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(onPressed: onTap, child: const Text('Open →')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
