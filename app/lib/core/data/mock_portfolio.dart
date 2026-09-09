/// Mock portfolio content. Replaced by the Cloudflare API in Phase 4.
library;

import '../../models/education.dart';
import '../../models/experience.dart';
import '../../models/portfolio_profile.dart';
import '../../models/project.dart';
import '../../models/skill.dart';
import '../../models/social_link.dart';

const mockProfile = PortfolioProfile(
  name: 'John Doe',
  headline: "HELLO, I'M",
  title: 'Flutter & Backend Developer',
  intro: 'I build modern web and mobile applications.',
  bio: "I'm a Flutter developer focused on building high-performance "
      'applications for mobile and web. I work across the stack — from '
      'Flutter frontends to Laravel and PostgreSQL backends — and I care '
      'about fast, maintainable products.',
  email: 'hello@example.com',
  phone: '+234 800 000 0000',
  location: 'Lagos, Nigeria',
  availability: 'Open to opportunities',
  yearsExperience: '3+ Years',
  currentRole: 'Senior Flutter Developer',
  interests: ['Mobile Apps', 'Backend Systems', 'UI Design', 'Open Source'],
);

const mockProjects = [
  Project(
    id: 'p1',
    title: 'Loan Management System',
    slug: 'loan-management-system',
    shortDescription: 'Platform for managing loan applications, repayments and customer accounts.',
    description: 'A full platform for managing loan applications, repayments and '
        'customer accounts, with role-based dashboards for agents and admins.',
    liveUrl: 'https://example.com/loan-app',
    githubUrl: 'https://github.com/example/loan-app',
    technologies: ['Flutter', 'Laravel', 'PostgreSQL'],
    type: 'Web App',
    featured: true,
    status: ProjectStatus.published,
    displayOrder: 1,
    dateLabel: '2025',
    problem: 'Loan officers tracked applications and repayments across spreadsheets, causing errors and delays.',
    solution: 'A single system with application intake, approval workflows, repayment schedules and reporting.',
    features: ['Application intake & approvals', 'Repayment tracking', 'Customer accounts', 'Admin reports'],
  ),
  Project(
    id: 'p2',
    title: 'E-commerce Platform',
    slug: 'ecommerce-platform',
    shortDescription: 'Storefront with cart, checkout and order management.',
    description: 'A complete e-commerce storefront with cart, checkout, payments '
        'and an admin panel for products and orders.',
    liveUrl: 'https://example.com/shop',
    githubUrl: 'https://github.com/example/shop',
    technologies: ['Flutter', 'Firebase', 'Stripe'],
    type: 'Mobile + Web',
    featured: true,
    status: ProjectStatus.published,
    displayOrder: 2,
    dateLabel: '2024',
    problem: 'Small retailers needed an affordable storefront that works on phones and desktops.',
    solution: 'One Flutter codebase shipping to mobile and web with a shared cart and checkout.',
    features: ['Product catalog & search', 'Cart & checkout', 'Order tracking', 'Admin panel'],
  ),
  Project(
    id: 'p3',
    title: 'Portfolio Website',
    slug: 'portfolio-website',
    shortDescription: 'This reusable portfolio platform itself.',
    description: 'The self-hosted, configurable developer portfolio CMS this site '
        'runs on — Flutter frontend, Cloudflare backend.',
    liveUrl: null,
    githubUrl: 'https://github.com/example/portfolio',
    technologies: ['Flutter', 'Cloudflare Workers', 'D1'],
    type: 'Open Source',
    featured: true,
    status: ProjectStatus.published,
    displayOrder: 3,
    dateLabel: '2026',
    problem: 'Developers rebuild their portfolio from scratch every time they learn something new.',
    solution: 'A clone-deploy-configure system: no code edits needed after deployment.',
    features: ['Admin dashboard', 'Theme system', 'Project management', 'R2 file uploads'],
  ),
  Project(
    id: 'p4',
    title: 'Task Tracker API',
    slug: 'task-tracker-api',
    shortDescription: 'REST API for teams with boards and assignments.',
    description: 'A REST API for team task tracking with boards, assignments and activity logs.',
    liveUrl: null,
    githubUrl: 'https://github.com/example/tasks',
    technologies: ['Laravel', 'PostgreSQL', 'Docker'],
    type: 'Backend',
    featured: false,
    status: ProjectStatus.published,
    displayOrder: 4,
    dateLabel: '2024',
    problem: 'Teams needed a simple self-hosted alternative to heavy project tools.',
    solution: 'A clean REST API with token auth that any frontend can consume.',
    features: ['Boards & tasks', 'Assignments', 'Activity log', 'API tokens'],
  ),
  Project(
    id: 'p5',
    title: 'Weather App Concept',
    slug: 'weather-app-concept',
    shortDescription: 'Experimental weather UI — currently a draft.',
    description: 'Design experiment, not published yet.',
    liveUrl: null,
    githubUrl: null,
    technologies: ['Flutter'],
    type: 'Concept',
    featured: false,
    status: ProjectStatus.draft,
    displayOrder: 5,
    dateLabel: '2026',
    problem: '',
    solution: '',
    features: [],
  ),
];

