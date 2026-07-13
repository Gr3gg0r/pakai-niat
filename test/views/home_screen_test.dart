import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pakai_niat/app.dart';
import 'package:pakai_niat/models/habit.dart';
import 'package:pakai_niat/models/task.dart';
import 'package:pakai_niat/providers/catalog_providers.dart';

void main() {
  testWidgets('shows empty state when nothing is due', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([])),
          habitsProvider.overrideWith((ref) => Stream.value([])),
          ideasProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const PakaiNiatApp(showSplash: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Nothing due right now.'), findsOneWidget);
    expect(find.text('Tap + to capture a task or habit.'), findsOneWidget);
  });

  testWidgets('shows a due habit in Today view', (tester) async {
    final habit = Habit()
      ..title = 'Skin care'
      ..frequency = 'daily'
      ..interval = 1
      ..streakCount = 0
      ..createdAt = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([])),
          habitsProvider.overrideWith((ref) => Stream.value([habit])),
          ideasProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const PakaiNiatApp(showSplash: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Skin care'), findsOneWidget);
  });

  testWidgets('shows a pending task in Today view', (tester) async {
    final task = Task()
      ..title = 'Study Rust'
      ..status = 'pending'
      ..createdAt = DateTime.now();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([task])),
          habitsProvider.overrideWith((ref) => Stream.value([])),
          ideasProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const PakaiNiatApp(showSplash: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Study Rust'), findsOneWidget);
  });
}
