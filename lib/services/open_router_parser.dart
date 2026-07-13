import 'dart:convert';

import 'package:dio/dio.dart';

import 'capture_draft.dart';
import 'catalog_operation.dart';

class OpenRouterParser {
  OpenRouterParser({
    required this.apiKey,
    Dio? dio,
  }) : _dio = dio ?? Dio();

  final String apiKey;
  final Dio _dio;

  static const String _endpoint = 'https://openrouter.ai/api/v1/chat/completions';

  /// Command parser model. DeepSeek V4 Flash is dirt cheap
  /// ($0.077/$0.154 per M tokens) and handles json_object reliably.
  /// The retrospective engine, when built, should use
  /// 'deepseek/deepseek-v4-pro' for its stronger reasoning.
  static const String _parserModel = 'deepseek/deepseek-v4-flash';

  /// Paid fallback if the primary parser model is unavailable.
  static const String _paidFallback = 'deepseek/deepseek-v4-pro';

  /// Free models, last resort only (e.g. account out of credits).
  /// They are flaky: providers error out, return malformed JSON, or
  /// ignore the system prompt.
  static const List<String> _freeModels = [
    'openrouter/free',
    'meta-llama/llama-3.3-70b-instruct:free',
    'qwen/qwen3-coder:free',
    'nousresearch/hermes-3-llama-3.1-405b:free',
  ];

  Future<List<CatalogOperation>> parse(String rawText, {DateTime? currentTime}) async {
    if (apiKey.isEmpty || apiKey == 'replace_me') {
      throw StateError('OPENROUTER_KEY is missing or not configured.');
    }

    final now = currentTime ?? DateTime.now();
    String? lastErrorMessage;

    final models = [
      _parserModel,
      _paidFallback,
      ..._freeModels,
    ];

    for (final model in models) {
      try {
        final response = await _dio.post(
          _endpoint,
          options: Options(
            headers: {
              'Authorization': 'Bearer $apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://gr3gg0r.github.io/pakai-niat/',
              'X-Title': 'Pakai Niat',
            },
          ),
          data: {
            'model': model,
            'response_format': {'type': 'json_object'},
            'messages': [
              {
                'role': 'system',
                'content': _systemPrompt(now),
              },
              {
                'role': 'user',
                'content': rawText,
              },
            ],
          },
        );

        final content = response.data['choices'][0]['message']['content'] as String;
        final decoded = jsonDecode(content);
        if (decoded is! Map<String, dynamic>) {
          throw StateError('OpenRouter returned an unexpected response shape.');
        }
        return _mapToOperations(decoded);
      } catch (e) {
        // A model may error out, return malformed JSON, or ignore the
        // system prompt. Wait briefly to avoid 429 bursts, then try the
        // next model instead of failing immediately.
        lastErrorMessage = e.toString();
        await Future.delayed(const Duration(seconds: 2));
        continue;
      }
    }

    throw StateError(
      'All OpenRouter models failed. Last error: $lastErrorMessage. '
      'Check your API key and account credits, then try again.',
    );
  }

  String _systemPrompt(DateTime now) {
    return '''
You are the deterministic JSON kernel of Pakai Niat.
Convert the user's natural language input into a list of catalog operations.
Current ISO timestamp: ${now.toIso8601String()}.

Rules:
- Return raw JSON text only. No markdown, no explanations, no prose.
- The top-level object must have a single "operations" field containing an array of operation objects.
- Each operation must have an "op" field with value "create", "update", or "delete".
- For "create": include "type" (task/habit/idea) and "title". Optional fields: "dueDateTime", "priority" (high/medium/low), "frequency", "interval", "dueTime", "description".
- For "update": include "targetType" (task/habit/idea), "targetTitle" (the existing title to match), and any fields to change: "newTitle", "dueDateTime", "priority", "frequency", "interval", "dueTime", "description", "markDone" (boolean).
- For "delete": include "targetType" and "targetTitle".
- Convert relative times like "tonight", "later", "after work" into absolute ISO timestamps based on the current time.
- Infer priority from urgency or deadlines. If the user says "must finish before X", "urgent", "ASAP", set priority to "high" and dueDateTime to the deadline.
- If today is Friday and the user mentions Zuhr prayer, treat it as Solat Jumaat for today: create a task "Solat Jumaat" and mark the "Zuhr prayer" habit as done.
- If the input contains multiple items, return multiple operations.

Example output for "study Rust for an hour":
{"operations":[{"op":"create","type":"task","title":"Study Rust","dueDateTime":"${now.toIso8601String()}"}]}

Example output for "rename reading habit to deep reading":
{"operations":[{"op":"update","targetType":"habit","targetTitle":"reading","newTitle":"deep reading"}]}

Example output for "today is friday so change zuhr prayer to solat jumaat":
{"operations":[{"op":"create","type":"task","title":"Solat Jumaat"},{"op":"update","targetType":"habit","targetTitle":"zuhr prayer","markDone":true}]}
'''.trim();
  }

