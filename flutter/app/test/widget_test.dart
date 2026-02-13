import 'package:flutter_test/flutter_test.dart';
import 'package:app/main.dart';

void main() {
  testWidgets('App starts', (WidgetTester tester) async {
    await tester.pumpWidget(const RunEarnApp());
    expect(find.byType(RunEarnApp), findsOneWidget);
  });
}
