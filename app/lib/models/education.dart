/// Education model (§11). Section is hideable (§27).
library;

class Education {
  final String id;
  final String institution;
  final String qualification;
  final String course;
  final String startYear;
  final String? endYear;
  final String description;

  const Education({
    required this.id,
    required this.institution,
    required this.qualification,
    required this.course,
    required this.startYear,
    this.endYear,
    required this.description,
  });

  String get rangeLabel => '$startYear — ${endYear ?? 'Present'}';

  factory Education.fromJson(Map<String, dynamic> j) {
    final end = j['endYear'] ?? j['end_year'];
    return Education(
      id: '${j['id'] ?? ''}',
      institution: (j['institution'] ?? '') as String,
      qualification: (j['qualification'] ?? '') as String,
      course: (j['course'] ?? '') as String,
      startYear: '${j['startYear'] ?? j['start_year'] ?? ''}',
      endYear: end == null ? null : '$end',
      description: (j['description'] ?? '') as String,
    );
  }
}
