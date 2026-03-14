// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/utils/navigation_service.dart
import 'dart:async';

import '../data/events/message_event.dart';
import '../data/events/nav_event.dart';
import '../enums/enums.dart';

class NavigationService {
  final _navController = StreamController<NavEvent>.broadcast();
  final _msgController = StreamController<MessageEvent>.broadcast();

  Stream<NavEvent>     get navigationStream => _navController.stream;
  Stream<MessageEvent> get messageStream    => _msgController.stream;

  void navigateTo(
    String name, {
    Map<String, String> pathParameters  = const {},
    Map<String, String> queryParameters = const {},
    Object?    extra,
    String?    fragment,
    RouteType  routeType  = RouteType.named,
    RouteLevel routeLevel = RouteLevel.normal,
  }) {
    _navController.add(NavEvent(
      name,
      pathParameters:  pathParameters,
      queryParameters: queryParameters,
      extra:           extra,
      fragment:        fragment,
      routeType:       routeType,
      routeLevel:      routeLevel,
    ));
  }

  void showMessage(MessageEvent event) => _msgController.add(event);

  void dispose() {
    _navController.close();
    _msgController.close();
  }
}
