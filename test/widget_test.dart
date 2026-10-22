import 'package:flutter_test/flutter_test.dart';
import 'package:codemon/main.dart';

void main() {
  testWidgets('Codemon app dapat dibuka', (WidgetTester tester) async {
    await tester.pumpWidget(const CodemonApp());

    await tester.pump();

    expect(find.byType(CodemonApp), findsOneWidget);
  });
}
