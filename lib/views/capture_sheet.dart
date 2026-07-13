import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/catalog_providers.dart';
import '../services/capture_draft.dart';
import '../services/catalog_operation.dart';

class CaptureSheet extends ConsumerStatefulWidget {
  const CaptureSheet({super.key});

  @override
  ConsumerState<CaptureSheet> createState() => _CaptureSheetState();
}

class _CaptureSheetState extends ConsumerState<CaptureSheet> {
  final _controller = TextEditingController();
  bool _isLoading = false;
  List<CatalogOperation> _operations = [];
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 5,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Capture',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                'Tell the agent what to schedule, change, or remember.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              if (_operations.isEmpty) ...[
                TextField(
                  controller: _controller,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'e.g., study Rust for an hour, high priority before 5pm',
                    prefixIcon: Icon(Icons.edit_note_rounded),
                  ),
                  maxLines: 4,
                  minLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 14),
                if (_error != null) _ErrorBanner(message: _error!),
                ElevatedButton.icon(
                  onPressed: _isLoading ? null : _parse,
                  icon: _isLoading
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C1400)),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: const Text('Parse with AI'),
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: TextButton(
                      onPressed: _isLoading ? null : _saveAsIdea,
                      child: const Text('Save raw text as Idea'),
                    ),
                  ),
              ] else ...[
                Text(
                  'Found ${_operations.length} operation(s)',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 10),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 280),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _operations.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final op = _operations[index];
                      return _OperationCard(operation: op);
                    },
                  ),
                ),
                const SizedBox(height: 14),
                if (_error != null) _ErrorBanner(message: _error!),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : () => setState(() => _operations = []),
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _commit,
                        child: _isLoading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF1C1400)),
                              )
                            : const Text('Apply'),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _parse() async {
    final key = ref.read(openRouterKeyProvider);
    if (key.isEmpty) {
      setState(() {
        _error = 'OpenRouter API key is missing. Add OPENROUTER_KEY to .env or rebuild with --dart-define.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final parser = ref.read(openRouterParserProvider);
      final operations = await parser.parse(_controller.text);
      setState(() {
        _operations = operations;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _commit() async {
    if (_operations.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final service = await ref.read(catalogServiceProvider.future);
      await service.commitOperations(_operations);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      return;
    }

    if (!mounted) return;
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _saveAsIdea() async {
    final rawText = _controller.text.trim();
    if (rawText.isEmpty) return;

    setState(() => _isLoading = true);

    try {
      final service = await ref.read(catalogServiceProvider.future);
      await service.commitDraft(
        CaptureDraft(type: 'idea', title: rawText),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
      return;
    }

    if (!mounted) return;
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    Navigator.pop(context);
  }
}

class _OperationCard extends StatelessWidget {
  const _OperationCard({required this.operation});

  final CatalogOperation operation;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = _iconFor(operation);
    final title = _titleFor(operation);
    final subtitle = _subtitleFor(operation);
    final color = _colorFor(operation, colorScheme);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleSmall),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _iconFor(CatalogOperation operation) {
    switch (operation) {
      case CreateOperation(:final draft):
        return _iconForType(draft.type);
      case UpdateOperation(:final targetType):
        return _iconForType(targetType);
      case DeleteOperation(:final targetType):
        return _iconForType(targetType);
    }
  }

  IconData _iconForType(String type) {
    switch (type) {
      case 'task':
        return Icons.check_circle_rounded;
      case 'habit':
        return Icons.repeat_rounded;
      case 'idea':
      default:
        return Icons.lightbulb_rounded;
    }
  }

  Color _colorFor(CatalogOperation operation, ColorScheme scheme) {
    switch (operation) {
      case CreateOperation():
        return scheme.primary;
      case UpdateOperation():
        return scheme.secondary;
      case DeleteOperation():
        return scheme.error;
    }
  }

  String _titleFor(CatalogOperation operation) {
    switch (operation) {
      case CreateOperation(:final draft):
        return 'Create ${draft.title}';
      case UpdateOperation(:final targetTitle, :final newTitle):
        if (newTitle != null && newTitle != targetTitle) {
          return 'Rename "$targetTitle" to "$newTitle"';
        }
        return 'Update "$targetTitle"';
      case DeleteOperation(:final targetTitle):
        return 'Delete "$targetTitle"';
    }
  }

  String _subtitleFor(CatalogOperation operation) {
    switch (operation) {
      case CreateOperation(:final draft):
        final parts = [draft.type, draft.priority].whereType<String>().toList();
        if (draft.dueDateTime != null) {
          parts.add('due ${draft.dueDateTime!.toIso8601String()}');
        }
        return parts.join(' • ');
      case UpdateOperation(:final targetType, :final priority):
        return ['update $targetType', priority].whereType<String>().join(' • ');
      case DeleteOperation(:final targetType):
        return 'delete $targetType';
    }
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.error.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.error, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.error.withValues(alpha: 0.95),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
