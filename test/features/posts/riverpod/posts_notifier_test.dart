// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/riverpod/posts_notifier_test.dart
//
// Tests for PostsNotifier (Riverpod).
// Uses ProviderContainer with overrides so providers receive mock
// repositories — no GetIt involved in provider files.

import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/core/api/exception/failure.dart';
import 'package:mpv_ioc/core/data/models/post.dart';
import 'package:mpv_ioc/core/enums/enums.dart';
import 'package:mpv_ioc/features/posts/presentation/riverpod/posts_provider.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_data.dart';
import '../../../helpers/test_setup.dart';

// ── Helper: build a ProviderContainer with repo override ──────────

ProviderContainer makeContainer(MockPostsRepository repo) {
  return ProviderContainer(
    overrides: [
      postsRepositoryProvider.overrideWith((_) => repo),
    ],
  );
}

void main() {
  late MockPostsRepository mockRepo;

  setUp(() {
    setupGetIt();
    mockRepo = MockPostsRepository();
  });

  tearDown(() async {
    await tearDownGetIt();
  });

  // ── IoC wiring ─────────────────────────────────────────────────

  test('IoC callbacks are wired after notifier construction', () async {
    when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
    final container = makeContainer(mockRepo);
    addTearDown(container.dispose);

    container.read(postsNotifierProvider); // triggers construction
    await Future.delayed(const Duration(milliseconds: 50));

    final manager = container.read(postsManagerProvider);
    expect(manager.onFetchPosts, isNotNull);
    expect(manager.onDeletePost, isNotNull);
    expect(manager.onSubmitPost, isNotNull);
  });

  // ── Fetch ──────────────────────────────────────────────────────

  group('fetch posts', () {
    test('transitions from loading to data on success', () async {
      when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      // Initial state is loading
      expect(
        container.read(postsNotifierProvider),
        isA<AsyncLoading<List<Post>>>(),
      );

      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(postsNotifierProvider);
      expect(state, isA<AsyncData<List<Post>>>());
      expect(state.valueOrNull, equals(tPosts));
    });

    test('transitions to AsyncError on failure', () async {
      when(mockRepo.getPosts()).thenAnswer((_) async => tFailureLeft);
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      await Future.delayed(const Duration(milliseconds: 50));

      final state = container.read(postsNotifierProvider);
      expect(state, isA<AsyncError<List<Post>>>());
    });

    test('populates manager.posts on success', () async {
      when(mockRepo.getPosts()).thenAnswer((_) async => tPostsRight);
      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      await Future.delayed(const Duration(milliseconds: 50));

      final manager = container.read(postsManagerProvider);
      expect(manager.posts.value, equals(tPosts));
      expect(manager.requestStatus.value, equals(RequestStatus.loaded));
    });
  });

  // ── Create ─────────────────────────────────────────────────────

  group('create post', () {
    test('prepends new post to state and manager list', () async {
      when(mockRepo.getPosts())
          .thenAnswer((_) async => tPostsRight);
      when(mockRepo.createPost(
              title: anyNamed('title'), body: anyNamed('body')))
          .thenAnswer((_) async => tNewPostRight);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      await Future.delayed(const Duration(milliseconds: 50));

      final manager = container.read(postsManagerProvider);
      manager.titleController.text = 'New title';
      manager.bodyController.text  = 'New body';
      manager.submitPost();

      await Future.delayed(const Duration(milliseconds: 50));

      final ids = (container.read(postsNotifierProvider).valueOrNull ?? [])
          .map((p) => p.id)
          .toList();
      expect(ids, contains(tNewPost.id));
    });
  });

  // ── Update ─────────────────────────────────────────────────────

  group('update post', () {
    test('replaces the post in state and manager list', () async {
      when(mockRepo.getPosts())
          .thenAnswer((_) async => tPostsRight);
      when(mockRepo.updatePost(
              id:    anyNamed('id'),
              title: anyNamed('title'),
              body:  anyNamed('body')))
          .thenAnswer((_) async => tUpdatedPostRight);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      await Future.delayed(const Duration(milliseconds: 50));

      final manager = container.read(postsManagerProvider);
      manager.selectPost(tPost1);
      manager.titleController.text = 'Updated';
      manager.bodyController.text  = 'Updated body';
      manager.submitPost();

      await Future.delayed(const Duration(milliseconds: 50));

      final updated = (container.read(postsNotifierProvider).valueOrNull ?? [])
          .firstWhere((p) => p.id == tPost1.id);
      expect(updated.title, equals('Updated'));
    });
  });

  // ── Delete ─────────────────────────────────────────────────────

  group('delete post', () {
    test('removes the post from state and manager list', () async {
      when(mockRepo.getPosts())
          .thenAnswer((_) async => tPostsRight);
      when(mockRepo.deletePost(tPost1.id!))
          .thenAnswer((_) async => tDeleteRight);

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      await Future.delayed(const Duration(milliseconds: 50));

      final manager = container.read(postsManagerProvider);
      manager.deletePost(tPost1.id!);

      await Future.delayed(const Duration(milliseconds: 50));

      final ids = (container.read(postsNotifierProvider).valueOrNull ?? [])
          .map((p) => p.id)
          .toList();
      expect(ids, isNot(contains(tPost1.id)));
    });

    test('emits error message and preserves list on failure', () async {
      when(mockRepo.getPosts())
          .thenAnswer((_) async => tPostsRight);
      when(mockRepo.deletePost(any))
          .thenAnswer((_) async => Left(ServerFailure()));

      final container = makeContainer(mockRepo);
      addTearDown(container.dispose);

      await Future.delayed(const Duration(milliseconds: 50));

      final manager = container.read(postsManagerProvider);
      manager.deletePost(tPost1.id!);

      await Future.delayed(const Duration(milliseconds: 50));

      expect(
        container.read(postsNotifierProvider).valueOrNull,
        hasLength(tPosts.length),
      );
    });
  });
}
