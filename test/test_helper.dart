import 'dart:io';

import 'package:isar/isar.dart';

import 'package:pakai_niat/models/habit.dart';
import 'package:pakai_niat/models/habit_log.dart';
import 'package:pakai_niat/models/idea.dart';
import 'package:pakai_niat/models/inbox_capture.dart';
import 'package:pakai_niat/models/task.dart';

/// Opens a fresh Isar instance in a temporary directory for tests.
Future<Isar> openTestIsar() async {
  final tempDir = await Directory.systemTemp.createTemp('pakai_niat_test_');
  return Isar.open(
    [InboxCaptureSchema, TaskSchema, HabitSchema, HabitLogSchema, IdeaSchema],
    directory: tempDir.path,
    name: 'test_${DateTime.now().microsecondsSinceEpoch}',
  );
}

/// Closes and deletes the test Isar instance.
Future<void> closeTestIsar(Isar isar) async {
  await isar.close(deleteFromDisk: true);
}
