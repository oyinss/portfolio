library;

import 'package:flutter/material.dart';

/// Max-width content wrapper shared by section pages.
/// Supports pull-to-refresh on mobile (§9 quality).
class PageContainer extends StatelessWidget {
  final Widget child;
  final Future<void> Function()? onRefresh;
  const PageContainer({super.key, required this.child, this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final content = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: child,
    );
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        child: content,
      );
    }
    return content;
  }
}

/// Simple placeholder for sections built out in Phase 2.
class SectionPlaceholder extends StatelessWidget {
  final String title;
  final String subtitle;
  const SectionPlaceholder({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('API-driven content lands here in Phase 4. Mock data in Phase 2.'))),
        ],
      ),
    );
  }
}
