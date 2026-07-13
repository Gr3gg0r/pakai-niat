import 'package:isar/isar.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/idea.dart';
import '../models/inbox_capture.dart';
import '../models/task.dart';
import 'capture_draft.dart';
import 'catalog_operation.dart';

class CatalogService {
  CatalogService(this._isar);

  /// Constructor for widget tests that fully stub the service — no Isar
  /// instance is needed (or available, e.g. in CI where the platform
  /// IsarCore library is not present).
  CatalogService.test();

  late final Isar _isar;

  Future<void> commitOperations(List<CatalogOperation> operations) async {
    await _isar.writeTxn(() async {
      for (final operation in operations) {
        switch (operation) {
          case CreateOperation(:final draft):
            await _createDraft(draft);
          case UpdateOperation(:final targetType, :final targetTitle):
            await _updateTarget(targetType, targetTitle, operation);
          case DeleteOperation(:final targetType, :final targetTitle):
            await _deleteTarget(targetType, targetTitle);
        }
      }
    });
  }

  Future<void> commitDraft(CaptureDraft draft) async {
    await commitOperations([CreateOperation(draft)]);
  }

  Future<void> commitDrafts(List<CaptureDraft> drafts) async {
    await commitOperations(drafts.map(CreateOperation.new).toList());
  }

  Future<void> _createDraft(CaptureDraft draft) async {
    if (draft.isTask) {
      final task = Task()
        ..title = draft.title
        ..dueDateTime = draft.dueDateTime
        ..priority = draft.priority
        ..status = 'pending'
        ..createdAt = DateTime.now();
      await _isar.tasks.put(task);
    } else if (draft.isHabit) {
      final habit = Habit()
        ..title = draft.title
        ..frequency = draft.frequency ?? 'daily'
        ..interval = draft.interval ?? 1
        ..dueTime = draft.dueTime
        ..streakCount = 0
        ..createdAt = DateTime.now();
      await _isar.habits.put(habit);
    } else {
      final idea = Idea()
        ..title = draft.title
        ..description = draft.description
        ..capturedAt = DateTime.now();
      await _isar.ideas.put(idea);
    }
  }

  Future<void> _updateTarget(
    String targetType,
    String targetTitle,
    UpdateOperation operation,
  ) async {
    switch (targetType) {
      case 'task':
        final task = await _findTask(targetTitle);
        if (operation.newTitle != null) task.title = operation.newTitle!;
        if (operation.dueDateTime != null) {
          task.dueDateTime = operation.dueDateTime;
        }
        if (operation.priority != null) task.priority = operation.priority;
        if (operation.markDone == true) task.status = 'done';
        await _isar.tasks.put(task);
      case 'habit':
        final habit = await _findHabit(targetTitle);
        if (operation.newTitle != null) habit.title = operation.newTitle!;
        if (operation.frequency != null) {
          habit.frequency = operation.frequency!;
        }
        if (operation.interval != null) habit.interval = operation.interval!;
        if (operation.dueTime != null) habit.dueTime = operation.dueTime;
        if (operation.markDone == true) {
          await _recordHabitDone(habit);
        }
        await _isar.habits.put(habit);
      case 'idea':
        final idea = await _findIdea(targetTitle);
        if (operation.newTitle != null) idea.title = operation.newTitle!;
        if (operation.description != null) {
          idea.description = operation.description;
        }
        await _isar.ideas.put(idea);
      default:
        throw StateError('Unknown target type: $targetType');
    }
  }

  Future<void> _deleteTarget(String targetType, String targetTitle) async {
    switch (targetType) {
      case 'task':
        final task = await _findTask(targetTitle);
        await _isar.tasks.delete(task.id);
      case 'habit':
        final habit = await _findHabit(targetTitle);
        await _isar.habits.delete(habit.id);
      case 'idea':
        final idea = await _findIdea(targetTitle);
        await _isar.ideas.delete(idea.id);
      default:
        throw StateError('Unknown target type: $targetType');
    }
  }

  Future<Task> _findTask(String title) async {
    final tasks = await _isar.tasks.where().findAll();
    final match = _bestMatch(tasks, title, (t) => t.title);
    if (match == null) throw StateError('No task found matching "$title"');
    return match;
  }

  Future<Habit> _findHabit(String title) async {
    final habits = await _isar.habits.where().findAll();
    final match = _bestMatch(habits, title, (h) => h.title);
    if (match == null) throw StateError('No habit found matching "$title"');
    return match;
  }

