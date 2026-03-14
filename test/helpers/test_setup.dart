// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/helpers/test_setup.dart
//
// Shared GetIt setup utilities.
//
// Every test that constructs a Manager or Cubit needs at least a
// NavigationService registered — because StateManager reads it at
// field-initialisation time. Use setupGetIt() / tearDownGetIt() in
// setUp/tearDown blocks.

import 'package:get_it/get_it.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/core/helpers/widget_helper.dart';
import 'package:mpv_ioc/core/routes/app_router.dart';
import 'package:mpv_ioc/core/utils/navigation_service.dart';

import 'mocks.mocks.dart';

final GetIt sl = GetIt.instance;

/// Registers the minimum set of dependencies that StateManager (and therefore
/// every Manager) needs at construction time.
void setupGetIt({
  NavigationService? navigationService,
  IWidgetHelper? widgetHelper,
  IAppRouter? appRouter,
}) {
  // Always reset first so tests never share state
  if (sl.isRegistered<NavigationService>()) sl.reset();

  sl.registerSingleton<NavigationService>(
    navigationService ?? NavigationService(),
  );
  sl.registerSingleton<IWidgetHelper>(
    widgetHelper ?? MockIWidgetHelper(),
  );
  sl.registerSingleton<IAppRouter>(
    appRouter ?? MockIAppRouter(),
  );
}

/// Tear down: resets GetIt so each test starts clean.
Future<void> tearDownGetIt() async {
  if (sl.isRegistered<NavigationService>()) {
    final nav = sl<NavigationService>();
    nav.dispose();
  }
  await sl.reset();
}

/// Convenience: a [MockIAppRouter] with all void methods stubbed to no-op so
/// widget tests don't need to set up expectations for navigation side-effects.
MockIAppRouter noopRouter() {
  final mock = MockIAppRouter();
  when(mock.navigate(any,
          context: anyNamed('context'),
          pathParameters: anyNamed('pathParameters'),
          queryParameters: anyNamed('queryParameters'),
          extra: anyNamed('extra'),
          fragment: anyNamed('fragment')))
      .thenReturn(null);
  when(mock.push<dynamic>(any,
          context: anyNamed('context'),
          pathParameters: anyNamed('pathParameters'),
          queryParameters: anyNamed('queryParameters'),
          extra: anyNamed('extra'),
          fragment: anyNamed('fragment')))
      .thenAnswer((_) async => null);
  when(mock.replace(any,
          context: anyNamed('context'),
          pathParameters: anyNamed('pathParameters'),
          queryParameters: anyNamed('queryParameters'),
          extra: anyNamed('extra'),
          fragment: anyNamed('fragment')))
      .thenReturn(null);
  when(mock.pop(any, any)).thenReturn(null);
  when(mock.canPop(any)).thenReturn(true);
  return mock;
}
