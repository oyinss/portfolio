library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/api/portfolio_repository.dart';
import '../../core/utils/file_url.dart';
import '../../models/portfolio_profile.dart';
import '../../shared/widgets/async_view.dart';
import '../../shared/widgets/page_scaffold.dart';
import '../../shared/widgets/project_card.dart';
import '../../shared/widgets/social_icon.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<({PortfolioProfile profile, List featured, int techCount})> _load(
      PortfolioRepository repo) async {
    final results = await Future.wait([
      repo.profile(),
      repo.featuredProjects(),
      repo.skills(),
    ]);
    final profile = results[0] as PortfolioProfile;
    return (
      profile: profile,
      featured: results[1] as List,
      techCount: (results[2] as List).length,
    );
  }

  @override
  Widget build(BuildContext context) {
    final repo = PortfolioScope.of(context);
    return AsyncView(
      load: () => _load(repo),
      builder: (context, data) => _HomeBody(
        profile: data.profile,
        featured: data.featured,
        techCount: data.techCount,
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  final PortfolioProfile profile;
  final List featured;
  final int techCount;
  const _HomeBody({required this.profile, required this.featured, required this.techCount});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final wide = MediaQuery.widthOf(context) >= 800;
    final photoUrl = resolveFileUrl(profile.profileImageUrl);
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (photoUrl != null) ...[
            CircleAvatar(radius: 48, backgroundImage: NetworkImage(photoUrl)),
            const SizedBox(height: 16),
          ],
          Text(
            profile.headline,
            style: text.labelLarge?.copyWith(
              letterSpacing: 2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(profile.name, style: text.displayMedium?.copyWith(fontWeight: FontWeight.w800)),
          Text(profile.title, style: text.headlineSmall),
          const SizedBox(height: 12),
          Text(profile.intro),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            children: [
              FilledButton(onPressed: () => context.go('/projects'), child: const Text('View Projects')),
              OutlinedButton(onPressed: () => context.go('/contact'), child: const Text('Contact Me')),
            ],
          ),
          const SizedBox(height: 28),
          Wrap(
            spacing: 32,
            children: [
              _Stat(value: profile.yearsExperience, label: 'Experience'),
              _Stat(value: '${featured.length}+', label: 'Featured'),
              _Stat(value: '$techCount+', label: 'Technologies'),
            ],
          ),
          const SizedBox(height: 32),
          Text('Featured Projects', style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: wide ? 3 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              for (final p in featured)
                SizedBox(
                  height: 300,
                  child: ProjectCard(project: p, onTap: () => context.go('/projects/${p.slug}')),
                ),
            ],
          ),
          const SizedBox(height: 20),
          _Socials(repo: PortfolioScope.of(context)),
        ],
      ),
    );
  }
}

class _Socials extends StatelessWidget {
  final PortfolioRepository repo;
  const _Socials({required this.repo});

  @override
  Widget build(BuildContext context) {
    return AsyncView(
      load: repo.socials,
      builder: (context, socials) {
        if (socials.isEmpty) return const SizedBox.shrink();
        return Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final s in socials)
              Tooltip(
                message: s.platform,
                child: OutlinedButton.icon(
                  onPressed: () {},
                  icon: SocialIcon(platform: s.platform),
                  label: Text(s.platform),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  const _Stat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
        Text(label),
      ],
    );
  }
}
