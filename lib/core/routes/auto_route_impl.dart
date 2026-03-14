// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/routes/auto_route_impl.dart
//
// AutoRoute concrete IAppRouter.
// Uses AutoRoute's context extensions: context.router.pushNamed(), etc.
// The interface is identical to GoRouterImpl — swap with one line in
// AppInitializer.

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../../features/post_detail/presentation/screens/post_detail_screen.dart';
import '../../features/posts/presentation/screens/posts_screen.dart';
import '../data/models/post.dart';
import 'app_router.dart';
import 'auto_route_impl.gr.dart';
import 'route_constants.dart';

// ── Route page wrappers ───────────────────────────────────────────
// AutoRoute requires annotated classes for code generation.
// We keep the GetIt pattern so swapping the concrete screen impl
// still only requires a change in AppInitializer._registerScreens().

@RoutePage(name: 'PostsRoute')
class PostsAutoRoutePage extends StatelessWidget {
  const PostsAutoRoutePage({super.key});
  @override
  Widget build(BuildContext context) => GetIt.I<PostsScreen>();
}

@RoutePage(name: 'PostDetailRoute')
class PostDetailAutoRoutePage extends StatelessWidget {
  final Post post;
  const PostDetailAutoRoutePage({super.key, required this.post});
  @override
  Widget build(BuildContext context) =>
      GetIt.I<PostDetailScreen>(param1: post);
}

// ── Router config ─────────────────────────────────────────────────
@AutoRouterConfig(replaceInRouteName: 'Page,Route')
class _AppAutoRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
        AutoRoute(
          page: PostsRoute.page,
          path: '/${RouteConstants.posts}',
          initial: true,
          children: [
            AutoRoute(
              page: PostDetailRoute.page,
              path: RouteConstants.postDetail,
            ),
          ],
        ),
      ];
}

// ── IAppRouter implementation ─────────────────────────────────────
class AutoRouteImpl implements IAppRouter {
  final _appRouter = _AppAutoRouter();

  @override
  RouterConfig<Object> get routerConfig => _appRouter.config();

  // AutoRoute uses context.router extensions
  @override
  void navigate(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  }) {
    _pushByName(context, name, extra: extra, replace: true);
  }

  @override
  Future<T?> push<T>(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  }) async {
    _pushByName(context, name, extra: extra, replace: false);
    return null;
  }

  @override
  void replace(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  }) {
    _pushByName(context, name, extra: extra, replace: true);
  }

  void _pushByName(BuildContext context, String name,
      {Object? extra, bool replace = false}) {
    switch (name) {
      case RouteConstants.posts:
        replace
            ? context.router.replaceAll([PostsRoute()])
            : context.router.push(PostsRoute());
        break;
      case RouteConstants.postDetail:
        if (extra is Post) context.router.push(PostDetailRoute(post: extra));
        break;
    }
  }

  @override
  void pop(BuildContext context, [Object? result]) =>
      context.router.pop(result);

  @override
  bool canPop(BuildContext context) => context.router.canPop();
}
