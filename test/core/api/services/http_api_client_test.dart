// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/core/api/services/http_api_client_test.dart
//
// Tests for HttpApiClient — the dart:http-backed IApiClient implementation.
// Uses package:http/testing.dart MockClient to control responses.
//
// Structurally mirrors dio_api_client_test so the two are easy to compare.

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart' as http_test;

import 'package:mpv_ioc/core/api/exception/failure.dart';
import 'package:mpv_ioc/core/api/services/http_api_client.dart';
import 'package:mpv_ioc/core/enums/enums.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

// ── Helpers ────────────────────────────────────────────────────────

http_test.MockClient mockHttpClient(
  int status,
  Map<String, dynamic> body,
) {
  return http_test.MockClient(
    (_) async => http.Response(jsonEncode(body), status),
  );
}

HttpApiClient buildClient(http_test.MockClient httpClient) {
  return HttpApiClient(
    networkInfo: MockNetworkInfo(),
    client:      httpClient,
  );
}

void main() {
  // ── Successful responses ──────────────────────────────────────

  group('successful responses', () {
    test('200 with data envelope → Right(ApiResponse)', () async {
      final client = buildClient(mockHttpClient(200, tPostsEnvelope));

      final result = await client.request(
        '/posts',
        MethodType.get,
        (data) => (data as List).map((e) => e as Map<String, dynamic>).toList(),
        {},
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right: $l'),
        (r) {
          expect(r.data, isA<List>());
          expect(r.success, isTrue);
          expect(r.message, equals('Success'));
        },
      );
    });

    test('200 with raw object (no envelope) → Right', () async {
      final client = buildClient(mockHttpClient(200, tPost1.toJson()));

      final result = await client.request(
        '/posts/1',
        MethodType.get,
        (data) => data as Map<String, dynamic>,
        {},
      );

      expect(result.isRight(), isTrue);
    });

    test('201 POST response → Right', () async {
      final client = buildClient(mockHttpClient(201, tPostEnvelope));

      final result = await client.request(
        '/posts',
        MethodType.post,
        (d) => d as Map<String, dynamic>,
        {'title': 'T', 'body': 'B'},
      );

      expect(result.isRight(), isTrue);
    });

    test('200 PUT response → Right', () async {
      final client = buildClient(
          mockHttpClient(200, {'data': tPost1.toJson(), 'success': true}));

      final result = await client.request(
        '/posts/1',
        MethodType.put,
        (d) => d,
        {'title': 'Updated'},
      );

      expect(result.isRight(), isTrue);
    });

    test('200 DELETE response → Right', () async {
      final client = buildClient(
          mockHttpClient(200, {'message': 'Deleted', 'success': true}));

      final result = await client.request(
        '/posts/1', MethodType.delete, (_) {}, {},
      );

      expect(result.isRight(), isTrue);
    });

    test('applies fromJson transformer', () async {
      final client = buildClient(
          mockHttpClient(200, {'data': tPost1.toJson(), 'success': true}));

      final result = await client.request(
        '/posts/1',
        MethodType.get,
        (data) => (data as Map<String, dynamic>)['title'] as String,
        {},
      );

      result.fold(
        (l) => fail('Expected Right'),
        (r) => expect(r.data, equals(tPost1.title)),
      );
    });
  });

  // ── Error responses ────────────────────────────────────────────

  group('error responses', () {
    test('404 with message → Left(ValidationFailure)', () async {
      final client = buildClient(
          mockHttpClient(404, {'message': 'Post not found'}));

      final result = await client.request(
        '/posts/999', MethodType.get, (d) => d, {},
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) {
          expect(l, isA<ValidationFailure>());
          expect(l.failureMessage(), contains('Post not found'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('422 validation error → Left(ValidationFailure)', () async {
      final client = buildClient(
          mockHttpClient(422, {'message': 'Validation failed', 'errors': {}}));

      final result = await client.request(
        '/posts', MethodType.post, (d) => d, {},
      );

      expect(result.isLeft(), isTrue);
    });

    test('500 server error → Left(ValidationFailure or ServerFailure)',
        () async {
      final client = buildClient(
          mockHttpClient(500, {'message': 'Internal server error'}));

      final result = await client.request(
        '/posts', MethodType.get, (d) => d, {},
      );

      expect(result.isLeft(), isTrue);
    });

    test('network exception → Left(InternetFailure or ConnectionTimeOutFailure)',
        () async {
      final throwingClient = http_test.MockClient(
        (_) async => throw http.ClientException('No connection'),
      );
      final client = HttpApiClient(
        networkInfo: MockNetworkInfo(),
        client:      throwingClient,
      );

      final result = await client.request(
        '/posts', MethodType.get, (d) => d, {},
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<Failure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  // ── Bearer token ───────────────────────────────────────────────

  group('bearer token', () {
    test('sends Authorization header when token is set', () async {
      String? capturedAuth;

      final capturingClient = http_test.MockClient((request) async {
        capturedAuth = request.headers['Authorization'];
        return http.Response(jsonEncode(tPostEnvelope), 200);
      });

      final client = HttpApiClient(
        networkInfo: MockNetworkInfo(),
        client:      capturingClient,
      );
      client.setBearerToken('test-token-123');

      await client.request('/posts', MethodType.get, (d) => d, {});

      expect(capturedAuth, equals('Bearer test-token-123'));
    });
  });
}
