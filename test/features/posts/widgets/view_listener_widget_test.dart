// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/widgets/view_listener_widget_test.dart
//
// Tests for ViewListenerWidget and ViewEventObserver:
//
//  ViewEventObserver:
//    • Calls onEvent when primary stream emits
//    • Calls onSecondEvent when secondary stream emits
//    • Cancels both subscriptions on dispose (no leaks)
//    • Does nothing when widget is unmounted before event arrives
//
//  ViewListenerWidget:
//    • Calls IWidgetHelper.showToastError for MessageType.error
//    • Calls IWidgetHelper.showToast for MessageType.success
//    • Calls RouteHelper.navigate for RouteLevel.normal
//    • Calls RouteHelper.push for RouteLevel.top
//    • Calls RouteHelper.replace for RouteLevel.replace

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/core/components/view_event_observer.dart';
import 'package:mpv_ioc/core/components/view_listener_widget.dart';
import 'package:mpv_ioc/core/data/events/message_event.dart';
import 'package:mpv_ioc/core/enums/enums.dart';
import 'package:mpv_ioc/core/manager/state_manager.dart';

import '../../../helpers/mocks.mocks.dart';
import '../../../helpers/test_setup.dart';

// ── Minimal StateManager subclass for testing ─────────────────────
class _TestManager extends StateManager {}

