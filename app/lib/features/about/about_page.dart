library;

import 'package:flutter/material.dart';

import '../../core/api/portfolio_repository.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_header.dart';
import '../../shared/widgets/tech_chip.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AsyncView(
      load: repo.profile,
      builder: (context, p) => PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'About Me', subtitle: 'Career summary and how to reach me.'),
            const SizedBox(height: 20),
            Text(p.bio, style: Theme.of(context).textTheme.bodyLarge),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _InfoTile(label: 'Location', value: p.location, icon: Icons.place_outlined),
                _InfoTile(label: 'Experience', value: p.yearsExperience, icon: Icons.timeline),
                _InfoTile(label: 'Current Role', value: p.currentRole, icon: Icons.work_outline),
                _InfoTile(label: 'Availability', value: p.availability, icon: Icons.event_available_outlined),
              ],
            ),
            const SizedBox(height: 24),
            Text('Interests', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [for (final i in p.interests) TechChip(label: i)],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Resume download arrives with R2 file storage (Phase 7).')),
              ),
              icon: const Icon(Icons.download),
              label: const Text('Download Resume'),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20),
              const SizedBox(height: 8),
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      ),
    );
  }
}
