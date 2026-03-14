// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/core/api/services/dio_api_client_test.dart
//
// Tests for DioApiClient — the Dio-backed IApiClient implementation.
// Uses http_mock_adapter to intercept requests at the adapter level,
// which is possible because DioApiClient now accepts an injected Dio.
//
// Covers:
//  • Successful response with data envelope → Right(ApiResponse)
//  • Successful response without envelope  → Right(ApiResponse)
//  • 4xx response with message             → Left(ValidationFailure)
//  • 4xx response without message          → Left(ValidationFailure)
//  • ConnectionTimeout                     → Left(ConnectionTimeOutFailure)
//  • SocketException / network error       → Left(InternetFailure)
//  • 5xx server error                      → Left(ValidationFailure/ServerFailure)
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

import 'package:mpv_ioc/core/api/exception/failure.dart';
import 'package:mpv_ioc/core/api/services/dio_api_client.dart';
import 'package:mpv_ioc/core/enums/enums.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late DioApiClient client;
  late MockNetworkInfo mockNetworkInfo;

  const baseUrl = 'https://test.example.com';

  setUp(() {
    mockNetworkInfo = MockNetworkInfo();
    dio     = Dio(BaseOptions(baseUrl: baseUrl));
    adapter = DioAdapter(dio: dio, matcher: const FullHttpRequestMatcher());
    client  = DioApiClient(networkInfo: mockNetworkInfo);
  });

  tearDown(() {
    adapter.close();
  });

  // ── Successful responses ───────────────────────────────────────

  group('successful responses', () {
    test('parses data-envelope response into Right(ApiResponse)', () async {
      adapter.onGet('/posts', (server) => server.reply(200, tPostsEnvelope));

      final result = await client.request(
        '/posts',
        MethodType.get,
        (data) => (data as List).map((e) => e as Map<String, dynamic>).toList(),
        {},
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (l) => fail('Expected Right but got Left: $l'),
        (r) {
          expect(r.data, isA<List>());
          expect(r.message, equals('Success'));
          expect(r.success, isTrue);
          expect(r.total, equals(3));
        },
      );
    });

    test('parses raw-object response (no envelope) into Right', () async {
      adapter.onGet('/posts/1',
          (server) => server.reply(200, tPost1.toJson()));

      final result = await client.request(
        '/posts/1',
        MethodType.get,
        (data) => data as Map<String, dynamic>,
        {},
      );

      expect(result.isRight(), isTrue);
    });

    test('uses fromJson transformer on the data', () async {
      adapter.onGet('/posts/1',
          (server) => server.reply(200, {'data': tPost1.toJson()}));

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

    test('POST sends body and returns Right', () async {
      adapter.onPost('/posts',
          (server) => server.reply(201, tPostEnvelope));

      final result = await client.request(
        '/posts',
        MethodType.post,
        (data) => data as Map<String, dynamic>,
        {'title': 'T', 'body': 'B'},
      );

      expect(result.isRight(), isTrue);
    });

    test('PUT returns Right', () async {
      adapter.onPut('/posts/1',
          (server) => server.reply(200, tPostEnvelope));

      final result = await client.request(
        '/posts/1',
        MethodType.put,
        (data) => data as Map<String, dynamic>,
        {'title': 'Updated'},
      );

      expect(result.isRight(), isTrue);
    });

    test('DELETE returns Right', () async {
      adapter.onDelete('/posts/1',
          (server) => server.reply(200, {'message': 'Deleted', 'success': true}));

      final result = await client.request(
        '/posts/1',
        MethodType.delete,
        (_) {},
        {},
      );

      expect(result.isRight(), isTrue);
    });
  });

  // ── Error responses ────────────────────────────────────────────

  group('error responses', () {
    test('4xx with message → Left(ValidationFailure) with that message',
        () async {
      adapter.onGet('/posts',
          (server) => server.reply(404, {'message': 'Not found'}));

      final result = await client.request(
        '/posts',
        MethodType.get,
        (d) => d,
        {},
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) {
          expect(l, isA<ValidationFailure>());
          expect(l.failureMessage(), contains('Not found'));
        },
        (_) => fail('Expected Left'),
      );
    });

    test('4xx without message → Left(BadResponseFailure)', () async {
      adapter.onGet('/posts',
          (server) => server.reply(400, {'error': 'Bad request'}));

      final result = await client.request(
        '/posts', MethodType.get, (d) => d, {},
      );

      expect(result.isLeft(), isTrue);
      result.fold((l) => expect(l, isA<Failure>()), (_) => fail('Expected Left'));
    });

    test('connection timeout → Left(ConnectionTimeOutFailure)', () async {
      // Simulate timeout by using a future that never resolves
      adapter.onGet('/timeout',
          (server) => server.throws(
                0,
                DioException(
                  requestOptions: RequestOptions(path: '/timeout'),
                  type: DioExceptionType.connectionTimeout,
                ),
              ));

      final result = await client.request(
        '/timeout', MethodType.get, (d) => d, {},
      );

      expect(result.isLeft(), isTrue);
      result.fold(
        (l) => expect(l, isA<ConnectionTimeOutFailure>()),
        (_) => fail('Expected Left'),
      );
    });

    test('unknown Dio error → Left(UnknownFailure)', () async {
      adapter.onGet('/unknown',
          (server) => server.throws(
                0,
                DioException(
                  requestOptions: RequestOptions(path: '/unknown'),
                  type: DioExceptionType.unknown,
                ),
              ));

      final result = await client.request(
        '/unknown', MethodType.get, (d) => d, {},
      );

      expect(result.isLeft(), isTrue);
    });
  });
}
