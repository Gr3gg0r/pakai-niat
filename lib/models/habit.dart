import 'package:isar/isar.dart';

part 'habit.g.dart';

@Collection()
class Habit {
  Id id = Isar.autoIncrement;

  late String title;

  /// daily | everyNDays | weekly
  late String frequency;

  /// For everyNDays: 2 means every 2 days.
  int interval = 1;

  /// Time of day the habit is due. Only the time component is used.
  DateTime? dueTime;

  /// Streak count. Incremented on completion, optionally reset on miss.
  int streakCount = 0;

  DateTime? lastCompletedAt;

  late DateTime createdAt;
}
