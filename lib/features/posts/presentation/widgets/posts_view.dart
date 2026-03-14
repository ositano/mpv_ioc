// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/presentation/widgets/posts_view.dart
//
// ─────────────────────────────────────────────────────────────────
//  PostsView — the pure UI layer.
//
//  Receives a PostsManager. Knows nothing about:
//    • Which HTTP client is active  (Dio / http)
//    • Which state manager is active (Cubit / Riverpod)
//    • Which router is active        (GoRouter / AutoRoute)
//
//  Used by both PostsCubitScreen and PostsRiverpodScreen unchanged.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import '../../../../core/components/view_listener_widget.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../managers/posts_manager.dart';
import 'post_card.dart';
import 'post_form.dart';

class PostsView extends StatelessWidget {
  final PostsManager manager;
  const PostsView({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return ViewListenerWidget(
      manager: manager,
      child: Scaffold(
        backgroundColor: AppColors.bgGrey,
        appBar: AppBar(
          title: const Text('Posts'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: manager.refreshPosts,
              tooltip: 'Refresh',
            ),
          ],
        ),
        body: Column(
          children: [
            _PlugBadge(manager: manager),
            Expanded(
              child: ValueListenableBuilder<RequestStatus>(
                valueListenable: manager.requestStatus,
                builder: (_, status, __) {
                  if (status == RequestStatus.loading &&
                      manager.posts.value.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return ValueListenableBuilder(
                    valueListenable: manager.posts,
                    builder: (_, posts, __) {
                      if (posts.isEmpty && status != RequestStatus.loading) {
                        return const Center(child: Text('No posts yet.'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async => manager.refreshPosts(),
                        child: ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: posts.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (ctx, i) => PostCard(
                            post: posts[i],
                            onTap: () => manager.showPostDetail(posts[i]),
                            onEdit: () => _showForm(ctx, posts[i]),
                            onDelete: () => manager.deletePost(posts[i].id!),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showForm(context, null),
          label: const Text('New Post'),
          icon: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showForm(BuildContext context, dynamic post) {
    if (post != null) manager.selectPost(post);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PostForm(manager: manager),
    );
  }
}

// Small banner showing which implementations are active
class _PlugBadge extends StatelessWidget {
  final PostsManager manager;
  const _PlugBadge({required this.manager});

  @override
  Widget build(BuildContext context) {
    final isCubit = manager.runtimeType.toString().contains('Cubit') == false;
    return Container(
      width: double.infinity,
      color: AppColors.primary.withOpacity(0.07),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
      child: Text(
        '🔌  Swap DI in AppInitializer: Dio↔http  |  Cubit↔Riverpod  |  GoRouter↔AutoRoute  |  SharedPrefs↔Hive',
        style: TextStyle(
            fontSize: 10.5,
            color: AppColors.primary.withOpacity(0.85)),
        textAlign: TextAlign.center,
      ),
    );
  }
}
