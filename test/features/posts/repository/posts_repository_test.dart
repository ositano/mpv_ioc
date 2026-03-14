// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/repository/posts_repository_test.dart
//
// PostsRepositoryImpl is a thin delegation layer — tests verify
// it calls the correct ApiServices method with the correct arguments.

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/features/posts/repository/posts_repository.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';

void main() {
  late MockApiServices mockServices;
  late PostsRepositoryImpl repo;

  setUp(() {
    mockServices = MockApiServices();
    repo = PostsRepositoryImpl(apiServices: mockServices);
  });

  group('getPosts', () {
    test('delegates to apiServices.getPosts', () async {
      when(mockServices.getPosts())
          .thenAnswer((_) async => tPostsRight);

      final result = await repo.getPosts();

      verify(mockServices.getPosts()).called(1);
      expect(result, equals(tPostsRight));
    });
  });

  group('getPost', () {
    test('delegates to apiServices.getPost with correct id', () async {
      when(mockServices.getPost(1))
          .thenAnswer((_) async => tPostRight);

      final result = await repo.getPost(1);

      verify(mockServices.getPost(1)).called(1);
      expect(result, equals(tPostRight));
    });
  });

  group('createPost', () {
    test('delegates with correct title and body', () async {
      when(mockServices.createPost(
              title:  anyNamed('title'),
              body:   anyNamed('body'),
              userId: anyNamed('userId')))
          .thenAnswer((_) async => tNewPostRight);

      await repo.createPost(title: 'New', body: 'Body');

      verify(mockServices.createPost(
        title:  'New',
        body:   'Body',
        userId: 1,
      )).called(1);
    });
  });

  group('updatePost', () {
    test('delegates with id, title, body', () async {
      when(mockServices.updatePost(
              id:    anyNamed('id'),
              title: anyNamed('title'),
              body:  anyNamed('body')))
          .thenAnswer((_) async => tUpdatedPostRight);

      await repo.updatePost(id: 1, title: 'Updated', body: 'New body');

      verify(mockServices.updatePost(
        id: 1, title: 'Updated', body: 'New body',
      )).called(1);
    });
  });

  group('deletePost', () {
    test('delegates with correct id', () async {
      when(mockServices.deletePost(1))
          .thenAnswer((_) async => tDeleteRight);

      await repo.deletePost(1);

      verify(mockServices.deletePost(1)).called(1);
    });
  });
}
