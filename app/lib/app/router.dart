library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/api/auth_service.dart';
import '../features/about/about_page.dart';
import '../features/admin/appearance/appearance_page.dart';
import '../features/admin/auth/login_page.dart';
import '../features/admin/dashboard/dashboard_page.dart';
import '../features/admin/education/admin_education_page.dart';
import '../features/admin/experience/admin_experience_page.dart';
import '../features/admin/profile/profile_page.dart';
import '../features/admin/projects/admin_projects_page.dart';
import '../features/admin/projects/project_editor_page.dart';
import '../features/admin/settings/settings_page.dart';
import '../features/admin/skills/admin_skills_page.dart';
import '../features/admin/socials/admin_socials_page.dart';
import '../features/contact/contact_page.dart';
import '../features/education/education_page.dart';
import '../features/experience/experience_page.dart';
import '../features/home/home_page.dart';
import '../features/project_detail/project_detail_page.dart';
import '../features/projects/projects_page.dart';
import '../features/skills/skills_page.dart';
import '../shared/layouts/responsive_shell.dart';

/// Public routes (§44). Admin routes are reserved placeholders for Phase 5.
@immutable
class NavItem {
  final String path;
  final String label;
  final IconData icon;
  const NavItem(this.path, this.label, this.icon);
}

const navItems = [
  NavItem('/', 'Home', Icons.home_outlined),
  NavItem('/about', 'About', Icons.person_outline),
  NavItem('/projects', 'Projects', Icons.folder_outlined),
  NavItem('/skills', 'Skills', Icons.code),
  NavItem('/experience', 'Experience', Icons.work_outline),
  NavItem('/education', 'Education', Icons.school_outlined),
  NavItem('/contact', 'Contact', Icons.mail_outline),
];

GoRouter buildRouter({required AuthService auth}) {
  return GoRouter(
    initialLocation: '/',
    refreshListenable: auth,
    redirect: (context, state) {
      final loggedIn = auth.isAuthed;
      final path = state.uri.path;
      final isLogin = path == '/admin/login';
      if (path.startsWith('/admin') && !loggedIn && !isLogin) return '/admin/login';
      if (isLogin && loggedIn) return '/admin';
      return null;
    },
    routes: [
      ShellRoute(
        pageBuilder: (context, state, child) => CustomTransitionPage(
          key: state.pageKey,
          child: ResponsiveShell(location: state.uri.toString(), child: child),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
        routes: [
          GoRoute(path: '/', builder: (c, s) => const HomePage()),
          GoRoute(path: '/about', builder: (c, s) => const AboutPage()),
          GoRoute(path: '/projects', builder: (c, s) => const ProjectsPage()),
          GoRoute(
            path: '/projects/:slug',
            builder: (c, s) =>
                ProjectDetailPage(slug: s.pathParameters['slug'] ?? ''),
          ),
          GoRoute(path: '/skills', builder: (c, s) => const SkillsPage()),
          GoRoute(path: '/experience', builder: (c, s) => const ExperiencePage()),
          GoRoute(path: '/education', builder: (c, s) => const EducationPage()),
          GoRoute(path: '/contact', builder: (c, s) => const ContactPage()),
          GoRoute(
            path: '/admin/login',
            builder: (c, s) => const LoginPage(),
          ),
          GoRoute(
            path: '/admin',
            builder: (c, s) => const DashboardPage(),
          ),
          GoRoute(path: '/admin/profile', builder: (c, s) => const ProfilePage()),
          GoRoute(path: '/admin/projects', builder: (c, s) => const AdminProjectsPage()),
          GoRoute(path: '/admin/projects/new', builder: (c, s) => const ProjectEditorPage()),
          GoRoute(
            path: '/admin/projects/:id/edit',
            builder: (c, s) => ProjectEditorPage(id: s.pathParameters['id']),
          ),
          GoRoute(path: '/admin/skills', builder: (c, s) => const AdminSkillsPage()),
          GoRoute(path: '/admin/experience', builder: (c, s) => const AdminExperiencePage()),
          GoRoute(path: '/admin/education', builder: (c, s) => const AdminEducationPage()),
          GoRoute(path: '/admin/socials', builder: (c, s) => const AdminSocialsPage()),
          GoRoute(path: '/admin/appearance', builder: (c, s) => const AppearancePage()),
          GoRoute(path: '/admin/settings', builder: (c, s) => const SettingsPage()),
        ],
      ),
    ],
  );
}
