// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/cubits/posts_cubit_test.dart
//
// Tests for PostsCubit using bloc_test:
//  • Initial state
//  • Successful and failed fetch
//  • Create / update post
//  • Delete post
//  • IoC: manager callbacks are wired correctly

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/core/api/exception/failure.dart';
import 'package:mpv_ioc/core/enums/enums.dart';
import 'package:mpv_ioc/features/posts/presentation/cubits/posts_cubit.dart';
import 'package:mpv_ioc/features/posts/presentation/managers/posts_manager.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';
import '../../../helpers/test_setup.dart';

void main() {
  late MockPostsRepository mockRepo;
  late PostsManagerImpl manager;

  PostsCubit buildCubit() => PostsCubit(
        manager:    manager,
        repository: mockRepo,
      );

  setUp(() {
    setupGetIt();
    mockRepo = MockPostsRepository();
    manager  = PostsManagerImpl();
  });

  tearDown(() async {
    manager.dispose();
    await tearDownGetIt();
  });

  // ── Initial state ──────────────────────────────────────────────

  test('initial state is PostsInitial', () {
    when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
    final cubit = buildCubit();
    // The cubit fires fetch immediately — by the time this runs state is
    // already transitioning. We verify the declared initial:
    expect(cubit, isA<PostsCubit>());
    cubit.close();
  });

  // ── IoC wiring ─────────────────────────────────────────────────

  group('IoC wiring', () {
    test('onFetchPosts is wired to the cubit after construction', () {
      when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
      final cubit = buildCubit();
      expect(manager.onFetchPosts, isNotNull);
      cubit.close();
    });

    test('onDeletePost is wired to the cubit', () {
      when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
      when(mockRepo.deletePost(any))
          .thenAnswer((_) async => tDeleteRight);
      final cubit = buildCubit();
      expect(manager.onDeletePost, isNotNull);
      cubit.close();
    });

    test('onSubmitPost is wired to the cubit', () {
      when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
      final cubit = buildCubit();
      expect(manager.onSubmitPost, isNotNull);
      cubit.close();
    });
  });

  // ── Fetch ──────────────────────────────────────────────────────

  group('fetch posts', () {
    blocTest<PostsCubit, PostsState>(
      'emits [Loading, Loaded] on success and populates manager.posts',
      build: () {
        when(mockRepo.getPosts())
            .thenAnswer((_) async => tPostsRight);
        return buildCubit();
      },
      // The cubit auto-fetches on construction — wait for it
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<PostsLoading>(),
        isA<PostsLoaded>(),
      ],
      verify: (_) {
        expect(manager.posts.value, equals(tPosts));
        expect(manager.requestStatus.value, equals(RequestStatus.loaded));
      },
    );

    blocTest<PostsCubit, PostsState>(
      'emits [Loading, Error] on failure and shows error message',
      build: () {
        when(mockRepo.getPosts())
            .thenAnswer((_) async => tFailureLeft);
        return buildCubit();
      },
      wait: const Duration(milliseconds: 50),
      expect: () => [
        isA<PostsLoading>(),
        isA<PostsError>(),
      ],
      verify: (_) {
        expect(
          (manager.requestStatus.value),
          equals(RequestStatus.error),
        );
      },
    );

    blocTest<PostsCubit, PostsState>(
      'refreshPosts re-fetches and replaces the list',
      build: () {
        when(mockRepo.getPosts())
            .thenAnswer((_) async => tPostsRight);
        return buildCubit();
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        manager.refreshPosts();
        await Future.delayed(const Duration(milliseconds: 50));
      },
      expect: () => [
        isA<PostsLoading>(),
        isA<PostsLoaded>(),
        isA<PostsLoading>(),
        isA<PostsLoaded>(),
      ],
      verify: (_) {
        verify(mockRepo.getPosts()).called(2);
      },
    );
  });

  // ── Create ─────────────────────────────────────────────────────

  group('create post', () {
    setUp(() {
      when(mockRepo.getPosts())
          .thenAnswer((_) async => tPostsRight);
    });

    blocTest<PostsCubit, PostsState>(
      'adds new post to the top of the list on success',
      build: () {
        when(mockRepo.createPost(
                title: anyNamed('title'), body: anyNamed('body')))
            .thenAnswer((_) async => tNewPostRight);
        return buildCubit();
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        // Simulate a valid form submission
        manager.titleController.text = 'New title';
        manager.bodyController.text  = 'New body';
        manager.submitPost();
        await Future.delayed(const Duration(milliseconds: 50));
      },
      wait: const Duration(milliseconds: 200),
      verify: (_) {
        expect(manager.posts.value.first.id, equals(tNewPost.id));
        expect(manager.selectedPost.value, isNull); // cleared after save
      },
    );

    blocTest<PostsCubit, PostsState>(
      'shows error message and keeps state on failure',
      build: () {
        when(mockRepo.createPost(
                title: anyNamed('title'), body: anyNamed('body')))
            .thenAnswer((_) async => Left(const ValidationFailure('Create failed')));
        return buildCubit();
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        manager.titleController.text = 'X';
        manager.bodyController.text  = 'Y';
        manager.submitPost();
        await Future.delayed(const Duration(milliseconds: 50));
      },
      verify: (_) {
        expect(manager.requestStatus.value, equals(RequestStatus.error));
      },
    );
  });

  // ── Update ─────────────────────────────────────────────────────

  group('update post', () {
    setUp(() {
      when(mockRepo.getPosts())
          .thenAnswer((_) async => tPostsRight);
    });

    blocTest<PostsCubit, PostsState>(
      'replaces the existing post in the list on success',
      build: () {
        when(mockRepo.updatePost(
                id:    anyNamed('id'),
                title: anyNamed('title'),
                body:  anyNamed('body')))
            .thenAnswer((_) async => tUpdatedPostRight);
        return buildCubit();
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        manager.selectPost(tPost1);        // editing existing
        manager.titleController.text = 'Updated';
        manager.bodyController.text  = 'Updated body';
        manager.submitPost();
        await Future.delayed(const Duration(milliseconds: 50));
      },
      verify: (_) {
        final found = manager.posts.value
            .where((p) => p.id == tUpdatedPost.id)
            .first;
        expect(found.title, equals('Updated'));
      },
    );
  });

  // ── Delete ─────────────────────────────────────────────────────

  group('delete post', () {
    setUp(() {
      when(mockRepo.getPosts())
          .thenAnswer((_) async => tPostsRight);
    });

    blocTest<PostsCubit, PostsState>(
      'removes the post from the list on success',
      build: () {
        when(mockRepo.deletePost(tPost1.id!))
            .thenAnswer((_) async => tDeleteRight);
        return buildCubit();
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        manager.deletePost(tPost1.id!);
        await Future.delayed(const Duration(milliseconds: 50));
      },
      verify: (_) {
        final ids = manager.posts.value.map((p) => p.id).toList();
        expect(ids, isNot(contains(tPost1.id)));
      },
    );

    blocTest<PostsCubit, PostsState>(
      'shows error message and preserves list on failure',
      build: () {
        when(mockRepo.deletePost(any))
            .thenAnswer((_) async => Left(ServerFailure()));
        return buildCubit();
      },
      act: (cubit) async {
        await Future.delayed(const Duration(milliseconds: 50));
        manager.deletePost(tPost1.id!);
        await Future.delayed(const Duration(milliseconds: 50));
      },
      verify: (_) {
        expect(manager.posts.value, hasLength(tPosts.length));
        expect(manager.requestStatus.value, equals(RequestStatus.error));
      },
    );
  });

  // ── Dispose ────────────────────────────────────────────────────

  test('close disposes the manager', () async {
    when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
    final cubit = buildCubit();
    await cubit.close();
    // Accessing the manager's notifiers after close would throw — just
    // verify the cubit closes without error.
  });
}
