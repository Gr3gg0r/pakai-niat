import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pakai_niat/app.dart';
import 'package:pakai_niat/providers/catalog_providers.dart';
import 'package:pakai_niat/views/home_screen.dart';
import 'package:pakai_niat/views/splash_screen.dart';

void main() {
  testWidgets('PakaiNiatApp starts on SplashScreen and navigates to HomeScreen', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([])),
          habitsProvider.overrideWith((ref) => Stream.value([])),
          ideasProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const PakaiNiatApp(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Pakai Niat'), findsOneWidget);
    expect(find.text('Say it. Mean it. Do it.'), findsOneWidget);

    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