void main() {
  // ═══════════════════════════════════════════════════════════════
  //  ViewEventObserver unit tests (no GetIt needed)
  // ═══════════════════════════════════════════════════════════════

  group('ViewEventObserver', () {
    testWidgets('calls onEvent when primary stream emits', (tester) async {
      final controller = StreamController<String>.broadcast();
      final received   = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: ViewEventObserver<String, Never>(
            stream:  controller.stream,
            onEvent: received.add,
            child:   const SizedBox(),
          ),
        ),
      );

      controller.add('hello');
      await tester.pump();

      expect(received, equals(['hello']));
      await controller.close();
    });

    testWidgets('calls onSecondEvent when secondary stream emits',
        (tester) async {
      final primary   = StreamController<int>.broadcast();
      final secondary = StreamController<String>.broadcast();
      final received  = <String>[];

      await tester.pumpWidget(
        MaterialApp(
          home: ViewEventObserver<int, String>(
            stream:        primary.stream,
            onEvent:       (_) {},
            secondStream:  secondary.stream,
            onSecondEvent: received.add,
            child:         const SizedBox(),
          ),
        ),
      );

      secondary.add('nav-event');
      await tester.pump();

      expect(received, equals(['nav-event']));
      await primary.close();
      await secondary.close();
    });

    testWidgets('cancels subscriptions on dispose without throwing',
        (tester) async {
      final controller = StreamController<String>.broadcast();
      var  callCount   = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: ViewEventObserver<String, Never>(
            stream:  controller.stream,
            onEvent: (_) => callCount++,
            child:   const SizedBox(),
          ),
        ),
      );

      // Remove the widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));

      // Events after dispose should not call onEvent
      controller.add('late-event');
      await tester.pump();

      expect(callCount, equals(0));
      await controller.close();
    });

    testWidgets('works without a secondary stream', (tester) async {
      final controller = StreamController<int>.broadcast();
      final received   = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: ViewEventObserver<int, Never>(
            stream:  controller.stream,
            onEvent: received.add,
            child:   const SizedBox(),
          ),
        ),
      );

      controller.add(42);
      await tester.pump();

      expect(received, equals([42]));
      await controller.close();
    });
  });

  // ═══════════════════════════════════════════════════════════════
  //  ViewListenerWidget integration tests
  // ═══════════════════════════════════════════════════════════════

  group('ViewListenerWidget', () {
    late _TestManager manager;
    late MockIWidgetHelper mockHelper;
    late MockIAppRouter mockRouter;

    setUp(() {
      mockHelper = MockIWidgetHelper();
      mockRouter = noopRouter();
      setupGetIt(widgetHelper: mockHelper, appRouter: mockRouter);
      manager = _TestManager();
    });

    tearDown(() async {
      manager.dispose();
      await tearDownGetIt();
    });

    // Helper: pump ViewListenerWidget wrapping a simple child
    Future<void> pumpListener(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: ViewListenerWidget(
            manager: manager,
            child: const Text('child'),
          ),
        ),
      );
      await tester.pump();
    }

    // ── Message events ──────────────────────────────────────────

    testWidgets('calls showToastError for MessageType.error', (tester) async {
      await pumpListener(tester);

      manager.showUiMessage('Something failed', messageType: MessageType.error);
      await tester.pump();

      verify(mockHelper.showToastError(message: 'Something failed')).called(1);
      verifyNever(mockHelper.showToast(
          context: anyNamed('context'),
          subTitleLabel: anyNamed('subTitleLabel')));
    });

    testWidgets('calls showToast for MessageType.success', (tester) async {
      await pumpListener(tester);

      manager.showUiMessage('Saved!', messageType: MessageType.success);
      await tester.pump();

      verify(mockHelper.showToast(
        context:      anyNamed('context'),
        subTitleLabel: 'Saved!',
      )).called(1);
      verifyNever(mockHelper.showToastError(message: anyNamed('message')));
    });

    testWidgets('calls showToast for MessageType.info', (tester) async {
      await pumpListener(tester);

      manager.showUiMessage('FYI', messageType: MessageType.info);
      await tester.pump();

      verify(mockHelper.showToast(
        context:      anyNamed('context'),
        subTitleLabel: 'FYI',
      )).called(1);
    });

    // ── Navigation events ───────────────────────────────────────

    testWidgets('calls router.navigate for RouteLevel.normal', (tester) async {
      await pumpListener(tester);

      manager.navigateTo('posts', routeLevel: RouteLevel.normal);
      await tester.pump();

      verify(mockRouter.navigate(
        'posts',
        context:         anyNamed('context'),
        pathParameters:  anyNamed('pathParameters'),
        queryParameters: anyNamed('queryParameters'),
        extra:           anyNamed('extra'),
        fragment:        anyNamed('fragment'),
      )).called(1);
    });

    testWidgets('calls router.push for RouteLevel.top', (tester) async {
      await pumpListener(tester);

      manager.navigateTo('post_detail', routeLevel: RouteLevel.top);
      await tester.pump();

      verify(mockRouter.push<dynamic>(
        'post_detail',
        context:         anyNamed('context'),
        pathParameters:  anyNamed('pathParameters'),
        queryParameters: anyNamed('queryParameters'),
        extra:           anyNamed('extra'),
        fragment:        anyNamed('fragment'),
      )).called(1);
    });

    testWidgets('calls router.replace for RouteLevel.replace', (tester) async {
      await pumpListener(tester);

      manager.navigateTo('posts', routeLevel: RouteLevel.replace);
      await tester.pump();

      verify(mockRouter.replace(
        'posts',
        context:         anyNamed('context'),
        pathParameters:  anyNamed('pathParameters'),
        queryParameters: anyNamed('queryParameters'),
        extra:           anyNamed('extra'),
        fragment:        anyNamed('fragment'),
      )).called(1);
    });

    testWidgets('renders its child', (tester) async {
      await pumpListener(tester);
      expect(find.text('child'), findsOneWidget);
    });

    testWidgets('handles multiple successive events correctly', (tester) async {
      await pumpListener(tester);

      manager.showUiMessage('Error 1', messageType: MessageType.error);
      manager.showUiMessage('Error 2', messageType: MessageType.error);
      manager.showUiMessage('OK', messageType: MessageType.success);
      await tester.pump();

      verify(mockHelper.showToastError(message: anyNamed('message'))).called(2);
      verify(mockHelper.showToast(
        context:      anyNamed('context'),
        subTitleLabel: anyNamed('subTitleLabel'),
      )).called(1);
    });
  });
}
