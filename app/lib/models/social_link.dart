/// Social link model (§13, §37). Only entered links are displayed.
library;

class SocialLink {
  final String platform;
  final String url;
  final String? icon;

  const SocialLink({required this.platform, required this.url, this.icon});

  factory SocialLink.fromJson(Map<String, dynamic> j) {
    final icon = (j['icon'] ?? '') as String?;
    return SocialLink(
      platform: (j['platform'] ?? '') as String,
      url: (j['url'] ?? '') as String,
      icon: icon == null || icon.isEmpty ? null : icon,
    );
  }
}
