library;

import 'package:flutter/material.dart';

import '../../core/api/portfolio_repository.dart';
import '../../models/experience.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tech_chip.dart';

class ExperiencePage extends StatelessWidget {
  const ExperiencePage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AsyncView(
      load: repo.experience,
      builder: (context, items) => PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Experience', subtitle: 'Where I have worked and what I shipped.'),
            const SizedBox(height: 20),
            for (final e in items) _ExperienceCard(item: e),
          ],
        ),
      ),
    );
  }
}

class _ExperienceCard extends StatelessWidget {
  final Experience item;
  const _ExperienceCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(item.role, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                ),
                if (item.current)
                  Chip(
                    label: const Text('Current', style: TextStyle(fontSize: 12)),
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                    side: BorderSide.none,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            Text('${item.company} · ${item.location}', style: Theme.of(context).textTheme.bodyMedium),
            Text(item.rangeLabel, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(item.description),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final t in item.technologies) TechChip(label: t)],
            ),
          ],
        ),
      ),
    );
  }
}
