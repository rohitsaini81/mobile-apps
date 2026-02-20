import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:app/main.dart';

void main() {
  testWidgets('Tapping a title opens preview page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Trending Now'), findsOneWidget);

    final target = find.byKey(const ValueKey('media-card-Black Sands'));
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -200));
    await tester.pumpAndSettle();
    await tester.tap(target);
    await tester.pumpAndSettle();

    expect(find.text('Episodes & More Like This'), findsOneWidget);
    expect(find.text('Black Sands'), findsWidgets);
  });
}
