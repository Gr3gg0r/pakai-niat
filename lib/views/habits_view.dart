import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';

class HabitsView extends ConsumerWidget {
  const HabitsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habitsAsync = ref.watch(habitsProvider);

    return habitsAsync.when(
      data: (habits) {
        if (habits.isEmpty) {
          return _EmptyState();
        }
        final bottomPadding = MediaQuery.of(context).padding.bottom + 104;

        return ListView.builder(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPadding),
          itemCount: habits.length,
          itemBuilder: (context, index) {
            final habit = habits[index];
            final colorScheme = Theme.of(context).colorScheme;

            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.secondary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.local_fire_department_rounded,
                        color: colorScheme.secondary,
                      ),
                    ),
                    title: Text(
                      habit.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: Text(
                      '${habit.frequency}${habit.interval > 1 ? ' · every ${habit.interval} days' : ''} · Streak: ${habit.streakCount}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    trailing: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          final service = await ref.read(catalogServiceProvider.future);
                          await service.markHabitDone(habit);
                          await HapticFeedback.lightImpact();
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          alignment: Alignment.center,
                          child: const Icon(
                            Icons.check_rounded,
                            color: Color(0xFF22C55E),
                            size: 22,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.local_fire_department_rounded,
                size: 40,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No habits yet.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Build a streak by capturing a daily ritual.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
