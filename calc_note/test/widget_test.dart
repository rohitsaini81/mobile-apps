import 'package:calc_note/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CalcNote-like UI renders', (WidgetTester tester) async {
    await tester.pumpWidget(const CalcNoteApp());

    expect(find.text('CalcNote'), findsOneWidget);
    expect(find.text('Notepad Calculator'), findsOneWidget);
    expect(find.text('sin('), findsNothing);
    expect(find.text('='), findsOneWidget);
    expect(find.text('⌫'), findsOneWidget);
  });
}
