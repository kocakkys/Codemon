import 'package:flutter_test/flutter_test.dart';

import 'package:codemon2/main.dart';

void main() {
  testWidgets('Codemon app dapat dibuka', (WidgetTester tester) async {
    await tester.pumpWidget(const App());

    await tester.pump();

    expect(find.byType(App), findsOneWidget);
  });
}