/// Publicly visible projects, ordered (§29–§30).
List<Project> get publishedProjects {
  final list = mockProjects.where((p) => p.published).toList();
  list.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
  return list;
}

List<Project> get featuredProjects =>
    publishedProjects.where((p) => p.featured).toList();

Project? projectBySlug(String slug) {
  for (final p in mockProjects) {
    if (p.slug == slug && p.published) return p;
  }
  return null;
}

const mockSkills = [
  Skill(id: 's1', name: 'Flutter', proficiency: Proficiency.advanced, category: 'Mobile', displayOrder: 1),
  Skill(id: 's2', name: 'Dart', proficiency: Proficiency.advanced, category: 'Languages', displayOrder: 2),
  Skill(id: 's3', name: 'Laravel', proficiency: Proficiency.advanced, category: 'Backend', displayOrder: 3),
  Skill(id: 's4', name: 'PHP', proficiency: Proficiency.advanced, category: 'Languages', displayOrder: 4),
  Skill(id: 's5', name: 'JavaScript', proficiency: Proficiency.intermediate, category: 'Languages', displayOrder: 5),
  Skill(id: 's6', name: 'PostgreSQL', proficiency: Proficiency.intermediate, category: 'Backend', displayOrder: 6),
  Skill(id: 's7', name: 'Firebase', proficiency: Proficiency.intermediate, category: 'Backend', displayOrder: 7),
  Skill(id: 's8', name: 'Cloudflare', proficiency: Proficiency.intermediate, category: 'DevOps', displayOrder: 8),
  Skill(id: 's9', name: 'Git', proficiency: Proficiency.advanced, category: 'Tools', displayOrder: 9),
  Skill(id: 's10', name: 'Docker', proficiency: Proficiency.intermediate, category: 'DevOps', displayOrder: 10),
  Skill(id: 's11', name: 'Figma', proficiency: Proficiency.beginner, category: 'Design', displayOrder: 11),
];

const mockExperience = [
  Experience(
    id: 'e1',
    company: 'NovaTech Solutions',
    role: 'Senior Flutter Developer',
    location: 'Lagos, Nigeria',
    startDate: '2024',
    endDate: null,
    current: true,
    description: 'Built and maintained cross-platform applications for web and mobile.',
    technologies: ['Flutter', 'Firebase', 'Cloudflare'],
    displayOrder: 1,
  ),
  Experience(
    id: 'e2',
    company: 'BrightStack',
    role: 'Backend Developer',
    location: 'Remote',
    startDate: '2022',
    endDate: '2024',
    current: false,
    description: 'Designed REST APIs and database schemas serving mobile clients.',
    technologies: ['Laravel', 'PostgreSQL', 'Docker'],
    displayOrder: 2,
  ),
  Experience(
    id: 'e3',
    company: 'Freelance',
    role: 'Mobile Developer',
    location: 'Remote',
    startDate: '2021',
    endDate: '2022',
    current: false,
    description: 'Shipped apps for small businesses, from storefronts to booking tools.',
    technologies: ['Flutter', 'Firebase'],
    displayOrder: 3,
  ),
];

const mockEducation = [
  Education(
    id: 'ed1',
    institution: 'University of Lagos',
    qualification: 'B.Sc',
    course: 'Computer Science',
    startYear: '2020',
    endYear: '2024',
    description: 'Focused on software engineering and databases.',
  ),
];

const mockSocials = [
  SocialLink(platform: 'GitHub', url: 'https://github.com/example'),
  SocialLink(platform: 'LinkedIn', url: 'https://linkedin.com/in/example'),
  SocialLink(platform: 'X', url: 'https://x.com/example'),
];
