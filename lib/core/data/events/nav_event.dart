// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/data/events/nav_event.dart
import '../../enums/enums.dart';

class NavEvent {
  final String name;
  final Map<String, String> pathParameters;
  final Map<String, String> queryParameters;
  final Object? extra;
  final String? fragment;        // ← restored: used by GoRouter anchor navigation
  final RouteType routeType;
  final RouteLevel routeLevel;

  const NavEvent(
    this.name, {
    this.pathParameters  = const {},
    this.queryParameters = const {},
    this.extra,
    this.fragment,
    this.routeType  = RouteType.named,
    this.routeLevel = RouteLevel.normal,
  });
}
