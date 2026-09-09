/// Project model (§7–§8, §33). `status` drives draft visibility (§30).
library;

enum ProjectStatus { draft, published }

ProjectStatus projectStatusFrom(String? raw) =>
    raw == 'published' ? ProjectStatus.published : ProjectStatus.draft;

class Project {
  final String id;
  final String title;
  final String slug;
  final String shortDescription;
  final String description;
  final String? liveUrl;
  final String? githubUrl;
  final List<String> technologies;
  final String type;
  final bool featured;
  final ProjectStatus status;
  final int displayOrder;
  final String dateLabel;
  final String problem;
  final String solution;
  final List<String> features;

  const Project({
    required this.id,
    required this.title,
    required this.slug,
    required this.shortDescription,
    required this.description,
    this.liveUrl,
    this.githubUrl,
    required this.technologies,
    required this.type,
    required this.featured,
    required this.status,
    required this.displayOrder,
    required this.dateLabel,
    required this.problem,
    required this.solution,
    required this.features,
  });

  bool get published => status == ProjectStatus.published;

  static String? _str(Map<String, dynamic> j, String camel, String snake) {
    final v = j[camel] ?? j[snake];
    return v == null ? null : '$v';
  }

  factory Project.fromJson(Map<String, dynamic> j) {
    final featured = j['featured'];
    final order = j['displayOrder'] ?? j['display_order'] ?? 0;
    return Project(
      id: '${j['id'] ?? ''}',
      title: (j['title'] ?? '') as String,
      slug: (j['slug'] ?? '') as String,
      shortDescription: _str(j, 'shortDescription', 'short_description') ?? '',
      description: (j['description'] ?? '') as String,
      liveUrl: _str(j, 'liveUrl', 'live_url'),
      githubUrl: _str(j, 'githubUrl', 'github_url'),
      technologies: ((j['technologies'] ?? []) as List).map((e) => '$e').toList(),
      type: (j['type'] ?? '') as String,
      featured: featured is bool ? featured : (featured is num ? featured != 0 : false),
      status: projectStatusFrom(j['status'] as String?),
      displayOrder: order is num ? order.toInt() : 0,
      dateLabel: _str(j, 'dateLabel', 'date_label') ?? '',
      problem: (j['problem'] ?? '') as String,
      solution: (j['solution'] ?? '') as String,
      features: ((j['features'] ?? []) as List).map((e) => '$e').toList(),
    );
  }
}
