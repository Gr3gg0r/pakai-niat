import 'package:isar/isar.dart';

part 'habit_log.g.dart';

/// A record of whether a specific expected occurrence of a habit was
/// completed or missed.
@Collection()
class HabitLog {
  Id id = Isar.autoIncrement;

  /// The Isar id of the parent habit.
  late int habitId;

  /// The date (midnight) on which the habit was expected.
  late DateTime expectedDate;

  /// Status of this occurrence: 'done' or 'missed'.
  late String status;

  /// When the user (or the app) recorded this result.
  late DateTime recordedAt;

  /// Optional note, e.g. why it was missed.
  String? note;
}