  /// Maximum accepted length for LLM-supplied titles. Guards against absurd
  /// or oversized output being written to the database.
  static const int _maxTitleLength = 500;

  static const Set<String> _validTypes = {'task', 'habit', 'idea'};

  List<CatalogOperation> _mapToOperations(Map<String, dynamic> json) {
    final operations = json['operations'];
    if (operations is! List || operations.isEmpty) {
      throw StateError('OpenRouter returned an unexpected response shape.');
    }

    DateTime? parseDate(dynamic value, String field) {
      if (value == null) return null;
      if (value is! String) {
        throw StateError(
          'OpenRouter field "$field" must be an ISO date string.',
        );
      }
      if (value.isEmpty) return null;
      final parsed = DateTime.tryParse(value);
      if (parsed == null) {
        throw StateError(
          'OpenRouter field "$field" is not a valid date: "$value".',
        );
      }
      return parsed;
    }

    String? optionalString(dynamic value, String field) {
      if (value == null) return null;
      if (value is! String) {
        throw StateError('OpenRouter field "$field" must be a string.');
      }
      return value;
    }

    int? optionalInt(dynamic value, String field) {
      if (value == null) return null;
      if (value is! int) {
        throw StateError('OpenRouter field "$field" must be an integer.');
      }
      return value;
    }

    bool? parseBool(dynamic value) {
      if (value == null) return null;
      if (value is bool) return value;
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'true':
            return true;
          case 'false':
            return false;
        }
      }
      throw StateError('OpenRouter field "markDone" must be a boolean.');
    }

    String requireType(dynamic value, String field) {
      if (value is! String || !_validTypes.contains(value)) {
        throw StateError(
          'OpenRouter field "$field" must be one of: task, habit, idea.',
        );
      }
      return value;
    }

    String requireTitle(dynamic value, String field) {
      if (value is! String || value.trim().isEmpty) {
        throw StateError(
          'OpenRouter field "$field" must be a non-empty string.',
        );
      }
      if (value.length > _maxTitleLength) {
        throw StateError(
          'OpenRouter field "$field" exceeds the '
          '$_maxTitleLength-character limit.',
        );
      }
      return value;
    }

    String? optionalTitle(dynamic value, String field) {
      if (value == null) return null;
      return requireTitle(value, field);
    }

    return operations.map((item) {
      if (item is! Map<String, dynamic>) {
        throw StateError('OpenRouter returned a malformed operation entry.');
      }
      final map = item;
      final op = map['op'];
      if (op is! String) {
        throw StateError(
          'OpenRouter operation is missing a valid "op" field.',
        );
      }

      switch (op) {
        case 'create':
          return CreateOperation(
            CaptureDraft(
              type: requireType(map['type'], 'type'),
              title: requireTitle(map['title'], 'title'),
              dueDateTime: parseDate(map['dueDateTime'], 'dueDateTime'),
              priority: optionalString(map['priority'], 'priority'),
              frequency: optionalString(map['frequency'], 'frequency'),
              interval: optionalInt(map['interval'], 'interval'),
              dueTime: parseDate(map['dueTime'], 'dueTime'),
              description: optionalString(map['description'], 'description'),
            ),
          );
        case 'update':
          return UpdateOperation(
            targetType: requireType(map['targetType'], 'targetType'),
            targetTitle: requireTitle(map['targetTitle'], 'targetTitle'),
            newTitle: optionalTitle(map['newTitle'], 'newTitle'),
            dueDateTime: parseDate(map['dueDateTime'], 'dueDateTime'),
            priority: optionalString(map['priority'], 'priority'),
            frequency: optionalString(map['frequency'], 'frequency'),
            interval: optionalInt(map['interval'], 'interval'),
            dueTime: parseDate(map['dueTime'], 'dueTime'),
            description: optionalString(map['description'], 'description'),
            markDone: parseBool(map['markDone']),
          );
        case 'delete':
          return DeleteOperation(
            targetType: requireType(map['targetType'], 'targetType'),
            targetTitle: requireTitle(map['targetTitle'], 'targetTitle'),
          );
        default:
          throw StateError('Unknown operation: $op');
      }
    }).toList();
  }
}
