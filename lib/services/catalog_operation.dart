import 'capture_draft.dart';

/// An AI-driven mutation on the user's catalog.
///
/// The parser can emit create, update, or delete operations from natural
/// language commands such as:
/// - "add gym every day" -> CreateOperation
/// - "rename skin care to face care" -> UpdateOperation
/// - "delete gym habit" -> DeleteOperation
/// - "mark zuhr as done today" -> UpdateOperation(markDone: true)
sealed class CatalogOperation {}

class CreateOperation extends CatalogOperation {
  CreateOperation(this.draft);

  final CaptureDraft draft;
}

class UpdateOperation extends CatalogOperation {
  UpdateOperation({
    required this.targetType,
    required this.targetTitle,
    this.newTitle,
    this.dueDateTime,
    this.priority,
    this.frequency,
    this.interval,
    this.dueTime,
    this.description,
    this.markDone,
  });

  final String targetType; // task | habit | idea
  final String targetTitle;
  final String? newTitle;
  final DateTime? dueDateTime;
  final String? priority; // high | medium | low
  final String? frequency;
  final int? interval;
  final DateTime? dueTime;
  final String? description;
  final bool? markDone;
}

class DeleteOperation extends CatalogOperation {
  DeleteOperation({
    required this.targetType,
    required this.targetTitle,
  });

  final String targetType; // task | habit | idea
  final String targetTitle;
}
