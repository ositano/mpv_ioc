// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/post_detail/presentation/screens/post_detail_screen.dart
//
// Same pattern: abstract PostDetailScreen → router depends on interface.
// PostDetailCubitScreen is the concrete Cubit impl registered in DI.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../core/components/view_listener_widget.dart';
import '../../../../core/data/models/post.dart';
import '../../../../core/enums/enums.dart';
import '../../../../core/theme/app_theme.dart';
import '../cubits/post_detail_cubit.dart';
import '../managers/post_detail_manager.dart';

// ── Abstract screen ────────────────────────────────────────────────
abstract class PostDetailScreen extends Widget {
  final Post post;
  const PostDetailScreen({super.key, required this.post});
}

// ── Cubit concrete impl ────────────────────────────────────────────
class PostDetailCubitScreen extends StatelessWidget
    implements PostDetailScreen {
  @override
  final Post post;
  const PostDetailCubitScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<PostDetailCubit>(param1: post),
      child: BlocBuilder<PostDetailCubit, PostDetailState>(
        builder: (ctx, _) => PostDetailView(
          manager: ctx.read<PostDetailCubit>().manager,
        ),
      ),
    );
  }
}

// ── Pure View ──────────────────────────────────────────────────────
class PostDetailView extends StatelessWidget {
  final PostDetailManager manager;
  const PostDetailView({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return ViewListenerWidget(
      manager: manager,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Post Detail'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: manager.onBackPressed,
          ),
        ),
        body: ValueListenableBuilder<RequestStatus>(
          valueListenable: manager.requestStatus,
          builder: (_, status, __) {
            if (status == RequestStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }
            return ValueListenableBuilder<Post?>(
              valueListenable: manager.post,
              builder: (_, post, __) {
                if (post == null) {
                  return const Center(child: Text('Post not found.'));
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Post ID chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Post #${post.id}  ·  User ${post.userId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Title
                      Text(
                        post.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      // Body
                      Text(
                        post.body,
                        style: TextStyle(
                          fontSize: 15,
                          height: 1.6,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 32),
                      // Reload button
                      OutlinedButton.icon(
                        onPressed: manager.load,
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Reload from network'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
