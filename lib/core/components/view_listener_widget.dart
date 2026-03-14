// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/components/view_listener_widget.dart
//
// ─────────────────────────────────────────────────────────────────
//  ViewListenerWidget — wraps any screen/view.
//
//  Uses ViewEventObserver<MessageEvent, NavEvent> to subscribe to
//  both the message stream and the navigation stream from the Manager.
//
//  Message events  → IWidgetHelper.showToastError / showToast
//  Navigation events → RouteHelper.navigate / push / replace
//    (RouteHelper delegates to IAppRouter, so GoRouter and AutoRoute
//     both work without changing this widget.)
//
//  This is a StatelessWidget — the stateful subscription logic lives
//  in ViewEventObserver to stay generic and reusable.
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import '../data/events/message_event.dart';
import '../data/events/nav_event.dart';
import '../enums/enums.dart';
import '../helpers/widget_helper.dart';
import '../manager/state_manager.dart';
import '../routes/route_helper.dart';
import 'view_event_observer.dart';

class ViewListenerWidget extends StatelessWidget {
  final Widget child;
  final StateManager manager;

  const ViewListenerWidget({
    super.key,
    required this.child,
    required this.manager,
  });

  @override
  Widget build(BuildContext context) {
    return ViewEventObserver<MessageEvent, NavEvent>(
      // ── Primary stream: UI messages (toasts / snackbars) ──────
      stream: manager.messageStream,
      onEvent: (message) {
        if (message.messageType == MessageType.error) {
          GetIt.I<IWidgetHelper>().showToastError(message: message.message);
        } else {
          GetIt.I<IWidgetHelper>()
              .showToast(context: context, subTitleLabel: message.message);
        }
      },

      // ── Secondary stream: navigation events ───────────────────
      secondStream: manager.navigationStream,
      onSecondEvent: (nav) {
        // RouteHelper receives the BuildContext so the concrete router
        // (GoRouter / AutoRoute) can use context extensions directly.
        if (nav.routeLevel == RouteLevel.normal) {
          RouteHelper.navigate(
            nav.name,
            context:         context,
            pathParameters:  nav.pathParameters,
            queryParameters: nav.queryParameters,
            fragment:        nav.fragment,
            extra:           nav.extra,
            routeType:       nav.routeType,
          );
        } else if (nav.routeLevel == RouteLevel.replace) {
          RouteHelper.replace(
            nav.name,
            context:         context,
            pathParameters:  nav.pathParameters,
            queryParameters: nav.queryParameters,
            fragment:        nav.fragment,
            extra:           nav.extra,
            routeType:       nav.routeType,
          );
        } else {
          // RouteLevel.top — push onto the stack
          RouteHelper.push(
            nav.name,
            context:         context,
            pathParameters:  nav.pathParameters,
            queryParameters: nav.queryParameters,
            fragment:        nav.fragment,
            extra:           nav.extra,
            routeType:       nav.routeType,
          );
        }
      },

      child: child,
    );
  }
}
