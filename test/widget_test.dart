import 'package:flutter_test/flutter_test.dart';
import 'package:seat_vue/app/app.dart';

void main() {
  testWidgets('SeatVue initial launch smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const SeatVueApp());
    await tester.pumpAndSettle();

    // Verify SeatVue app brand and sections render
    expect(find.text('Now Showing'), findsWidgets);
    expect(find.text('Coming Soon'), findsWidgets);
    expect(find.text('FEATURED PREMIERE'), findsWidgets);
  });
}
