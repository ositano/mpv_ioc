// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/core/api/services/api_services_impl_test.dart
//
// ApiServicesImpl is a mapping layer between domain methods and HTTP calls.
// Tests verify the correct URL, MethodType, and parameters are forwarded
// to IApiClient — not the HTTP response itself (that's DioApiClient's job).

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/core/api/services/api_services_impl.dart';
import 'package:mpv_ioc/core/enums/enums.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

// Capture the url and method passed to apiClient.request
const _any = TypeMatcher<dynamic>();

void main() {
  late MockIApiClient mockClient;
  late ApiServicesImpl services;

  setUp(() {
    mockClient = MockIApiClient();
    services   = ApiServicesImpl(apiClient: mockClient);
  });

  // Stub helper — returns tPostsRight for any request call
  void stubRequest() {
    when(mockClient.request<dynamic>(
            any, any, any, any,
            queryParameters: anyNamed('queryParameters'),
            interceptor:     anyNamed('interceptor')))
        .thenAnswer((_) async => tPostsRight);
  }

  group('getPosts', () {
    test('calls request with /posts and GET', () async {
      stubRequest();
      await services.getPosts();

      final captured = verify(mockClient.request<dynamic>(
        captureAny, captureAny, any, any,
        queryParameters: anyNamed('queryParameters'),
        interceptor:     anyNamed('interceptor'),
      )).captured;

      expect(captured[0], equals('/posts'));
      expect(captured[1], equals(MethodType.get));
    });
  });

  group('getPost', () {
    test('calls request with /posts/1 and GET', () async {
      when(mockClient.request<dynamic>(
              any, any, any, any,
              queryParameters: anyNamed('queryParameters'),
              interceptor:     anyNamed('interceptor')))
          .thenAnswer((_) async => tPostRight);

      await services.getPost(1);

      final captured = verify(mockClient.request<dynamic>(
        captureAny, captureAny, any, any,
        queryParameters: anyNamed('queryParameters'),
        interceptor:     anyNamed('interceptor'),
      )).captured;

      expect(captured[0], equals('/posts/1'));
      expect(captured[1], equals(MethodType.get));
    });
  });

  group('createPost', () {
    test('calls request with /posts and POST with correct body', () async {
      when(mockClient.request<dynamic>(
              any, any, any, any,
              queryParameters: anyNamed('queryParameters'),
              interceptor:     anyNamed('interceptor')))
          .thenAnswer((_) async => tNewPostRight);

      await services.createPost(title: 'T', body: 'B', userId: 1);

      final captured = verify(mockClient.request<dynamic>(
        captureAny, captureAny, any, captureAny,
        queryParameters: anyNamed('queryParameters'),
        interceptor:     anyNamed('interceptor'),
      )).captured;

      expect(captured[0], equals('/posts'));
      expect(captured[1], equals(MethodType.post));
      expect((captured[2] as Map)['title'], equals('T'));
      expect((captured[2] as Map)['body'],  equals('B'));
      expect((captured[2] as Map)['userId'], equals(1));
    });
  });

  group('updatePost', () {
    test('calls request with /posts/1 and PUT', () async {
      when(mockClient.request<dynamic>(
              any, any, any, any,
              queryParameters: anyNamed('queryParameters'),
              interceptor:     anyNamed('interceptor')))
          .thenAnswer((_) async => tUpdatedPostRight);

      await services.updatePost(id: 1, title: 'Up', body: 'Bd');

      final captured = verify(mockClient.request<dynamic>(
        captureAny, captureAny, any, any,
        queryParameters: anyNamed('queryParameters'),
        interceptor:     anyNamed('interceptor'),
      )).captured;

      expect(captured[0], equals('/posts/1'));
      expect(captured[1], equals(MethodType.put));
    });
  });

  group('deletePost', () {
    test('calls request with /posts/1 and DELETE', () async {
      when(mockClient.request<dynamic>(
              any, any, any, any,
              queryParameters: anyNamed('queryParameters'),
              interceptor:     anyNamed('interceptor')))
          .thenAnswer((_) async => tDeleteRight);

      await services.deletePost(1);

      final captured = verify(mockClient.request<dynamic>(
        captureAny, captureAny, any, any,
        queryParameters: anyNamed('queryParameters'),
        interceptor:     anyNamed('interceptor'),
      )).captured;

      expect(captured[0], equals('/posts/1'));
      expect(captured[1], equals(MethodType.delete));
    });
  });
}
