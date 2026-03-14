// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/routes/go_router_impl.dart
//
// GoRouter concrete IAppRouter.
// Uses the BuildContext extensions that GoRouter adds to every
// context in the widget tree (context.goNamed, context.pushNamed, …).
// This is idiomatic GoRouter and matches the original project style.
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';

import '../../features/post_detail/presentation/screens/post_detail_screen.dart';
import '../../features/posts/presentation/screens/posts_screen.dart';
import '../data/models/post.dart';
import '../utils/global_variables.dart';
import 'app_router.dart';
import 'route_constants.dart';

class GoRouterImpl implements IAppRouter {
  late final GoRouter _router;

  GoRouterImpl() {
    _router = GoRouter(
      navigatorKey: GlobalVariables.rootNavigatorKey,
      initialLocation: '/${RouteConstants.posts}',
      routes: [
        GoRoute(
          path: '/${RouteConstants.posts}',
          name: RouteConstants.posts,
          pageBuilder: (_, __) =>
              MaterialPage(child: GetIt.I<PostsScreen>()),
          routes: [
            GoRoute(
              path: RouteConstants.postDetail,
              name: RouteConstants.postDetail,
              parentNavigatorKey: GlobalVariables.rootNavigatorKey,
              pageBuilder: (_, state) => MaterialPage(
                child: GetIt.I<PostDetailScreen>(
                  param1: state.extra as Post,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  RouterConfig<Object> get routerConfig => _router;

  // ── IAppRouter ────────────────────────────────────────────────

  @override
  void navigate(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  }) {
    // GoRouter context extension — idiomatic and type-safe
    context.goNamed(
      name,
      pathParameters:  pathParameters,
      queryParameters: queryParameters,
      extra:           extra,
    );
  }

  @override
  Future<T?> push<T>(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  }) {
    return context.pushNamed<T>(
      name,
      pathParameters:  pathParameters,
      queryParameters: queryParameters,
      extra:           extra,
    );
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
    context.replaceNamed(
      name,
      pathParameters:  pathParameters,
      queryParameters: queryParameters,
      extra:           extra,
    );
  }

  @override
  void pop(BuildContext context, [Object? result]) {
    if (context.canPop()) context.pop(result);
  }

  @override
  bool canPop(BuildContext context) => context.canPop();
}
