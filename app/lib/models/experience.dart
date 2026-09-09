/// Experience model (§10, §35).
library;

class Experience {
  final String id;
  final String company;
  final String role;
  final String location;
  final String startDate;
  final String? endDate;
  final bool current;
  final String description;
  final List<String> technologies;
  final int displayOrder;

  const Experience({
    required this.id,
    required this.company,
    required this.role,
    required this.location,
    required this.startDate,
    this.endDate,
    required this.current,
    required this.description,
    required this.technologies,
    required this.displayOrder,
  });

  String get rangeLabel => '$startDate — ${current ? 'Present' : (endDate ?? '')}';

  factory Experience.fromJson(Map<String, dynamic> j) {
    final current = j['current'];
    final order = j['displayOrder'] ?? j['display_order'] ?? 0;
    final end = j['endDate'] ?? j['end_date'];
    return Experience(
      id: '${j['id'] ?? ''}',
      company: (j['company'] ?? '') as String,
      role: (j['role'] ?? '') as String,
      location: (j['location'] ?? '') as String,
      startDate: '${j['startDate'] ?? j['start_date'] ?? ''}',
      endDate: end == null ? null : '$end',
      current: current is bool ? current : (current is num ? current != 0 : false),
      description: (j['description'] ?? '') as String,
      technologies: ((j['technologies'] ?? []) as List).map((e) => '$e').toList(),
      displayOrder: order is num ? order.toInt() : 0,
    );
  }
}
