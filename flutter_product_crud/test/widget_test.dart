import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_product_crud/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Product Management'), findsOneWidget);
  });
}
