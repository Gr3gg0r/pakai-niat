import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:pakai_niat/services/catalog_operation.dart';
import 'package:pakai_niat/services/open_router_parser.dart';

class _FakeOpenRouterAdapter implements HttpClientAdapter {
  _FakeOpenRouterAdapter(this._responseJson);

  final Map<String, dynamic> _responseJson;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final content = jsonEncode(_responseJson);
    return ResponseBody.fromString(
      jsonEncode({
        'choices': [
          {
            'message': {'content': content}
          }
        ]
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Returns [content] verbatim as the LLM message content, so tests can feed
/// malformed or wrongly-shaped JSON through the parser.
class _RawContentAdapter implements HttpClientAdapter {
  _RawContentAdapter(this._content);

  final String _content;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode({
        'choices': [
          {
            'message': {'content': _content}
          }
        ]
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Always responds with HTTP 500, simulating a provider that is down.
class _FailingAdapter implements HttpClientAdapter {
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      '{"error": "provider unavailable"}',
      500,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Fails the first [failures] requests, then serves a valid response.
/// Verifies the parser's wait-and-retry loop recovers from flaky models.
class _FlakyAdapter implements HttpClientAdapter {
  _FlakyAdapter(this.failures);

  final int failures;
  int _requests = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    _requests += 1;
    if (_requests <= failures) {
      return ResponseBody.fromString('{"error": "rate limited"}', 429);
    }
    return ResponseBody.fromString(
      jsonEncode({
        'choices': [
          {
            'message': {
              'content': jsonEncode({
                'operations': [
                  {'op': 'create', 'type': 'idea', 'title': 'Recovered'}
                ]
              })
            }
          }
        ]
      }),
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test('parses a create task operation', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'create',
          'type': 'task',
          'title': 'Study Rust',
          'dueDateTime': '2026-07-10T12:00:00.000',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);
    final ops = await parser.parse('study Rust for an hour');

    expect(ops, hasLength(1));
    final op = ops.first as CreateOperation;
    expect(op.draft.isTask, true);
    expect(op.draft.title, 'Study Rust');
    expect(op.draft.dueDateTime, isNotNull);
  });

  test('parses a create habit operation', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'create',
          'type': 'habit',
          'title': 'Skin care',
          'frequency': 'everyNDays',
          'interval': 2,
          'dueTime': '2026-07-10T21:00:00.000',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);
    final ops = await parser.parse('skin care every 2 days evening');

    expect(ops, hasLength(1));
    final op = ops.first as CreateOperation;
    expect(op.draft.isHabit, true);
    expect(op.draft.title, 'Skin care');
    expect(op.draft.frequency, 'everyNDays');
    expect(op.draft.interval, 2);
  });

  test('parses an update operation', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'update',
          'targetType': 'habit',
          'targetTitle': 'gym',
          'interval': 3,
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);
    final ops = await parser.parse('change gym to every 3 days');

    expect(ops, hasLength(1));
    final op = ops.first as UpdateOperation;
    expect(op.targetType, 'habit');
    expect(op.targetTitle, 'gym');
    expect(op.interval, 3);
  });

  test('parses a delete operation', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'delete',
          'targetType': 'task',
          'targetTitle': 'old task',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);
    final ops = await parser.parse('delete old task');

    expect(ops, hasLength(1));
    final op = ops.first as DeleteOperation;
    expect(op.targetType, 'task');
    expect(op.targetTitle, 'old task');
  });

  test('parses priority for a task', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'create',
          'type': 'task',
          'title': 'Submit report',
          'dueDateTime': '2026-07-10T17:00:00.000',
          'priority': 'high',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);
    final ops = await parser.parse('urgent: submit report before 5pm');

    expect(ops, hasLength(1));
    final op = ops.first as CreateOperation;
    expect(op.draft.priority, 'high');
  });

  test('throws when API key is missing', () async {
    final parser = OpenRouterParser(apiKey: '');

    expect(
      () => parser.parse('anything'),
      throwsA(isA<StateError>()),
    );
  });

  test('parses markDone given as a string', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'update',
          'targetType': 'habit',
          'targetTitle': 'zuhr prayer',
          'markDone': 'true',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);
    final ops = await parser.parse('mark zuhr as done');

    final op = ops.first as UpdateOperation;
    expect(op.markDone, true);
  });

  test('retries the next model and recovers after a failure', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FlakyAdapter(1);

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);
    final ops = await parser.parse('remember this');

    expect(ops, hasLength(1));
    final op = ops.first as CreateOperation;
    expect(op.draft.title, 'Recovered');
  });

  test('throws a wait-and-retry error when all models fail', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FailingAdapter();

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    await expectLater(
      parser.parse('buy milk'),
      throwsA(isA<StateError>().having(
        (e) => e.message,
        'message',
        contains('Wait a minute and try again'),
      )),
    );
  });

  test('rejects malformed JSON content', () async {
    final dio = Dio();
    dio.httpClientAdapter = _RawContentAdapter('not json at all {{{');

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add gym'), throwsA(isA<StateError>()));
  });

  test('rejects an empty LLM response', () async {
    final dio = Dio();
    dio.httpClientAdapter = _RawContentAdapter('');

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add gym'), throwsA(isA<StateError>()));
  });

  test('rejects a top-level JSON array', () async {
    final dio = Dio();
    dio.httpClientAdapter = _RawContentAdapter('[{"op": "create"}]');

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add gym'), throwsA(isA<StateError>()));
  });

  test('rejects a top-level JSON string', () async {
    final dio = Dio();
    dio.httpClientAdapter = _RawContentAdapter('"just a string"');

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add gym'), throwsA(isA<StateError>()));
  });

  test('rejects an empty JSON object', () async {
    final dio = Dio();
    dio.httpClientAdapter = _RawContentAdapter('{}');

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add gym'), throwsA(isA<StateError>()));
  });

  test('rejects a non-object operation entry', () async {
    final dio = Dio();
    dio.httpClientAdapter = _RawContentAdapter(
      '{"operations": ["create a task"]}',
    );

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add gym'), throwsA(isA<StateError>()));
  });

  test('rejects an unknown operation type', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'op': 'explode', 'type': 'task', 'title': 'Boom'}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('do something'), throwsA(isA<StateError>()));
  });

  test('rejects an operation missing the op field', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'type': 'task', 'title': 'No op field'}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add something'), throwsA(isA<StateError>()));
  });

  test('rejects a create operation missing the title', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'op': 'create', 'type': 'task'}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add something'), throwsA(isA<StateError>()));
  });

  test('rejects a create operation with an empty title', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'op': 'create', 'type': 'task', 'title': '   '}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add something'), throwsA(isA<StateError>()));
  });

  test('rejects a create operation with a non-string title', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'op': 'create', 'type': 'task', 'title': 42}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add something'), throwsA(isA<StateError>()));
  });

  test('rejects an oversized title', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'op': 'create', 'type': 'task', 'title': 'x' * 501}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('add something'), throwsA(isA<StateError>()));
  });

  test('rejects an invalid date string', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'create',
          'type': 'task',
          'title': 'Study Rust',
          'dueDateTime': 'next tuesdayish',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('study rust'), throwsA(isA<StateError>()));
  });

  test('rejects a wrong field type for interval', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'create',
          'type': 'habit',
          'title': 'Gym',
          'interval': 'daily',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('gym daily'), throwsA(isA<StateError>()));
  });

  test('rejects an invalid markDone value', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {
          'op': 'update',
          'targetType': 'habit',
          'targetTitle': 'gym',
          'markDone': 'yes',
        }
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('gym done'), throwsA(isA<StateError>()));
  });

  test('rejects an update operation missing the target title', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'op': 'update', 'targetType': 'habit', 'interval': 3}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('change gym'), throwsA(isA<StateError>()));
  });

  test('rejects an unknown target type', () async {
    final dio = Dio();
    dio.httpClientAdapter = _FakeOpenRouterAdapter({
      'operations': [
        {'op': 'delete', 'targetType': 'chore', 'targetTitle': 'gym'}
      ],
    });

    final parser = OpenRouterParser(apiKey: 'fake-key', dio: dio);

    expect(() => parser.parse('delete gym'), throwsA(isA<StateError>()));
  });
}
