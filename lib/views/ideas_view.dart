import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';

class IdeasView extends ConsumerWidget {
  const IdeasView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ideasAsync = ref.watch(ideasProvider);

    return ideasAsync.when(
      data: (ideas) {
        if (ideas.isEmpty) {
          return _EmptyState();
        }
        final bottomPadding = MediaQuery.of(context).padding.bottom + 104;

        return ListView.builder(
          padding: EdgeInsets.only(left: 16, right: 16, top: 12, bottom: bottomPadding),
          itemCount: ideas.length,
          itemBuilder: (context, index) {
            final idea = ideas[index];
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
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        Icons.lightbulb_rounded,
                        color: colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      idea.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    subtitle: idea.description != null
                        ? Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              idea.description!,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          )
                        : null,
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
                color: colorScheme.primary.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No ideas yet.',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Capture quick thoughts before they slip away.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
