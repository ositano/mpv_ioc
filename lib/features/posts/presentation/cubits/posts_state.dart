// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/presentation/cubits/posts_state.dart
//
// Minimal state — the Manager's ValueNotifiers carry the real UI
// state. The Cubit state only tracks lifecycle transitions.

part of 'posts_cubit.dart';

abstract class PostsState {
  const PostsState();
}
class PostsInitial  extends PostsState { const PostsInitial(); }
class PostsLoading  extends PostsState { const PostsLoading(); }
class PostsLoaded   extends PostsState { const PostsLoaded(); }
class PostsError    extends PostsState {
  final String message;
  const PostsError(this.message);
}
