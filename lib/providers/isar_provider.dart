import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/idea.dart';
import '../models/inbox_capture.dart';
import '../models/task.dart';

final isarProvider = FutureProvider<Isar>((ref) async {
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open(
    [InboxCaptureSchema, TaskSchema, HabitSchema, HabitLogSchema, IdeaSchema],
    directory: dir.path,
    name: 'pakai_niat_instance',
  );
  return isar;
});
