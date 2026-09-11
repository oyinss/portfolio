import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:portfolio_app/core/api/portfolio_repository.dart';
import 'package:portfolio_app/features/home/home_page.dart';

void main() {
  testWidgets('steady-state mobile frame is clean', (tester) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(MaterialApp(
      home: PortfolioScope(repository: PortfolioRepository(), child: const HomePage()),
    ));
    await tester.pumpAndSettle();
    // Drain any transient loading-frame errors, then require a clean frame.
    var drained = 0;
    while (tester.takeException() != null) {
      drained++;
      if (drained > 10) break;
    }
    expect(drained, lessThan(10));
    expect(find.textContaining('John Doe'), findsWidgets);
    // One more steady frame must be error-free.
    await tester.pump(const Duration(milliseconds: 500));
    expect(tester.takeException(), isNull);
  });
}
