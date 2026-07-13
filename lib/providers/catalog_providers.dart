import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/idea.dart';
import '../models/task.dart';
import '../services/catalog_service.dart';
import '../services/open_router_parser.dart';
import 'isar_provider.dart';

final catalogServiceProvider = FutureProvider<CatalogService>((ref) async {
  final isar = await ref.watch(isarProvider.future);
  return CatalogService(isar);
});

final tasksProvider = StreamProvider.autoDispose<List<Task>>((ref) async* {
  final service = await ref.watch(catalogServiceProvider.future);
  yield* service.watchTasks();
});

final habitsProvider = StreamProvider.autoDispose<List<Habit>>((ref) async* {
  final service = await ref.watch(catalogServiceProvider.future);
  yield* service.watchHabits();
});

final ideasProvider = StreamProvider.autoDispose<List<Idea>>((ref) async* {
  final service = await ref.watch(catalogServiceProvider.future);
  yield* service.watchIdeas();
});

final habitLogsProvider = StreamProvider.autoDispose<List<HabitLog>>((ref) async* {
  final service = await ref.watch(catalogServiceProvider.future);
  yield* service.watchHabitLogs();
});

/// Resolves the OpenRouter API key from .env (asset) first, then from a
/// compile-time dart-define. Using an asset lets the app work during normal
/// `flutter run` without remembering to pass `--dart-define` every time, while
/// release builds can still hard-code the key via `--dart-define` for extra
/// security if desired.
final openRouterKeyProvider = Provider<String>((ref) {
  const compiled = String.fromEnvironment('OPENROUTER_KEY');
  final fromEnv = dotenv.env['OPENROUTER_KEY'];
  return (compiled.isNotEmpty ? compiled : fromEnv ?? '').trim();
});

final openRouterParserProvider = Provider<OpenRouterParser>((ref) {
  return OpenRouterParser(apiKey: ref.watch(openRouterKeyProvider));
});