  Future<Idea> _findIdea(String title) async {
    final ideas = await _isar.ideas.where().findAll();
    final match = _bestMatch(ideas, title, (i) => i.title);
    if (match == null) throw StateError('No idea found matching "$title"');
    return match;
  }

  T? _bestMatch<T>(List<T> items, String query, String Function(T) getTitle) {
    final lowerQuery = query.toLowerCase();
    T? partialMatch;
    for (final item in items) {
      final title = getTitle(item).toLowerCase();
      if (title == lowerQuery) return item;
      if (partialMatch == null && title.contains(lowerQuery)) {
        partialMatch = item;
      }
    }
    return partialMatch;
  }

  Future<void> markTaskDone(Task task) async {
    await _isar.writeTxn(() async {
      task.status = 'done';
      await _isar.tasks.put(task);
    });
  }

  Future<void> markHabitDone(Habit habit) async {
    await _isar.writeTxn(() async {
      await _recordHabitDone(habit);
      await _isar.habits.put(habit);
    });
  }

  Future<void> markHabitMissed(Habit habit, {DateTime? expectedDate}) async {
    await _isar.writeTxn(() async {
      await _recordHabitMissed(habit, expectedDate ?? _today());
      await _isar.habits.put(habit);
    });
  }

  /// Reverses [markTaskDone], returning the task to the Today list.
  Future<void> unmarkTaskDone(Task task) async {
    await _isar.writeTxn(() async {
      task.status = 'pending';
      await _isar.tasks.put(task);
    });
  }

  /// Reverses [markHabitDone] for today: removes today's 'done' log, rolls
  /// back the streak increment, and restores [Habit.lastCompletedAt] from
  /// the most recent remaining 'done' log (or clears it when none remain).
  Future<void> unmarkHabitDone(Habit habit) async {
    await _isar.writeTxn(() async {
      final today = _today();
      final log = await _isar.habitLogs
          .where()
          .filter()
          .habitIdEqualTo(habit.id)
          .expectedDateEqualTo(today)
          .statusEqualTo('done')
          .findFirst();
      if (log == null) return;
      await _isar.habitLogs.delete(log.id);
      if (habit.streakCount > 0) habit.streakCount -= 1;
      final lastDone = await _isar.habitLogs
          .where()
          .filter()
          .habitIdEqualTo(habit.id)
          .statusEqualTo('done')
          .sortByRecordedAtDesc()
          .findFirst();
      habit.lastCompletedAt = lastDone?.recordedAt;
      await _isar.habits.put(habit);
    });
  }

  /// Reverses [markHabitMissed] for today by deleting today's 'missed' log.
  /// The streak is untouched: marking a habit missed never changes it.
  Future<void> unmarkHabitMissed(Habit habit) async {
    await _isar.writeTxn(() async {
      final today = _today();
      final log = await _isar.habitLogs
          .where()
          .filter()
          .habitIdEqualTo(habit.id)
          .expectedDateEqualTo(today)
          .statusEqualTo('missed')
          .findFirst();
      if (log == null) return;
      await _isar.habitLogs.delete(log.id);
    });
  }

  /// Records a successful completion for the given habit on today's date.
  /// Idempotent: if already marked done today, the streak is not incremented
  /// again. Must be called inside an Isar write transaction.
  Future<void> _recordHabitDone(Habit habit) async {
    final today = _today();
    final alreadyDone = await _isar.habitLogs
        .where()
        .filter()
        .habitIdEqualTo(habit.id)
        .expectedDateEqualTo(today)
        .statusEqualTo('done')
        .findFirst();
    if (alreadyDone == null) {
      habit.streakCount += 1;
    }
    habit.lastCompletedAt = DateTime.now();
    await _upsertHabitLog(habit.id, today, 'done');
  }

  /// Records a miss for the given habit on [expectedDate].
  /// Must be called inside an Isar write transaction.
  Future<void> _recordHabitMissed(Habit habit, DateTime expectedDate) async {
    await _upsertHabitLog(habit.id, expectedDate, 'missed');
  }

