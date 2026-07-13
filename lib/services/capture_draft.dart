class CaptureDraft {
  final String type;
  final String title;
  final DateTime? dueDateTime;
  final String? priority; // high | medium | low
  final String? frequency;
  final int? interval;
  final DateTime? dueTime;
  final String? description;

  const CaptureDraft({
    required this.type,
    required this.title,
    this.dueDateTime,
    this.priority,
    this.frequency,
    this.interval,
    this.dueTime,
    this.description,
  });

  bool get isTask => type == 'task';
  bool get isHabit => type == 'habit';
  bool get isIdea => type == 'idea';
}
