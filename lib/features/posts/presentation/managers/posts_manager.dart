// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/presentation/managers/posts_manager.dart
//
// ─────────────────────────────────────────────────────────────────
//  MANAGER = presentation logic without Flutter widgets.
//
//  • Holds UI state as ValueNotifiers (no Cubit/Riverpod dependency).
//  • Owns form fields via the inherited StateManager.
//  • Navigation emitted as stream events via RouteHelper/NavigationService
//    — no BuildContext required.
//  • IoC callbacks (onFetchPosts, onDeletePost, onSubmitPost) are
//    assigned by whichever orchestrator (Cubit / StateNotifier) is
//    active. The Manager never imports either.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../core/data/models/post.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/manager/state_manager.dart';
import '../../../../core/routes/route_constants.dart';

// ── Abstract contract (what the View sees) ─────────────────────────
abstract class PostsManager extends StateManager {
  ValueNotifier<List<Post>> get posts;
  ValueNotifier<Post?> get selectedPost;
  TextEditingController get titleController;
  TextEditingController get bodyController;

  // IoC hooks — assigned by the orchestrator (Cubit or StateNotifier)
  VoidCallback? onFetchPosts;
  void Function(int id)? onDeletePost;
  VoidCallback? onSubmitPost;

  void refreshPosts();
  void selectPost(Post post);
  void clearSelection();
  void submitPost();
  void deletePost(int id);
  void showPostDetail(Post post);
}

// ── Concrete implementation ─────────────────────────────────────────
class PostsManagerImpl extends StateManager implements PostsManager {
  @override late final ValueNotifier<List<Post>> posts;
  @override late final ValueNotifier<Post?> selectedPost;
  @override late final TextEditingController titleController;
  @override late final TextEditingController bodyController;

  @override VoidCallback? onFetchPosts;
  @override void Function(int)? onDeletePost;
  @override VoidCallback? onSubmitPost;

  PostsManagerImpl() {
    posts           = ValueNotifier<List<Post>>([]);
    selectedPost    = ValueNotifier<Post?>(null);
    titleController = TextEditingController();
    bodyController  = TextEditingController();
    _initFields();
    _syncControllersToFields();
  }

  void _initFields() {
    addField<String>(
      fieldName: 'title',
      initialValue: '',
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Title is required' : null,
    );
    addField<String>(
      fieldName: 'body',
      initialValue: '',
      validator: (v) =>
          (v == null || v.trim().isEmpty) ? 'Body is required' : null,
    );
  }

  void _syncControllersToFields() {
    titleController
        .addListener(() => updateField('title', titleController.text));
    bodyController
        .addListener(() => updateField('body', bodyController.text));
  }

  @override
  void refreshPosts() => onFetchPosts?.call();

  @override
  void selectPost(Post post) {
    selectedPost.value  = post;
    titleController.text = post.title;
    bodyController.text  = post.body;
    updateField('title', post.title);
    updateField('body', post.body);
  }

  @override
  void clearSelection() {
    selectedPost.value = null;
    titleController.clear();
    bodyController.clear();
    resetForm();
  }

  @override
  void submitPost() {
    markAllAsTouched();
    if (isValid().value) onSubmitPost?.call();
  }

  @override
  void deletePost(int id) => onDeletePost?.call(id);

  @override
  void showPostDetail(Post post) {
    // Uses navigateTo (which emits a NavEvent on the NavigationService stream).
    // ViewListenerWidget catches it and calls context.goNamed(...) — no
    // BuildContext needed here.
    navigateTo(RouteConstants.postDetail, extra: post, routeLevel: RouteLevel.top);
  }

  @override
  void dispose() {
    posts.dispose();
    selectedPost.dispose();
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }
}
