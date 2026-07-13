import 'package:flutter_test/flutter_test.dart';

import 'package:pakai_niat/services/capture_draft.dart';

void main() {
  test('constructs a draft with all fields set', () {
    final due = DateTime(2026, 7, 10, 12);
    final dueTime = DateTime(2026, 7, 10, 21);
    final draft = CaptureDraft(
      type: 'task',
      title: 'Study Rust',
      dueDateTime: due,
      priority: 'high',
      frequency: 'daily',
      interval: 2,
      dueTime: dueTime,
      description: 'notes',
    );

    expect(draft.type, 'task');
    expect(draft.title, 'Study Rust');
    expect(draft.dueDateTime, due);
    expect(draft.priority, 'high');
    expect(draft.frequency, 'daily');
    expect(draft.interval, 2);
    expect(draft.dueTime, dueTime);
    expect(draft.description, 'notes');
    expect(draft.isTask, true);
    expect(draft.isHabit, false);
    expect(draft.isIdea, false);
  });

  test('optional fields default to null', () {
    const draft = CaptureDraft(type: 'idea', title: 'An idea');

    expect(draft.dueDateTime, isNull);
    expect(draft.priority, isNull);
    expect(draft.frequency, isNull);
    expect(draft.interval, isNull);
    expect(draft.dueTime, isNull);
    expect(draft.description, isNull);
  });

  test('type getters follow the type string exactly', () {
    const habit = CaptureDraft(type: 'habit', title: 'h');
    const idea = CaptureDraft(type: 'idea', title: 'i');
    const unknown = CaptureDraft(type: 'chore', title: 'c');

    expect(habit.isHabit, true);
    expect(habit.isTask, false);
    expect(idea.isIdea, true);
    expect(idea.isHabit, false);
    expect(unknown.isTask, false);
    expect(unknown.isHabit, false);
    expect(unknown.isIdea, false);
  });
}
