import 'package:isar/isar.dart';

part 'inbox_capture.g.dart';

@Collection()
class InboxCapture {
  Id id = Isar.autoIncrement;

  late String rawText;

  late DateTime createdAt;

  /// pending | parsed | failed
  late String status;

  String? parsedType;

  String? parsedJson;

  String? errorMessage;
}
