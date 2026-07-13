import 'package:isar/isar.dart';

part 'task.g.dart';

@Collection()
class Task {
  Id id = Isar.autoIncrement;

  late String title;

  DateTime? dueDateTime;

  /// pending | done
  late String status;

  String? category;

  String? priority;

  late DateTime createdAt;
}
