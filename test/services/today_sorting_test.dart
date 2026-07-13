import 'package:flutter_test/flutter_test.dart';

import 'package:pakai_niat/models/task.dart';
import 'package:pakai_niat/services/catalog_service.dart';

Task _task({
  required String title,
  String? priority,
  DateTime? dueDateTime,
  required DateTime createdAt,
}) {
  return Task()
    ..title = title
    ..status = 'pending'
    ..priority = priority
    ..dueDateTime = dueDateTime
    ..createdAt = createdAt;
}

void main() {
  final base = DateTime(2026, 7, 13, 9);

  test('orders by priority: high, medium, low, none', () {
    final tasks = [
      _task(title: 'none', createdAt: base),
      _task(title: 'low', priority: 'low', createdAt: base),
      _task(title: 'high', priority: 'high', createdAt: base),
      _task(title: 'medium', priority: 'medium', createdAt: base),
    ];

    final sorted = sortTasksForToday(tasks);

    expect(sorted.map((t) => t.title), ['high', 'medium', 'low', 'none']);
  });

  test('treats unknown labels as no priority, case-insensitively', () {
    final tasks = [
      _task(title: 'weird', priority: 'someday', createdAt: base),
      _task(title: 'caps', priority: 'HIGH', createdAt: base),
      _task(title: 'low', priority: 'low', createdAt: base),
    ];

    final sorted = sortTasksForToday(tasks);

    expect(sorted.map((t) => t.title), ['caps', 'low', 'weird']);
  });

  test('orders by due date ascending within the same priority', () {
    final tasks = [
      _task(
        title: 'later',
        priority: 'high',
        dueDateTime: base.add(const Duration(hours: 5)),
        createdAt: base,
      ),
      _task(
        title: 'sooner',
        priority: 'high',
        dueDateTime: base.add(const Duration(hours: 1)),
        createdAt: base,
      ),
    ];

    final sorted = sortTasksForToday(tasks);

    expect(sorted.map((t) => t.title), ['sooner', 'later']);
  });

  test('tasks without a due date sort last within the same priority', () {
    final tasks = [
      _task(
        title: 'no due',
        priority: 'high',
        createdAt: base.subtract(const Duration(days: 1)),
      ),
      _task(
        title: 'due',
        priority: 'high',
        dueDateTime: base.add(const Duration(hours: 1)),
        createdAt: base,
      ),
    ];

    final sorted = sortTasksForToday(tasks);

    expect(sorted.map((t) => t.title), ['due', 'no due']);
  });

  test('breaks remaining ties by creation time ascending', () {
    final tasks = [
      _task(title: 'newer', priority: 'low', createdAt: base),
      _task(
        title: 'older',
        priority: 'low',
        createdAt: base.subtract(const Duration(hours: 3)),
      ),
    ];

    final sorted = sortTasksForToday(tasks);

    expect(sorted.map((t) => t.title), ['older', 'newer']);
  });

  test('priority outranks due date across sort keys', () {
    // A high-priority task due next week still floats above a
    // medium-priority task due in an hour.
    final tasks = [
      _task(
        title: 'medium soon',
        priority: 'medium',
        dueDateTime: base.add(const Duration(hours: 1)),
        createdAt: base,
      ),
      _task(
        title: 'high later',
        priority: 'high',
        dueDateTime: base.add(const Duration(days: 7)),
        createdAt: base,
      ),
    ];

    final sorted = sortTasksForToday(tasks);

    expect(sorted.map((t) => t.title), ['high later', 'medium soon']);
  });

  test('does not mutate the input list', () {
    final tasks = [
      _task(title: 'b', priority: 'low', createdAt: base),
      _task(title: 'a', priority: 'high', createdAt: base),
    ];

    final sorted = sortTasksForToday(tasks);

    expect(sorted.map((t) => t.title), ['a', 'b']);
    expect(tasks.map((t) => t.title), ['b', 'a']);
  });
}
