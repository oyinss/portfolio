import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:portfolio_app/core/api/admin_repository.dart';
import 'package:portfolio_app/core/api/api_client.dart';
import 'package:portfolio_app/core/api/auth_service.dart';
import 'package:portfolio_app/core/config/site_config.dart';
import 'package:portfolio_app/core/data/mock_portfolio.dart';
import 'package:portfolio_app/core/theme/accent_theme.dart';
import 'package:portfolio_app/core/theme/app_theme.dart';
import 'package:portfolio_app/models/experience.dart';
import 'package:portfolio_app/models/project.dart';
import 'package:portfolio_app/models/skill.dart';

void main() {
  test('twelve accents resolve to distinct seeds', () {
    final seeds = AccentTheme.values.map((a) => a.seed).toSet();
    expect(seeds.length, 12);
  });

  test('light and dark themes build with tokens', () {
    final light = buildLightTheme(AccentTheme.blue.seed);
    final dark = buildDarkTheme(AccentTheme.blue.seed);
    expect(light.brightness, Brightness.light);
    expect(dark.brightness, Brightness.dark);
  });

  test('published projects exclude drafts and stay ordered', () {
    final slugs = publishedProjects.map((p) => p.slug).toList();
    expect(slugs, isNot(contains('weather-app-concept')));
    final orders = publishedProjects.map((p) => p.displayOrder).toList();
    expect(orders, orderedEquals([...orders]..sort()));
  });

  test('project slugs are unique and featured resolve', () {
    final slugs = mockProjects.map((p) => p.slug).toSet();
    expect(slugs.length, mockProjects.length);
    expect(featuredProjects, isNotEmpty);
    expect(projectBySlug('loan-management-system')?.title, 'Loan Management System');
    expect(projectBySlug('no-such-slug'), isNull);
    expect(projectBySlug('weather-app-concept'), isNull); // draft: not public
  });

  test('fromJson parses live API shapes (camelCase + int flags)', () {
    final project = Project.fromJson({
      'id': 'p1',
      'title': 'Loan Management System',
      'slug': 'loan-management-system',
      'shortDescription': 'Short',
      'description': 'Full',
      'imageUrl': null,
      'liveUrl': 'https://example.com',
      'githubUrl': null,
      'technologies': ['Flutter'],
      'type': 'Web App',
      'featured': 1,
      'status': 'published',
      'displayOrder': 1,
      'dateLabel': '2025',
      'problem': 'P',
      'solution': 'S',
      'features': ['F1'],
    });
    expect(project.published, isTrue);
    expect(project.featured, isTrue);
    expect(project.technologies, ['Flutter']);

    final skill = Skill.fromJson({
      'id': 's1',
      'name': 'Flutter',
      'proficiency': 'advanced',
      'category': 'Mobile',
      'display_order': 1,
    });
    expect(skill.proficiency, Proficiency.advanced);
    expect(skill.displayOrder, 1);

    final exp = Experience.fromJson({
      'id': 'e1',
      'company': 'NovaTech',
      'role': 'Dev',
      'location': 'Lagos',
      'start_date': '2024',
      'end_date': null,
      'current': 1,
      'description': 'D',
      'technologies': ['Flutter'],
      'display_order': 1,
    });
    expect(exp.current, isTrue);
    expect(exp.rangeLabel, '2024 — Present');
  });

  test('AuthService login persists token, logout clears it', () async {
    SharedPreferences.setMockInitialValues({});
    final api = ApiClient(
      baseUrl: 'https://example.com',
      httpClient: MockClient((req) async {
        if (req.url.path == '/api/auth/login') {
          final body = req.body;
          if (body.contains('good')) {
            return http.Response('{"token":"tok123","email":"a@b.c"}', 200);
          }
          return http.Response('{"error":"invalid credentials"}', 401);
        }
        return http.Response('not found', 404);
      }),
    );
    final auth = await AuthService.load(api: api);
    expect(auth.isAuthed, isFalse);

    await auth.login('a@b.c', 'good-password');
    expect(auth.isAuthed, isTrue);
    expect(auth.email, 'a@b.c');

    await auth.logout();
    expect(auth.isAuthed, isFalse);

    expect(
      () => auth.login('a@b.c', 'bad'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
  });

  test('AdminRepository creates projects and surfaces 401s', () async {
    SharedPreferences.setMockInitialValues({});
    final mock = MockClient((req) async {
      if (req.url.path == '/api/auth/login') {
        return http.Response('{"token":"admintok","email":"a@b.c"}', 200);
      }
      if (req.url.path == '/api/projects' && req.method == 'POST') {
        return http.Response('{"id":"np1","title":"New","slug":"new"}', 201);
      }
      return http.Response('{"error":"unauthorized"}', 401);
    });
    final api = ApiClient(baseUrl: 'https://example.com', httpClient: mock);
    final auth = await AuthService.load(api: api);
    await auth.login('a@b.c', 'good-password');
    final admin = AdminRepository(auth: auth, baseUrl: 'https://example.com', httpClient: mock);
    final created = await admin.saveProject({'title': 'New'});
    expect(created['slug'], 'new');
    expect(
      () => admin.get('/api/admin/projects'),
      throwsA(isA<ApiException>().having((e) => e.statusCode, 'status', 401)),
    );
  });

  test('SiteConfig parses visibility and order with safe defaults', () {
    final defaults = SiteConfig.fromSettings({});
    expect(defaults.isVisible('education'), isTrue);
    expect(defaults.order.first, 'home');

    final custom = SiteConfig.fromSettings({
      'sections': '{"education":false}',
      'section_order': '["contact","home"]',
    });
    expect(custom.isVisible('education'), isFalse);
    expect(custom.isVisible('home'), isTrue);
    expect(custom.order.take(2).toList(), ['contact', 'home']);
    expect(sectionForPath('/projects/some-slug'), 'projects');
    expect(sectionForPath('/admin'), 'home');
  });
}
