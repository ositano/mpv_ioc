// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/core/manager/state_manager_test.dart
//
// Tests for StateManager — the base class every Manager extends.
// Verifies field registration, validation, grouping, touch tracking,
// and the navigation / message helpers.


import 'package:flutter_test/flutter_test.dart';

import 'package:mpv_ioc/core/data/events/message_event.dart';
import 'package:mpv_ioc/core/data/events/nav_event.dart';
import 'package:mpv_ioc/core/enums/enums.dart';
import 'package:mpv_ioc/core/manager/state_manager.dart';

import '../../helpers/test_setup.dart';

// ── Concrete subclass for testing ──────────────────────────────────
class _TestManager extends StateManager {}

void main() {
  late _TestManager manager;

  setUp(() {
    setupGetIt();
    manager = _TestManager();
  });

  tearDown(() async {
    manager.dispose();
    await tearDownGetIt();
  });

  // ── addField ───────────────────────────────────────────────────

  group('addField', () {
    test('registers a field with the given initial value', () {
      manager.addField<String>(
        fieldName: 'email',
        initialValue: '',
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      );

      expect(manager.getFieldValue<String>('email'), equals(''));
    });

    test('field is initially invalid when initial value fails validation', () {
      manager.addField<String>(
        fieldName: 'email',
        initialValue: '',
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      );

      expect(manager.isValid().value, isFalse);
    });

    test('field is initially valid when initial value passes validation', () {
      manager.addField<String>(
        fieldName: 'name',
        initialValue: 'Alice',
        validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
      );

      expect(manager.isValid().value, isTrue);
    });

    test('supports multiple independent groups', () {
      manager.addField<String>(
        groupId: 'login',
        fieldName: 'email',
        initialValue: '',
        validator: (v) => v!.isEmpty ? 'Required' : null,
      );
      manager.addField<String>(
        groupId: 'profile',
        fieldName: 'bio',
        initialValue: 'Hello',
        validator: (v) => v!.isEmpty ? 'Required' : null,
      );

      expect(manager.isValid(groupId: 'login').value, isFalse);
      expect(manager.isValid(groupId: 'profile').value, isTrue);
    });

    test('throws if field name is read before registration', () {
      expect(
        () => manager.getFieldValue<String>('nonexistent'),
        throwsException,
      );
    });
  });

  // ── updateField ────────────────────────────────────────────────

  group('updateField', () {
    setUp(() {
      manager.addField<String>(
        fieldName: 'title',
        initialValue: '',
        validator: (v) => v!.isEmpty ? 'Required' : null,
      );
    });

    test('updates the field value', () {
      manager.updateField('title', 'My post');
      expect(manager.getFieldValue<String>('title'), equals('My post'));
    });

    test('marks the field as touched after update', () {
      manager.updateField('title', 'x');
      expect(manager.isFieldTouched('title'), isTrue);
    });

    test('re-validates group after update', () {
      expect(manager.isValid().value, isFalse);
      manager.updateField('title', 'something');
      expect(manager.isValid().value, isTrue);
    });

    test('notifies field listenable listeners', () {
      var notified = false;
      manager.getFieldListenable<String>('title').addListener(() {
        notified = true;
      });

      manager.updateField('title', 'changed');

      expect(notified, isTrue);
    });
  });

  // ── markAllAsTouched ───────────────────────────────────────────

  group('markAllAsTouched', () {
    setUp(() {
      manager.addField<String>(
        fieldName: 'a',
        initialValue: '',
        validator: (v) => v!.isEmpty ? 'err' : null,
      );
      manager.addField<String>(
        fieldName: 'b',
        initialValue: '',
        validator: (v) => v!.isEmpty ? 'err' : null,
      );
    });

    test('marks every field in the default group as touched', () {
      manager.markAllAsTouched();

      expect(manager.isFieldTouched('a'), isTrue);
      expect(manager.isFieldTouched('b'), isTrue);
    });

    test('does not affect fields in other groups', () {
      manager.addField<String>(
        groupId: 'other',
        fieldName: 'c',
        initialValue: '',
        validator: (_) => null,
      );

      manager.markAllAsTouched();

      expect(manager.isFieldTouched('c', groupId: 'other'), isFalse);
    });
  });

  // ── getFieldError ──────────────────────────────────────────────

  group('getFieldError', () {
    setUp(() {
      manager.addField<String>(
        fieldName: 'title',
        initialValue: '',
        validator: (v) => v!.isEmpty ? 'Required' : null,
      );
    });

    test('returns null when field is not yet touched', () {
      expect(manager.getFieldError('title'), isNull);
    });

    test('returns error string after field is touched and invalid', () {
      manager.updateField('title', ''); // triggers touch
      expect(manager.getFieldError('title'), equals('Required'));
    });

    test('returns null after field becomes valid', () {
      manager.updateField('title', 'Hello');
      expect(manager.getFieldError('title'), isNull);
    });
  });

  // ── touchField ────────────────────────────────────────────────

  group('touchField', () {
    setUp(() {
      manager.addField<String>(
        fieldName: 'bio',
        initialValue: '',
        validator: (v) => v!.isEmpty ? 'Required' : null,
      );
    });

    test('marks field as touched when callback is invoked', () {
      manager.touchField('bio').call();
      expect(manager.isFieldTouched('bio'), isTrue);
    });

    test('does not double-touch a field', () {
      var notifyCount = 0;
      manager.getFieldListenable<String>('bio').addListener(() {
        notifyCount++;
      });

      manager.touchField('bio').call();
      manager.touchField('bio').call(); // second call should be no-op

      expect(notifyCount, equals(1));
    });
  });

  // ── resetForm ─────────────────────────────────────────────────

  group('resetForm', () {
    setUp(() {
      manager.addField<String>(
        fieldName: 'query',
        initialValue: '',
        validator: (_) => null,
      );
    });

    test('resets value to initial and clears touched state', () {
      manager.updateField('query', 'flutter');
      expect(manager.getFieldValue<String>('query'), equals('flutter'));

      manager.resetForm();

      expect(manager.getFieldValue<String>('query'), equals(''));
      expect(manager.isFieldTouched('query'), isFalse);
    });
  });

  // ── requestStatus ─────────────────────────────────────────────

  group('requestStatus', () {
    test('starts as RequestStatus.initial', () {
      expect(manager.requestStatus.value, equals(RequestStatus.initial));
    });

    test('can be updated to loading and loaded', () {
      manager.requestStatus.value = RequestStatus.loading;
      expect(manager.requestStatus.value, equals(RequestStatus.loading));

      manager.requestStatus.value = RequestStatus.loaded;
      expect(manager.requestStatus.value, equals(RequestStatus.loaded));
    });
  });

  // ── showUiMessage ─────────────────────────────────────────────

  group('showUiMessage', () {
    test('emits a MessageEvent on the messageStream', () async {
      final events = <MessageEvent>[];
      final sub = manager.messageStream.listen(events.add);

      manager.showUiMessage('Hello', messageType: MessageType.success);

      await Future.microtask(() {});
      await sub.cancel();

      expect(events, hasLength(1));
      expect(events.first.message, equals('Hello'));
      expect(events.first.messageType, equals(MessageType.success));
    });

    test('defaults to MessageType.error', () async {
      final events = <MessageEvent>[];
      final sub = manager.messageStream.listen(events.add);

      manager.showUiMessage('Oops');

      await Future.microtask(() {});
      await sub.cancel();

      expect(events.first.messageType, equals(MessageType.error));
    });
  });

  // ── navigateTo ────────────────────────────────────────────────

  group('navigateTo', () {
    test('emits a NavEvent with correct name and extra', () async {
      final events = <NavEvent>[];
      final sub = manager.navigationStream.listen(events.add);

      manager.navigateTo(
        'post_detail',
        extra: 'somePayload',
        routeLevel: RouteLevel.top,
      );

      await Future.microtask(() {});
      await sub.cancel();

      expect(events, hasLength(1));
      expect(events.first.name, equals('post_detail'));
      expect(events.first.extra, equals('somePayload'));
      expect(events.first.routeLevel, equals(RouteLevel.top));
    });

    test('onBackPressed emits /back NavEvent', () async {
      final events = <NavEvent>[];
      final sub = manager.navigationStream.listen(events.add);

      manager.onBackPressed();

      await Future.microtask(() {});
      await sub.cancel();

      expect(events.first.name, equals('/back'));
    });

    test('onBackPressedWithData emits /back with extra', () async {
      final events = <NavEvent>[];
      final sub = manager.navigationStream.listen(events.add);

      manager.onBackPressedWithData({'id': 42});

      await Future.microtask(() {});
      await sub.cancel();

      expect(events.first.extra, equals({'id': 42}));
    });
  });
}
