/// Skill model (§9, §34).
library;

enum Proficiency { beginner, intermediate, advanced, expert }

extension ProficiencyX on Proficiency {
  String get label => switch (this) {
        Proficiency.beginner => 'Beginner',
        Proficiency.intermediate => 'Intermediate',
        Proficiency.advanced => 'Advanced',
        Proficiency.expert => 'Expert',
      };

  /// 1–4 filled dots for the meter.
  int get level => index + 1;
}

Proficiency proficiencyFrom(String? raw) => Proficiency.values.firstWhere(
      (p) => p.name == (raw ?? '').toLowerCase(),
      orElse: () => Proficiency.intermediate,
    );

class Skill {
  final String id;
  final String name;
  final Proficiency proficiency;
  final String category;
  final int displayOrder;

  const Skill({
    required this.id,
    required this.name,
    required this.proficiency,
    required this.category,
    required this.displayOrder,
  });

  factory Skill.fromJson(Map<String, dynamic> j) {
    final order = j['displayOrder'] ?? j['display_order'] ?? 0;
    return Skill(
      id: '${j['id'] ?? ''}',
      name: (j['name'] ?? '') as String,
      proficiency: proficiencyFrom(j['proficiency'] as String?),
      category: (j['category'] ?? '') as String,
      displayOrder: order is num ? order.toInt() : 0,
    );
  }
}
