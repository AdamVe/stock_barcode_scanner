import 'package:flutter_test/flutter_test.dart';
import 'package:stock_barcode_scanner/main.dart';

void main() {
  testWidgets('initial test', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Initial'), findsOneWidget);
  });
}
