library;

import 'package:flutter/material.dart';

import '../../core/api/portfolio_repository.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/section_header.dart';

class EducationPage extends StatelessWidget {
  const EducationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AsyncView(
      load: repo.education,
      builder: (context, items) => PageContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(title: 'Education', subtitle: 'Formal training and qualifications.'),
            const SizedBox(height: 20),
            for (final e in items)
              Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${e.qualification} · ${e.course}',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                      Text(e.institution),
                      Text(e.rangeLabel, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(e.description),
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
