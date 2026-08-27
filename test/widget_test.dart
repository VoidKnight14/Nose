import 'package:flutter_test/flutter_test.dart';
import 'package:name_none/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MiColegioApp());
    expect(find.text('Nexora'), findsOneWidget);
  });
}
