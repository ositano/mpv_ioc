// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/routes/app_router.dart
//
// ─────────────────────────────────────────────────────────────────
//  IAppRouter — abstract routing contract.
//
//  ViewListenerWidget always has a BuildContext (it is a widget), so
//  it passes context to RouteHelper, which passes it here.
//  Concrete impls use it to call the router's context extensions
//  (context.goNamed for GoRouter, context.router for AutoRoute).
//
//  The Manager still has NO BuildContext — it only emits NavEvents
//  on the NavigationService stream.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';

abstract class IAppRouter {
  /// The value passed to MaterialApp.router(routerConfig: ...)
  RouterConfig<Object> get routerConfig;

  /// Navigate and replace the current route (go).
  void navigate(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  });

  /// Push onto the stack — preserves history, returns a result.
  Future<T?> push<T>(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  });

  /// Replace the current entry in the stack.
  void replace(
    String name, {
    required BuildContext context,
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object? extra,
    String? fragment,
  });

  void pop(BuildContext context, [Object? result]);
  bool canPop(BuildContext context);
}
