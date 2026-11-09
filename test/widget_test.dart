import 'package:flutter_test/flutter_test.dart';
import 'package:currency/main.dart';

void main() {
  testWidgets('shows the cash counter and note denominations', (tester) async {
    await tester.pumpWidget(const CurrencyApp());

    expect(find.text('Quick cash counter'), findsOneWidget);
    expect(find.text('Count your notes'), findsOneWidget);
    expect(find.text('₹500 note'), findsOneWidget);
    expect(find.text('₹10 note'), findsOneWidget);
  });
}
