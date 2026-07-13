import 'package:flutter_test/flutter_test.dart';
import 'package:isar/isar.dart';

import 'package:pakai_niat/models/habit.dart';
import 'package:pakai_niat/models/habit_log.dart';
import 'package:pakai_niat/models/idea.dart';
import 'package:pakai_niat/models/inbox_capture.dart';
import 'package:pakai_niat/models/task.dart';
import 'package:pakai_niat/services/capture_draft.dart';
import 'package:pakai_niat/services/catalog_operation.dart';
import 'package:pakai_niat/services/catalog_service.dart';

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

  test('commits a task draft', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'task',
      title: 'Study Rust',
    ));

    final tasks = await isar.tasks.where().findAll();
    expect(tasks, hasLength(1));
    expect(tasks.first.title, 'Study Rust');
    expect(tasks.first.status, 'pending');
  });

  test('commits multiple drafts', () async {
    final service = CatalogService(isar);
    await service.commitDrafts([
      const CaptureDraft(type: 'task', title: 'Task 1'),
      const CaptureDraft(type: 'habit', title: 'Habit 1', frequency: 'daily'),
      const CaptureDraft(type: 'idea', title: 'Idea 1'),
    ]);

    expect(await isar.tasks.where().findAll(), hasLength(1));
    expect(await isar.habits.where().findAll(), hasLength(1));
    expect(await isar.ideas.where().findAll(), hasLength(1));
  });

  test('marks a task done', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'Task'));
    final task = (await isar.tasks.where().findAll()).first;

    await service.markTaskDone(task);

    final updated = await isar.tasks.get(task.id);
    expect(updated!.status, 'done');
  });

  test('marks a habit done and increments streak', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'Skin care',
      frequency: 'everyNDays',
      interval: 2,
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.markHabitDone(habit);

    final updated = await isar.habits.get(habit.id);
    expect(updated!.streakCount, 1);
    expect(updated.lastCompletedAt, isNotNull);
  });

  test('emits initial data from watchTasks', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'Task'));

    final tasks = await service.watchTasks().first;
    expect(tasks, hasLength(1));
  });

  test('updates a habit by title', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'gym',
      frequency: 'daily',
      interval: 1,
    ));

    await service.commitOperations([
      UpdateOperation(
        targetType: 'habit',
        targetTitle: 'gym',
        interval: 3,
      ),
    ]);

    final updated = (await isar.habits.where().findAll()).first;
    expect(updated.interval, 3);
  });

  test('marks a habit done via update operation', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'zuhr prayer',
      frequency: 'daily',
    ));

    await service.commitOperations([
      UpdateOperation(
        targetType: 'habit',
        targetTitle: 'zuhr prayer',
        markDone: true,
      ),
    ]);

    final updated = (await isar.habits.where().findAll()).first;
    expect(updated.lastCompletedAt, isNotNull);
    expect(updated.streakCount, 1);
  });

  test('deletes a task by title', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'old task'));

    await service.commitOperations([
      DeleteOperation(targetType: 'task', targetTitle: 'old task'),
    ]);

    expect(await isar.tasks.where().findAll(), isEmpty);
  });

  test('commits a high priority task', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'task',
      title: 'Urgent report',
      priority: 'high',
    ));

    final tasks = await isar.tasks.where().findAll();
    expect(tasks.first.priority, 'high');
  });

  test('records a done log when marking habit done', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'subuh prayer',
      frequency: 'daily',
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.markHabitDone(habit);

    final logs = await isar.habitLogs.where().findAll();
    expect(logs, hasLength(1));
    expect(logs.first.status, 'done');
    expect(logs.first.habitId, habit.id);
  });

  test('records a missed log when marking habit missed', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'subuh prayer',
      frequency: 'daily',
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.markHabitMissed(habit);

    final logs = await isar.habitLogs.where().findAll();
    expect(logs, hasLength(1));
    expect(logs.first.status, 'missed');
    expect(logs.first.habitId, habit.id);
  });

  test('unmarkTaskDone restores a done task to pending', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'Task'));
    final task = (await isar.tasks.where().findAll()).first;

    await service.markTaskDone(task);
    await service.unmarkTaskDone(task);

    final updated = await isar.tasks.get(task.id);
    expect(updated!.status, 'pending');
  });

  test('unmarkHabitDone removes today\'s done log and rolls back the streak',
      () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'Skin care',
      frequency: 'daily',
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.markHabitDone(habit);
    await service.unmarkHabitDone(habit);

    final updated = await isar.habits.get(habit.id);
    expect(updated!.streakCount, 0);
    expect(updated.lastCompletedAt, isNull);
    expect(await isar.habitLogs.where().findAll(), isEmpty);
  });

  test('unmarkHabitDone restores lastCompletedAt from an earlier done log',
      () async {
    final service = CatalogService(isar);
    final earlier = DateTime.now().subtract(const Duration(days: 2));
    final habit = Habit()
      ..title = 'Skin care'
      ..frequency = 'daily'
      ..interval = 1
      ..streakCount = 3
      ..lastCompletedAt = earlier
      ..createdAt = earlier;
    await isar.writeTxn(() async {
      await isar.habits.put(habit);
      final earlierLog = HabitLog()
        ..habitId = habit.id
        ..expectedDate = DateTime(earlier.year, earlier.month, earlier.day)
        ..status = 'done'
        ..recordedAt = earlier;
      await isar.habitLogs.put(earlierLog);
    });

    await service.markHabitDone(habit);
    expect(habit.streakCount, 4);

    await service.unmarkHabitDone(habit);

    final updated = await isar.habits.get(habit.id);
    expect(updated!.streakCount, 3);
    // Isar round-trips DateTime as UTC, so compare instants, not identity.
    expect(updated.lastCompletedAt!.toUtc(), earlier.toUtc());
    final logs = await isar.habitLogs.where().findAll();
    expect(logs, hasLength(1));
    expect(logs.first.status, 'done');
  });

  test('unmarkHabitDone is a no-op when the habit is not done today', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'Skin care',
      frequency: 'daily',
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.unmarkHabitDone(habit);

    final updated = await isar.habits.get(habit.id);
    expect(updated!.streakCount, 0);
    expect(await isar.habitLogs.where().findAll(), isEmpty);
  });

  test('unmarkHabitMissed removes today\'s missed log and keeps the streak',
      () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'Skin care',
      frequency: 'daily',
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.markHabitMissed(habit);
    expect(await isar.habitLogs.where().findAll(), hasLength(1));

    await service.unmarkHabitMissed(habit);

    expect(await isar.habitLogs.where().findAll(), isEmpty);
    final updated = await isar.habits.get(habit.id);
    expect(updated!.streakCount, 0);
  });

  test('syncMissedLogs creates missed logs for overdue habits', () async {
    final service = CatalogService(isar);
    final habit = Habit()
      ..title = 'subuh prayer'
      ..frequency = 'daily'
      ..interval = 1
      ..createdAt = DateTime.now().subtract(const Duration(days: 2))
      ..streakCount = 0;
    await isar.writeTxn(() async => isar.habits.put(habit));

    await service.syncMissedLogs();

    final logs = await isar.habitLogs.where().findAll();
    expect(logs.length, greaterThanOrEqualTo(1));
    expect(logs.any((l) => l.status == 'missed'), true);
  });

  test('update with a nonexistent title throws and writes nothing', () async {
    final service = CatalogService(isar);

    await expectLater(
      service.commitOperations([
        UpdateOperation(
          targetType: 'task',
          targetTitle: 'ghost task',
          newTitle: 'renamed',
        ),
      ]),
      throwsA(isA<StateError>()),
    );

    expect(await isar.tasks.where().findAll(), isEmpty);
  });

  test('delete with a nonexistent title throws and writes nothing', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'keep'));

    await expectLater(
      service.commitOperations([
        DeleteOperation(targetType: 'task', targetTitle: 'ghost task'),
      ]),
      throwsA(isA<StateError>()),
    );

    expect(await isar.tasks.where().findAll(), hasLength(1));
  });

  test('a failed batch rolls back earlier operations in the same commit',
      () async {
    final service = CatalogService(isar);

    await expectLater(
      service.commitOperations([
        CreateOperation(const CaptureDraft(type: 'task', title: 'new task')),
        DeleteOperation(targetType: 'habit', targetTitle: 'ghost habit'),
      ]),
      throwsA(isA<StateError>()),
    );

    // The create happened in the same write transaction as the failing
    // delete, so it must be rolled back too.
    expect(await isar.tasks.where().findAll(), isEmpty);
  });

  test('habit update targeting a task title throws and leaves the task alone',
      () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'laundry'));

    await expectLater(
      service.commitOperations([
        UpdateOperation(
          targetType: 'habit',
          targetTitle: 'laundry',
          markDone: true,
        ),
      ]),
      throwsA(isA<StateError>()),
    );

    final tasks = await isar.tasks.where().findAll();
    expect(tasks, hasLength(1));
    expect(tasks.first.status, 'pending');
    expect(await isar.habitLogs.where().findAll(), isEmpty);
  });

  test('task delete targeting a habit title throws and keeps the habit',
      () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'gym',
      frequency: 'daily',
    ));

    await expectLater(
      service.commitOperations([
        DeleteOperation(targetType: 'task', targetTitle: 'gym'),
      ]),
      throwsA(isA<StateError>()),
    );

    expect(await isar.habits.where().findAll(), hasLength(1));
  });

  test('unknown target type throws for update and delete', () async {
    final service = CatalogService(isar);

    await expectLater(
      service.commitOperations([
        UpdateOperation(
          targetType: 'chore',
          targetTitle: 'gym',
          newTitle: 'gym2',
        ),
      ]),
      throwsA(isA<StateError>()),
    );
    await expectLater(
      service.commitOperations([
        DeleteOperation(targetType: 'chore', targetTitle: 'gym'),
      ]),
      throwsA(isA<StateError>()),
    );
  });

  test('updates task fields by title', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'report'));
    final due = DateTime(2026, 7, 20, 17);

    await service.commitOperations([
      UpdateOperation(
        targetType: 'task',
        targetTitle: 'report',
        newTitle: 'quarterly report',
        dueDateTime: due,
        priority: 'high',
        markDone: true,
      ),
    ]);

    final updated = (await isar.tasks.where().findAll()).first;
    expect(updated.title, 'quarterly report');
    expect(updated.dueDateTime!.toUtc(), due.toUtc());
    expect(updated.priority, 'high');
    expect(updated.status, 'done');
  });

  test('updates an idea by title', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'idea',
      title: 'app idea',
      description: 'vague',
    ));

    await service.commitOperations([
      UpdateOperation(
        targetType: 'idea',
        targetTitle: 'app idea',
        newTitle: 'habit app idea',
        description: 'AI-powered',
      ),
    ]);

    final updated = (await isar.ideas.where().findAll()).first;
    expect(updated.title, 'habit app idea');
    expect(updated.description, 'AI-powered');
  });

  test('deletes a habit and an idea by title', () async {
    final service = CatalogService(isar);
    await service.commitDrafts([
      const CaptureDraft(type: 'habit', title: 'gym', frequency: 'daily'),
      const CaptureDraft(type: 'idea', title: 'old idea'),
    ]);

    await service.commitOperations([
      DeleteOperation(targetType: 'habit', targetTitle: 'gym'),
      DeleteOperation(targetType: 'idea', targetTitle: 'old idea'),
    ]);

    expect(await isar.habits.where().findAll(), isEmpty);
    expect(await isar.ideas.where().findAll(), isEmpty);
  });

  test('unmarkHabitMissed is a no-op when there is no missed log', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'Skin care',
      frequency: 'daily',
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.unmarkHabitMissed(habit);

    final updated = await isar.habits.get(habit.id);
    expect(updated!.streakCount, 0);
    expect(await isar.habitLogs.where().findAll(), isEmpty);
  });

  test('unmarkTaskDone on a pending task is a safe no-op', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(type: 'task', title: 'Task'));
    final task = (await isar.tasks.where().findAll()).first;

    await service.unmarkTaskDone(task);

    final updated = await isar.tasks.get(task.id);
    expect(updated!.status, 'pending');
  });

  test('markHabitDone is idempotent for the same day', () async {
    final service = CatalogService(isar);
    await service.commitDraft(const CaptureDraft(
      type: 'habit',
      title: 'Skin care',
      frequency: 'daily',
    ));
    final habit = (await isar.habits.where().findAll()).first;

    await service.markHabitDone(habit);
    await service.markHabitDone(habit);

    final updated = await isar.habits.get(habit.id);
    expect(updated!.streakCount, 1);
    expect(await isar.habitLogs.where().findAll(), hasLength(1));
  });

  test('emits initial data from the habit, idea, and log watchers', () async {
    final service = CatalogService(isar);
    await service.commitDrafts([
      const CaptureDraft(type: 'habit', title: 'gym', frequency: 'daily'),
      const CaptureDraft(type: 'idea', title: 'idea'),
    ]);

    expect(await service.watchHabits().first, hasLength(1));
    expect(await service.watchIdeas().first, hasLength(1));
    expect(await service.watchHabitLogs().first, isEmpty);
  });

  test('saveRawCapture stores the raw text as pending', () async {
    final service = CatalogService(isar);

    await service.saveRawCapture('gym tomorrow 6am');

    final captures = await isar.inboxCaptures.where().findAll();
    expect(captures, hasLength(1));
    expect(captures.first.rawText, 'gym tomorrow 6am');
    expect(captures.first.status, 'pending');
  });
}
