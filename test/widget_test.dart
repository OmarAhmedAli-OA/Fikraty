import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail_image_network/mocktail_image_network.dart';
import 'package:fikraty/main.dart';

void main() {
  testWidgets('Fikraty app loads HomeScreen with brand title and feed',
      (WidgetTester tester) async {
    await mockNetworkImages(() async {
      await tester.pumpWidget(const FikratyApp());

      // Verify brand title and role badge in AppBar
      expect(find.text('Fikraty'), findsOneWidget);
      expect(find.text('Entrepreneur'), findsOneWidget);

      // Total mock delays: 150ms + 150ms + 300ms = 600ms
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();

      // Verify trending tags bar loaded
      expect(find.text('Trending'), findsOneWidget);
      expect(find.text('#FinTech'), findsOneWidget);
      expect(find.text('Sarah Al-Mansouri'), findsOneWidget);
    });
  });
}
