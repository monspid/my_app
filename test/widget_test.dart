import 'package:flutter_test/flutter_test.dart';
import 'package:my_app/app.dart';

void main() {
  testWidgets('App builds', (WidgetTester tester) async {
    await tester.pumpWidget(const MessengerApp());
    expect(find.byType(MessengerApp), findsOneWidget);
  });
}