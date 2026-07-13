import 'package:isar/isar.dart';

part 'idea.g.dart';

@Collection()
class Idea {
  Id id = Isar.autoIncrement;

  late String title;

  String? description;

  late DateTime capturedAt;

  List<String> tags = [];
}
