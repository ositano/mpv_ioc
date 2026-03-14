// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/routes/route_helper.dart
//
// ─────────────────────────────────────────────────────────────────
//  RouteHelper — static navigation utilities.
//
//  Mirrors the original implementation from the article closely:
//    • Accepts an optional BuildContext (falls back to rootNavigatorKey).
//    • Handles the '/back' sentinel for pop.
//    • Delegates to IAppRouter registered in GetIt, so GoRouter and
//      AutoRoute both work without changing any call site.
//
//  The Manager calls StateManager.navigateTo() → NavEvent stream →
//  ViewListenerWidget.onNav() → RouteHelper.navigate/push/replace()
//  → IAppRouter impl.  The Manager never touches BuildContext.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';

import '../enums/enums.dart';
import '../utils/global_variables.dart';
import 'app_router.dart';

class RouteHelper {
  static IAppRouter get _router => GetIt.I<IAppRouter>();

  // ── Navigate (go / clear stack above) ─────────────────────────
  static void navigate(
    String name, {
    BuildContext? context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
    RouteType  routeType  = RouteType.named,
    RouteLevel routeLevel = RouteLevel.normal,
  }) {
    final ctx = _resolveContext(context);
    if (ctx == null) return;

    if (name == '/' || name == '/back') {
      if (ctx.mounted && _router.canPop(ctx)) _router.pop(ctx);
      return;
    }

    if (!ctx.mounted) return;
    _router.navigate(
      name,
      context:         ctx,
      pathParameters:  pathParameters,
      queryParameters: queryParameters,
      extra:           extra,
      fragment:        fragment,
    );
  }

  // ── Push (keeps stack, can return a result) ────────────────────
  static Future<T?> push<T>(
    String name, {
    BuildContext? context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
    RouteType routeType = RouteType.named,
  }) async {
    final ctx = _resolveContext(context);
    if (ctx == null) return null;

    if (name == '/' || name == '/back') {
      if (ctx.mounted && _router.canPop(ctx)) _router.pop(ctx);
      return null;
    }

    if (!ctx.mounted) return null;
    return _router.push<T>(
      name,
      context:         ctx,
      pathParameters:  pathParameters,
      queryParameters: queryParameters,
      extra:           extra,
      fragment:        fragment,
    );
  }

  // ── Replace (swap current entry) ──────────────────────────────
  static void replace(
    String name, {
    BuildContext? context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
    RouteType routeType = RouteType.named,
  }) {
    final ctx = _resolveContext(context);
    if (ctx == null || !ctx.mounted) return;

    if (name == '/' || name == '/back') {
      if (_router.canPop(ctx)) _router.pop(ctx);
      return;
    }

    _router.replace(
      name,
      context:         ctx,
      pathParameters:  pathParameters,
      queryParameters: queryParameters,
      extra:           extra,
      fragment:        fragment,
    );
  }

  // ── Internal ───────────────────────────────────────────────────
  static BuildContext? _resolveContext(BuildContext? provided) {
    return provided ?? GlobalVariables.rootNavigatorKey.currentContext;
  }
}
