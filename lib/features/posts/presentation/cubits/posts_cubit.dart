// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/presentation/cubits/posts_cubit.dart
//
// ─────────────────────────────────────────────────────────────────
//  CUBIT = business logic orchestrator.
//
//  • Calls the Repository (no knowledge of HTTP client).
//  • Writes results into the Manager's ValueNotifiers.
//  • Assigns IoC callbacks on the Manager so the Manager can
//    trigger business logic without depending on the Cubit directly.
//
//  The View never calls the Cubit directly — it calls manager methods.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/enums.dart';
import '../../repository/posts_repository.dart';
import '../managers/posts_manager.dart';

part 'posts_state.dart';

class PostsCubit extends Cubit<PostsState> {
  final PostsManager manager;
  final PostsRepository repository;

  PostsCubit({required this.manager, required this.repository})
      : super(const PostsInitial()) {
    // ── Inversion of Control: assign callbacks ─────────────────────
    manager.onFetchPosts  = _fetchPosts;
    manager.onDeletePost  = _deletePost;
    manager.onSubmitPost  = _submitPost;
    // ── Kick off initial load ──────────────────────────────────────
    _fetchPosts();
  }

  // ── Fetch ────────────────────────────────────────────────────────
  Future<void> _fetchPosts() async {
    emit(const PostsLoading());
    manager.requestStatus.value = RequestStatus.loading;

    final result = await repository.getPosts();

    result.fold(
      (failure) {
        manager.requestStatus.value = RequestStatus.error;
        manager.showUiMessage(failure.failureMessage());
        emit(PostsError(failure.failureMessage()));
      },
      (response) {
        manager.posts.value = response.data ?? [];
        manager.requestStatus.value = RequestStatus.loaded;
        emit(const PostsLoaded());
      },
    );
  }

  // ── Create / Update ───────────────────────────────────────────────
  Future<void> _submitPost() async {
    manager.requestStatus.value = RequestStatus.loading;
    final title = manager.getFieldValue<String>('title');
    final body  = manager.getFieldValue<String>('body');
    final existingPost = manager.selectedPost.value;

    final result = existingPost != null
        ? await repository.updatePost(
            id: existingPost.id!, title: title, body: body)
        : await repository.createPost(title: title, body: body);

    result.fold(
      (failure) {
        manager.requestStatus.value = RequestStatus.error;
        manager.showUiMessage(failure.failureMessage());
      },
      (response) {
        final post = response.data!;
        if (existingPost != null) {
          // Replace in list
          final updated = manager.posts.value
              .map((p) => p.id == post.id ? post : p)
              .toList();
          manager.posts.value = updated;
        } else {
          manager.posts.value = [post, ...manager.posts.value];
        }
        manager.requestStatus.value = RequestStatus.loaded;
        manager.showUiMessage(
          existingPost != null ? 'Post updated!' : 'Post created!',
          messageType: MessageType.success,
        );
        manager.clearSelection();
        manager.onBackPressed();
      },
    );
  }

  // ── Delete ────────────────────────────────────────────────────────
  Future<void> _deletePost(int id) async {
    manager.requestStatus.value = RequestStatus.loading;

    final result = await repository.deletePost(id);

    result.fold(
      (failure) {
        manager.requestStatus.value = RequestStatus.error;
        manager.showUiMessage(failure.failureMessage());
      },
      (_) {
        manager.posts.value =
            manager.posts.value.where((p) => p.id != id).toList();
        manager.requestStatus.value = RequestStatus.loaded;
        manager.showUiMessage('Post deleted', messageType: MessageType.success);
      },
    );
  }

  @override
  Future<void> close() {
    manager.dispose();
    return super.close();
  }
}