  Future<void> _upsertHabitLog(
    int habitId,
    DateTime expectedDate,
    String status,
  ) async {
    final day = DateTime(expectedDate.year, expectedDate.month, expectedDate.day);
    final existing = await _isar.habitLogs
        .where()
        .filter()
        .habitIdEqualTo(habitId)
        .expectedDateEqualTo(day)
        .findFirst();

    if (existing != null) {
      existing.status = status;
      existing.recordedAt = DateTime.now();
      await _isar.habitLogs.put(existing);
    } else {
      final log = HabitLog()
        ..habitId = habitId
        ..expectedDate = day
        ..status = status
        ..recordedAt = DateTime.now();
      await _isar.habitLogs.put(log);
    }
  }

  /// Scans all habits and creates 'missed' logs for any expected occurrence
  /// that has passed without a 'done' log. Call this when the app launches
  /// or at the end of the day to keep the habit history accurate.
  Future<void> syncMissedLogs() async {
    await _isar.writeTxn(() async {
      final habits = await _isar.habits.where().findAll();
      for (final habit in habits) {
        final expectedDates = _expectedDates(habit, _today());
        for (final day in expectedDates) {
          final doneLog = await _isar.habitLogs
              .where()
              .filter()
              .habitIdEqualTo(habit.id)
              .expectedDateEqualTo(day)
              .statusEqualTo('done')
              .findFirst();
          if (doneLog != null) continue;

          final missedLog = await _isar.habitLogs
              .where()
              .filter()
              .habitIdEqualTo(habit.id)
              .expectedDateEqualTo(day)
              .statusEqualTo('missed')
              .findFirst();
          if (missedLog != null) continue;

          await _recordHabitMissed(habit, day);
        }
      }
    });
  }

  /// Returns the expected occurrence dates for [habit] from the day after its
  /// last completion (or creation) up to [upToDate].
  List<DateTime> _expectedDates(Habit habit, DateTime upToDate) {
    final intervalDays = habit.frequency == 'weekly' ? 7 : habit.interval;
    final anchor = habit.lastCompletedAt ?? habit.createdAt;
    final anchorDate = DateTime(anchor.year, anchor.month, anchor.day);
    final upTo = DateTime(upToDate.year, upToDate.month, upToDate.day);

    final dates = <DateTime>[];
    var current = anchorDate.add(Duration(days: intervalDays));
    while (!current.isAfter(upTo)) {
      dates.add(current);
      current = current.add(Duration(days: intervalDays));
    }
    return dates;
  }

  DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  Stream<List<Task>> watchTasks() async* {
    yield await _isar.tasks.where().findAll();
    yield* _isar.tasks.where().watch();
  }

  Stream<List<Habit>> watchHabits() async* {
    yield await _isar.habits.where().findAll();
    yield* _isar.habits.where().watch();
  }

  Stream<List<Idea>> watchIdeas() async* {
    yield await _isar.ideas.where().findAll();
    yield* _isar.ideas.where().watch();
  }

  Stream<List<HabitLog>> watchHabitLogs() async* {
    yield await _isar.habitLogs.where().findAll();
    yield* _isar.habitLogs.where().watch();
  }

  Future<void> saveRawCapture(String rawText) async {
    final capture = InboxCapture()
      ..rawText = rawText
      ..status = 'pending'
      ..createdAt = DateTime.now();
    await _isar.writeTxn(() async {
      await _isar.inboxCaptures.put(capture);
    });
  }
}

/// Returns a copy of [tasks] ordered for the Today view: priority
/// (high → medium → low → none), then due date ascending (tasks without a
/// due date last), then creation time ascending. Tasks that compare equal
/// on all three keys fall back to insertion order (Isar id).
List<Task> sortTasksForToday(List<Task> tasks) {
  final sorted = List<Task>.of(tasks);
  sorted.sort((a, b) {
    final byPriority = _priorityRank(a.priority).compareTo(
      _priorityRank(b.priority),
    );
    if (byPriority != 0) return byPriority;
    final byDue = _compareNullableDateTime(a.dueDateTime, b.dueDateTime);
    if (byDue != 0) return byDue;
    final byCreated = a.createdAt.compareTo(b.createdAt);
    if (byCreated != 0) return byCreated;
    return a.id.compareTo(b.id);
  });
  return sorted;
}

int _priorityRank(String? priority) {
  switch (priority?.toLowerCase()) {
    case 'high':
      return 0;
    case 'medium':
      return 1;
    case 'low':
      return 2;
    default:
      return 3;
  }
}

/// Ascending comparison with nulls last.
int _compareNullableDateTime(DateTime? a, DateTime? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  return a.compareTo(b);
}
