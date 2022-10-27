import 'package:flutter_test/flutter_test.dart';
import 'package:pc_calc/app/app.dart';
import 'package:pc_calc/counter/counter.dart';

void main() {
  group('App', () {
    testWidgets('renders CounterPage', (tester) async {
      await tester.pumpWidget(const App());
      expect(find.byType(CounterPage), findsOneWidget);
    });
  });
}
