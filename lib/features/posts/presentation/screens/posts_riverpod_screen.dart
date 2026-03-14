// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/presentation/screens/posts_riverpod_screen.dart
//
// ─────────────────────────────────────────────────────────────────
//  Riverpod concrete screen — implements PostsScreen (abstract).
//
//  The ONLY structural difference from PostsCubitScreen:
//    • Extends ConsumerWidget instead of StatelessWidget
//    • Watches postsNotifierProvider (Riverpod) instead of
//      providing a Cubit (BlocProvider)
//
//  Both screens hand the same PostsManager to the same PostsView.
//  All UI code lives in PostsView — shared, untouched.
// ─────────────────────────────────────────────────────────────────

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../riverpod/posts_provider.dart';
import 'posts_screen.dart';
import '../widgets/posts_view.dart';

@RoutePage()
class PostsRiverpodScreen extends ConsumerWidget implements PostsScreen {
  const PostsRiverpodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watching the provider triggers the StateNotifier which assigns
    // IoC callbacks on the manager and kicks off the initial fetch.
    ref.watch(postsNotifierProvider);
    final manager = ref.watch(postsManagerProvider);

    return PostsView(manager: manager);
  }
}
