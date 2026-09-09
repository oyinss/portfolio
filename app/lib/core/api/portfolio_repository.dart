/// Portfolio repository (Phase 4): live API when API_URL is set,
/// mock data otherwise — so local dev works with no backend.
library;

import 'package:flutter/widgets.dart';

import '../../models/education.dart';
import '../../models/experience.dart';
import '../../models/portfolio_profile.dart';
import '../../models/project.dart';
import '../../models/skill.dart';
import '../../models/social_link.dart';
import '../config/site_config.dart';
import '../data/mock_portfolio.dart' as mock;
import 'api_client.dart';

class PortfolioRepository {
  final ApiClient? _api;

  PortfolioRepository({String? baseUrl})
      : _api = (baseUrl ?? apiBaseUrl).isEmpty ? null : ApiClient(baseUrl: baseUrl ?? apiBaseUrl);

  bool get isLive => _api != null;

  Future<PortfolioProfile>? _profileCache;

  Future<PortfolioProfile> profile() {
    final api = _api;
    if (api == null) return Future.value(mock.mockProfile);
    return _profileCache ??= _fetchProfile(api);
  }

  Future<PortfolioProfile> _fetchProfile(ApiClient api) async {
    final json = Map<String, dynamic>.from(await api.getJson('/api/profile') as Map);
    return PortfolioProfile.fromJson(json);
  }

  Future<List<Project>> publishedProjects() async {
    final api = _api;
    if (api == null) return mock.publishedProjects;
    final list = (await api.getJson('/api/projects') as List)
        .map((e) => Project.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<List<Project>> featuredProjects() async =>
      (await publishedProjects()).where((p) => p.featured).toList();

  Future<Project?> projectBySlug(String slug) async {
    final api = _api;
    if (api == null) return mock.projectBySlug(slug);
    try {
      return Project.fromJson(
          Map<String, dynamic>.from(await api.getJson('/api/projects/$slug') as Map));
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<List<Skill>> skills() async {
    final api = _api;
    if (api == null) return [...mock.mockSkills];
    final list = (await api.getJson('/api/skills') as List)
        .map((e) => Skill.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<List<Experience>> experience() async {
    final api = _api;
    if (api == null) return [...mock.mockExperience];
    final list = (await api.getJson('/api/experience') as List)
        .map((e) => Experience.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
    return list;
  }

  Future<List<Education>> education() async {
    final api = _api;
    if (api == null) return [...mock.mockEducation];
    return (await api.getJson('/api/education') as List)
        .map((e) => Education.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<SocialLink>> socials() async {
    final api = _api;
    if (api == null) return [...mock.mockSocials];
    return (await api.getJson('/api/socials') as List)
        .map((e) => SocialLink.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Raw site settings (public). Empty map in mock mode.
  Future<Map<String, String>> settings() async {
    final api = _api;
    if (api == null) return {};
    final raw = await api.getJson('/api/settings') as Map;
    return raw.map((k, v) => MapEntry('$k', '$v'));
  }

  Future<SiteConfig>? _configCache;

  /// Section visibility + order (cached per app run).
  Future<SiteConfig> siteConfig() {
    if (_api == null) return Future.value(SiteConfig.defaults());
    return _configCache ??= settings().then(SiteConfig.fromSettings);
  }

  void invalidateConfig() => _configCache = null;
}

class PortfolioScope extends InheritedWidget {
  final PortfolioRepository repository;
  const PortfolioScope({super.key, required this.repository, required super.child});

  static PortfolioRepository of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PortfolioScope>()!.repository;

  @override
  bool updateShouldNotify(PortfolioScope oldWidget) => repository != oldWidget.repository;
}
