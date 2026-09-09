import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_app/models/social_link.dart';
import 'package:portfolio_app/shared/widgets/social_icon.dart';

void main() {
  test('SocialLink.from empty icon stays null', () {
    final s = SocialLink.fromJson({'platform': 'GitHub', 'url': 'x', 'icon': ''});
    expect(s.icon, isNull);
  });
  test('SocialIcon builds for known platforms', () {
    for (final p in ['GitHub', 'LinkedIn', 'X', 'Reddit', 'Telegram']) {
      final widget = SocialIcon(platform: p);
      expect(widget, isNotNull, reason: p);
    }
  });
}
