// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/presentation/screens/posts_screen.dart
//
// ─────────────────────────────────────────────────────────────────
//  PostsScreen — abstract Widget (the "interface" for this screen).
//
//  Two concrete implementations:
//    • PostsCubitScreen    (this file)   — wires BlocProvider + Cubit
//    • PostsRiverpodScreen (separate file) — wires ConsumerWidget + Notifier
//
//  AppInitializer._registerScreens() decides which one GetIt returns.
//  The router only knows about PostsScreen (abstract) — it never
//  imports either concrete class.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../cubits/posts_cubit.dart';
import '../widgets/posts_view.dart';

// ── Abstract type (the "interface") ───────────────────────────────
abstract class PostsScreen extends Widget {
  const PostsScreen({super.key});
}

// ── Cubit concrete implementation ────────────────────────────────
class PostsCubitScreen extends StatelessWidget implements PostsScreen {
  const PostsCubitScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<PostsCubit>(),
      child: BlocBuilder<PostsCubit, PostsState>(
        builder: (ctx, _) => PostsView(
          manager: ctx.read<PostsCubit>().manager,
        ),
      ),
    );
  }
}
