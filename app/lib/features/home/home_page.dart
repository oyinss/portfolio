library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api/portfolio_repository.dart';
import '../../core/theme/accent_theme.dart';
import '../../core/theme/theme_controller.dart';
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
    return PageContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _HeroCard(profile: profile),
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
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: wide ? 3 : 1,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              mainAxisExtent: 500,
            ),
            itemCount: featured.length,
            itemBuilder: (context, i) {
              final p = featured[i];
              return ProjectCard(project: p, onTap: () => context.go('/projects/${p.slug}'));
            },
          ),
          const SizedBox(height: 20),
          _Socials(repo: PortfolioScope.of(context)),
        ],
      ),
    );
  }
}

/// Dark hero card: ringed photo, name headline, CV + Hire-Me actions.
/// Stays dark in both brightness modes; the ring and filled button follow
/// the active accent color.
class _HeroCard extends StatelessWidget {
  final PortfolioProfile profile;
  const _HeroCard({required this.profile});

  Future<void> _downloadCv(BuildContext context) async {
    final url = resolveFileUrl(profile.resumeUrl);
    if (url == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No resume uploaded yet — add one in Admin → Profile.')),
      );
      return;
    }
    final uri = Uri.tryParse(url);
    if (uri == null || !(await launchUrl(uri))) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not open the resume.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Raw accent seed: ColorScheme.primary is a muted tonal derivative.
    final accentSeed = ThemeScope.of(context).accent.seed;
    final onAccent = ThemeData.estimateBrightnessForColor(accentSeed) == Brightness.dark
        ? Colors.white
        : Colors.black;
    final accent = accentSeed;
    final photoUrl = resolveFileUrl(profile.profileImageUrl);
    final wide = MediaQuery.widthOf(context) >= 800;
    final photo = SizedBox(
      width: 220,
      height: 220,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accent, width: 3),
            ),
            child: ClipOval(
              child: photoUrl != null
                  ? Image.network(
                      photoUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (c, e, s) => _HeroFallback(initials: initialsOf(profile.name)),
                    )
                  : _HeroFallback(initials: initialsOf(profile.name)),
            ),
          ),
          Positioned(
            right: 16,
            top: 44,
            child: Container(width: 18, height: 18, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          ),
          Positioned(
            left: 16,
            bottom: 44,
            child: Container(width: 18, height: 18, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
          ),
        ],
      ),
    );
    final copy = Column(
      crossAxisAlignment: wide ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          '${profile.headline.isNotEmpty ? '${profile.headline} ' : ''}This is ${profile.name}'.trim(),
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          profile.title,
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 12),
        Text(
          profile.intro,
          textAlign: wide ? TextAlign.start : TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: wide ? WrapAlignment.start : WrapAlignment.center,
          children: [
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: accent, foregroundColor: onAccent),
              onPressed: () => _downloadCv(context),
              child: const Text('Download CV'),
            ),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Colors.white54),
              ),
              onPressed: () => context.go('/contact'),
              child: const Text('Hire Me'),
            ),
          ],
        ),
      ],
    );
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF141A12), Color(0xFF0A0D0A)],
        ),
      ),
      child: wide
          ? Row(
              children: [
                photo,
                const SizedBox(width: 36),
                Expanded(child: copy),
              ],
            )
          : Column(
              children: [
                photo,
                const SizedBox(height: 24),
                copy,
              ],
            ),
    );
  }
}

class _HeroFallback extends StatelessWidget {
  final String initials;
  const _HeroFallback({required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF1E2420),
      child: Center(
        child: Text(initials, style: const TextStyle(fontSize: 56, color: Colors.white)),
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
