import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:pakai_niat/models/habit.dart';
import 'package:pakai_niat/models/idea.dart';
import 'package:pakai_niat/models/inbox_capture.dart';
import 'package:pakai_niat/models/task.dart';

import '../test_helper.dart';

void main() {
  late Isar isar;

  setUp(() async {
    await Isar.initializeIsarCore(download: true);
    isar = await openTestIsar();
  });

  tearDown(() async {
    await closeTestIsar(isar);
  });

  test('creates and reads a task', () async {
    final task = Task()
      ..title = 'Study Rust'
      ..status = 'pending'
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });

    final fetched = await isar.tasks.get(task.id);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Study Rust');
    expect(fetched.status, 'pending');
  });

  test('creates and reads a habit', () async {
    final habit = Habit()
      ..title = 'Skin care'
      ..frequency = 'everyNDays'
      ..interval = 2
      ..streakCount = 0
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.habits.put(habit);
    });

    final fetched = await isar.habits.get(habit.id);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Skin care');
    expect(fetched.interval, 2);
  });

  test('creates and reads an idea', () async {
    final idea = Idea()
      ..title = 'Quran memorization app'
      ..capturedAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.ideas.put(idea);
    });

    final fetched = await isar.ideas.get(idea.id);
    expect(fetched, isNotNull);
    expect(fetched!.title, 'Quran memorization app');
  });

  test('creates and reads an inbox capture', () async {
    final capture = InboxCapture()
      ..rawText = 'Call plumber next week'
      ..status = 'pending'
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.inboxCaptures.put(capture);
    });

    final fetched = await isar.inboxCaptures.get(capture.id);
    expect(fetched, isNotNull);
    expect(fetched!.rawText, 'Call plumber next week');
  });

  test('updates task status', () async {
    final task = Task()
      ..title = 'Buy groceries'
      ..status = 'pending'
      ..createdAt = DateTime.now();

    await isar.writeTxn(() async {
      await isar.tasks.put(task);
    });

    await isar.writeTxn(() async {
      task.status = 'done';
      await isar.tasks.put(task);
    });

    final fetched = await isar.tasks.get(task.id);
    expect(fetched!.status, 'done');
  });
}
