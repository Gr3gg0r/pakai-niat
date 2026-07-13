import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:pakai_niat/app.dart';
import 'package:pakai_niat/models/habit.dart';
import 'package:pakai_niat/models/habit_log.dart';
import 'package:pakai_niat/models/idea.dart';
import 'package:pakai_niat/models/task.dart';
import 'package:pakai_niat/providers/catalog_providers.dart';
import 'package:pakai_niat/services/catalog_service.dart';

import '../test_helper.dart';

/// In-memory [CatalogService] for widget tests.
///
/// Real Isar streams never deliver inside the fake-async zone that
/// testWidgets installs (its FFI completions arrive on the real event
/// loop), so this fake drives the UI through broadcast controllers, whose
/// emissions are plain microtasks. The real persistence logic — including
/// the undo reversals — is covered against a real Isar instance in
/// test/services/catalog_service_test.dart.
class _FakeCatalogService extends CatalogService {
  _FakeCatalogService(super.isar);

  final _tasksController = StreamController<List<Task>>.broadcast();
  final _habitsController = StreamController<List<Habit>>.broadcast();
  final _logsController = StreamController<List<HabitLog>>.broadcast();

  List<Task> tasks = [];
  List<Habit> habits = [];
  List<HabitLog> logs = [];

  void dispose() {
    _tasksController.close();
    _habitsController.close();
    _logsController.close();
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  @override
  Stream<List<Task>> watchTasks() async* {
    yield tasks;
    yield* _tasksController.stream;
  }

  @override
  Stream<List<Habit>> watchHabits() async* {
    yield habits;
    yield* _habitsController.stream;
  }

  @override
  Stream<List<HabitLog>> watchHabitLogs() async* {
    yield logs;
    yield* _logsController.stream;
  }

  @override
  Future<void> syncMissedLogs() async {}

  @override
  Future<void> markTaskDone(Task task) async {
    task.status = 'done';
    _tasksController.add(tasks);
  }

  @override
  Future<void> unmarkTaskDone(Task task) async {
    task.status = 'pending';
    _tasksController.add(tasks);
  }

  @override
  Future<void> markHabitDone(Habit habit) async {
    habit.streakCount += 1;
    habit.lastCompletedAt = DateTime.now();
    logs = [
      ...logs,
      HabitLog()
        ..habitId = habit.id
        ..expectedDate = _today()
        ..status = 'done'
        ..recordedAt = DateTime.now(),
    ];
    _habitsController.add(habits);
    _logsController.add(logs);
  }

  @override
  Future<void> unmarkHabitDone(Habit habit) async {
    if (habit.streakCount > 0) habit.streakCount -= 1;
    habit.lastCompletedAt = null;
    logs = logs.where((l) => l.habitId != habit.id).toList();
    _habitsController.add(habits);
    _logsController.add(logs);
  }

  @override
  Future<void> markHabitMissed(Habit habit, {DateTime? expectedDate}) async {
    logs = [
      ...logs,
      HabitLog()
        ..habitId = habit.id
        ..expectedDate = expectedDate ?? _today()
        ..status = 'missed'
        ..recordedAt = DateTime.now(),
    ];
    _logsController.add(logs);
  }

  @override
  Future<void> unmarkHabitMissed(Habit habit) async {
    logs = logs.where((l) => l.habitId != habit.id).toList();
    _logsController.add(logs);
  }
}

void main() {
  late Isar isar;
  late _FakeCatalogService service;

  setUp(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await openTestIsar();
    service = _FakeCatalogService(isar);
  });

  tearDown(() async {
    service.dispose();
    await closeTestIsar(isar);
  });

  Task task(String title) => Task()
    ..title = title
    ..status = 'pending'
    ..createdAt = DateTime.now();

  Habit habit(String title) => Habit()
    ..title = title
    ..frequency = 'daily'
    ..interval = 1
    ..streakCount = 0
    ..createdAt = DateTime.now();

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          catalogServiceProvider.overrideWith((ref) => Future.value(service)),
          tasksProvider.overrideWith((ref) => service.watchTasks()),
          habitsProvider.overrideWith((ref) => service.watchHabits()),
          habitLogsProvider.overrideWith((ref) => service.watchHabitLogs()),
          ideasProvider.overrideWith((ref) => Stream.value(<Idea>[])),
        ],
        child: const PakaiNiatApp(showSplash: false),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> flushSnackBar(WidgetTester tester) async {
    // Let any remaining snackbar display timer expire so no timer leaks
    // past the end of the test.
    await tester.pump(const Duration(seconds: 5));
    await tester.pumpAndSettle();
  }

  testWidgets('marking a task done shows a snackbar whose Undo restores it',
      (tester) async {
    service.tasks = [task('Study Rust')];
    await pumpApp(tester);
    expect(find.text('Study Rust'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_circle_outline_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Study Rust'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Study Rust'), findsOneWidget);
    await flushSnackBar(tester);
  });

  testWidgets('marking a habit done shows a snackbar whose Undo restores it',
      (tester) async {
    service.habits = [habit('Skin care')];
    await pumpApp(tester);
    expect(find.text('Skin care'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.check_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Skin care'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Skin care'), findsOneWidget);
    expect(find.text('Streak: 0'), findsOneWidget);
    await flushSnackBar(tester);
  });

  testWidgets('marking a habit missed shows a snackbar whose Undo restores it',
      (tester) async {
    service.habits = [habit('Skin care')];
    await pumpApp(tester);
    expect(find.text('Skin care'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Skin care'), findsNothing);
    expect(find.text('Undo'), findsOneWidget);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();

    expect(find.text('Skin care'), findsOneWidget);
    await flushSnackBar(tester);
  });
}
