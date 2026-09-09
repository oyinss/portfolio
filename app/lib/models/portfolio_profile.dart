/// Owner profile (§6, §19).
library;

class PortfolioProfile {
  final String name;
  final String headline;
  final String title;
  final String intro;
  final String bio;
  final String email;
  final String phone;
  final String location;
  final String availability;
  final String yearsExperience;
  final String currentRole;
  final List<String> interests;
  final String? profileImageUrl;
  final String? resumeUrl;

  const PortfolioProfile({
    required this.name,
    required this.headline,
    required this.title,
    required this.intro,
    required this.bio,
    required this.email,
    required this.phone,
    required this.location,
    required this.availability,
    required this.yearsExperience,
    required this.currentRole,
    required this.interests,
    this.profileImageUrl,
    this.resumeUrl,
  });

  factory PortfolioProfile.fromJson(Map<String, dynamic> j) => PortfolioProfile(
        name: (j['name'] ?? '') as String,
        headline: (j['headline'] ?? '') as String,
        title: (j['title'] ?? '') as String,
        intro: (j['intro'] ?? '') as String,
        bio: (j['bio'] ?? '') as String,
        email: (j['email'] ?? '') as String,
        phone: (j['phone'] ?? '') as String,
        location: (j['location'] ?? '') as String,
        availability: (j['availability'] ?? '') as String,
        yearsExperience: (j['yearsExperience'] ?? j['years_experience'] ?? '') as String,
        currentRole: (j['currentRole'] ?? j['current_role'] ?? '') as String,
        interests: ((j['interests'] ?? []) as List).map((e) => '$e').toList(),
        profileImageUrl: (j['profileImageUrl'] ?? j['profile_image_url'])?.toString(),
        resumeUrl: (j['resumeUrl'] ?? j['resume_url'])?.toString(),
      );
}
