// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/presentation/riverpod/posts_provider.dart
//
// ─────────────────────────────────────────────────────────────────
//  Riverpod providers for the Posts feature.
//
//  Key design decisions:
//
//  1. No GetIt calls here.
//     The providers declare abstract/interface types.
//     The concrete implementations are injected via ProviderScope
//     overrides in app.dart (bridged from GetIt once at startup).
//
//  2. Same PostsRepository and PostsManager as the Cubit feature.
//     Zero duplication of business logic.
//
//  3. PostsNotifier uses the same IoC callback pattern as PostsCubit:
//     manager.onFetchPosts = _fetchPosts;
//     This means the Manager is completely state-manager-agnostic.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/data/models/post.dart';
import '../../../../core/enums/enums.dart';
import '../../repository/posts_repository.dart';
import '../managers/posts_manager.dart';

// ── Abstract providers ────────────────────────────────────────────
// These throw by default; they MUST be overridden in ProviderScope.
// See app.dart → ProviderScope(overrides: AppInitializer.riverpodOverrides)

final postsRepositoryProvider = Provider<PostsRepository>(
  (ref) => throw UnimplementedError(
    'postsRepositoryProvider must be overridden in ProviderScope',
  ),
);

final postsManagerProvider = Provider<PostsManager>(
  (ref) {
    final manager = PostsManagerImpl();
    ref.onDispose(manager.dispose);
    return manager;
  },
);

// ── StateNotifier ─────────────────────────────────────────────────

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  final PostsRepository repository;
  final PostsManager manager;

  PostsNotifier({required this.repository, required this.manager})
      : super(const AsyncValue.loading()) {
    // ── IoC: same pattern as PostsCubit ──────────────────────────
    manager.onFetchPosts = _fetchPosts;
    manager.onDeletePost = _deletePost;
    manager.onSubmitPost = _submitPost;
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    state = const AsyncValue.loading();
    manager.requestStatus.value = RequestStatus.loading;

    final result = await repository.getPosts();
    result.fold(
      (failure) {
        manager.requestStatus.value = RequestStatus.error;
        manager.showUiMessage(failure.failureMessage());
        state = AsyncValue.error(failure.failureMessage(), StackTrace.current);
      },
      (response) {
        final posts = response.data ?? [];
        manager.posts.value = posts;
        manager.requestStatus.value = RequestStatus.loaded;
        state = AsyncValue.data(posts);
      },
    );
  }

  Future<void> _submitPost() async {
    manager.requestStatus.value = RequestStatus.loading;
    final title    = manager.getFieldValue<String>('title');
    final body     = manager.getFieldValue<String>('body');
    final existing = manager.selectedPost.value;

    final result = existing != null
        ? await repository.updatePost(
            id: existing.id!, title: title, body: body)
        : await repository.createPost(title: title, body: body);

    result.fold(
      (failure) {
        manager.requestStatus.value = RequestStatus.error;
        manager.showUiMessage(failure.failureMessage());
      },
      (response) {
        final post    = response.data!;
        final current = state.valueOrNull ?? [];
        final updated = existing != null
            ? current.map((p) => p.id == post.id ? post : p).toList()
            : [post, ...current];

        manager.posts.value             = updated;
        state                           = AsyncValue.data(updated);
        manager.requestStatus.value     = RequestStatus.loaded;
        manager.showUiMessage(
          existing != null ? 'Post updated!' : 'Post created!',
          messageType: MessageType.success,
        );
        manager.clearSelection();
        manager.onBackPressed();
      },
    );
  }

  Future<void> _deletePost(int id) async {
    manager.requestStatus.value = RequestStatus.loading;

    final result = await repository.deletePost(id);
    result.fold(
      (failure) {
        manager.requestStatus.value = RequestStatus.error;
        manager.showUiMessage(failure.failureMessage());
      },
      (_) {
        final updated =
            (state.valueOrNull ?? []).where((p) => p.id != id).toList();
        manager.posts.value         = updated;
        state                       = AsyncValue.data(updated);
        manager.requestStatus.value = RequestStatus.loaded;
        manager.showUiMessage('Deleted', messageType: MessageType.success);
      },
    );
  }
}

// ── StateNotifierProvider ─────────────────────────────────────────

final postsNotifierProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier(
    repository: ref.watch(postsRepositoryProvider),
    manager:    ref.watch(postsManagerProvider),
  );
});
