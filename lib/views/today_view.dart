import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../models/habit.dart';
import '../models/habit_log.dart';
import '../models/task.dart';
import '../providers/catalog_providers.dart';
import '../services/catalog_service.dart';

class TodayView extends ConsumerWidget {
  const TodayView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksAsync = ref.watch(tasksProvider);
    final habitsAsync = ref.watch(habitsProvider);
    final logsAsync = ref.watch(habitLogsProvider);

    return tasksAsync.when(
      data: (tasks) {
        return habitsAsync.when(
          data: (habits) {
            final logs = logsAsync.valueOrNull ?? const <HabitLog>[];
            final today = _today();
            final handledTodayIds = logs
                .where((log) => _isSameDay(log.expectedDate, today))
                .map((log) => log.habitId)
                .toSet();

            final pendingTasks = sortTasksForToday(
              tasks.where((t) => t.status != 'done').toList(),
            );
            final dueHabits = habits
                .where((h) => _isDueToday(h, today) && !handledTodayIds.contains(h.id))
                .toList();

            if (pendingTasks.isEmpty && dueHabits.isEmpty) {
              return _EmptyState();
            }

            final bottomPadding = MediaQuery.of(context).padding.bottom + 104;

            return ListView(
              padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPadding),
              children: [
                const _GreetingHeader(),
                const SizedBox(height: 20),
                if (dueHabits.isNotEmpty) ...[
                  _SectionTitle('Habits', icon: Icons.local_fire_department_rounded),
                  const SizedBox(height: 8),
                  ...dueHabits.map((h) => _HabitTile(habit: h)),
                  const SizedBox(height: 20),
                ],
                if (pendingTasks.isNotEmpty) ...[
                  _SectionTitle('Tasks', icon: Icons.check_circle_rounded),
                  const SizedBox(height: 8),
                  ...pendingTasks.map((t) => _TaskTile(task: t)),
                ],
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  static bool _isDueToday(Habit habit, DateTime today) {
    if (habit.lastCompletedAt == null) return true;
    final last = DateTime(
      habit.lastCompletedAt!.year,
      habit.lastCompletedAt!.month,
      habit.lastCompletedAt!.day,
    );
    final daysSince = today.difference(last).inDays;
    return daysSince >= habit.interval;
  }
}

/// Shows a transient confirmation with an Undo action, replacing any
/// snackbar that is already visible so only one shows at a time.
///
/// Takes the [ScaffoldMessengerState] rather than a [BuildContext] because
/// the triggering tile is typically removed from the tree by the time the
/// action completes (the item leaves the Today list), which would unmount
/// its context before the snackbar could be shown.
void _showUndoSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required Future<void> Function() onUndo,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () => onUndo(),
        ),
      ),
    );
}

class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader();

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Good morning';
    } else if (hour < 17) {
      greeting = 'Good afternoon';
    } else {
      greeting = 'Good evening';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEEE, MMM d').format(now),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.icon});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(icon, size: 16, color: colorScheme.secondary),
        const SizedBox(width: 8),
        Text(
          text.toUpperCase(),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: colorScheme.secondary,
                letterSpacing: 0.8,
              ),
        ),
      ],
    );
  }
}

class _TaskTile extends ConsumerWidget {
  const _TaskTile({required this.task});

  final Task task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final priority = task.priority?.toLowerCase();
    final dueText = task.dueDateTime != null
        ? DateFormat('E, h:mm a').format(task.dueDateTime!)
        : null;
    final priorityColor = _priorityColor(context, priority);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
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
            contentPadding: const EdgeInsets.only(left: 16, right: 12),
            horizontalTitleGap: 12,
            leading: Container(
              width: 4,
              height: 44,
              decoration: BoxDecoration(
                color: priorityColor,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(task.title, style: Theme.of(context).textTheme.titleSmall),
            subtitle: Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                if (dueText != null)
                  Text(
                    dueText,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                if (priority != null) _PriorityChip(priority: priority),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.check_circle_outline_rounded),
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              onPressed: () async {
                final messenger = ScaffoldMessenger.of(context);
                final service = await ref.read(catalogServiceProvider.future);
                await service.markTaskDone(task);
                // Snackbar before the haptic: HapticFeedback's platform
                // future never resolves in widget tests, which would stall
                // anything awaited after it.
                _showUndoSnackBar(
                  messenger,
                  message: 'Task marked done',
                  onUndo: () => service.unmarkTaskDone(task),
                );
                await HapticFeedback.lightImpact();
              },
            ),
          ),
        ),
      ),
    );
  }

  Color _priorityColor(BuildContext context, String? priority) {
    final scheme = Theme.of(context).colorScheme;
    switch (priority) {
      case 'high':
        return scheme.error;
      case 'medium':
        return scheme.secondary;
      case 'low':
      default:
        return scheme.onSurface.withValues(alpha: 0.25);
    }
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.priority});

  final String priority;

  @override
  Widget build(BuildContext context) {
    final colors = {
      'high': Theme.of(context).colorScheme.error,
      'medium': Theme.of(context).colorScheme.secondary,
      'low': Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.45),
    };
    final color = colors[priority] ?? colors['low']!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        priority.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _HabitTile extends ConsumerWidget {
  const _HabitTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            title: Text(habit.title, style: Theme.of(context).textTheme.titleSmall),
            subtitle: Text(
              'Streak: ${habit.streakCount}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ActionButton(
                  icon: Icons.check_rounded,
                  color: const Color(0xFF22C55E),
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final service = await ref.read(catalogServiceProvider.future);
                    await service.markHabitDone(habit);
                    _showUndoSnackBar(
                      messenger,
                      message: 'Habit marked done',
                      onUndo: () => service.unmarkHabitDone(habit),
                    );
                    await HapticFeedback.lightImpact();
                  },
                ),
                const SizedBox(width: 6),
                _ActionButton(
                  icon: Icons.close_rounded,
                  color: colorScheme.error,
                  onPressed: () async {
                    final messenger = ScaffoldMessenger.of(context);
                    final service = await ref.read(catalogServiceProvider.future);
                    await service.markHabitMissed(habit);
                    _showUndoSnackBar(
                      messenger,
                      message: 'Habit marked missed',
                      onUndo: () => service.unmarkHabitMissed(habit),
                    );
                    await HapticFeedback.lightImpact();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 20),
        ),
      ),
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
                Icons.nightlight_round,
                size: 40,
                color: colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Nothing due right now.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to capture a task or habit.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
