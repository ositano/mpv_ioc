// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/managers/posts_manager_test.dart
//
// Tests for PostsManagerImpl:
//  • Constructor initialises all ValueNotifiers and form fields
//  • TextEditingControllers sync to field registry
//  • selectPost / clearSelection
//  • submitPost gates on validation and calls IoC callback
//  • deletePost and refreshPosts delegate to IoC callbacks
//  • showPostDetail emits the correct NavEvent

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';

import 'package:mpv_ioc/core/data/events/nav_event.dart';
import 'package:mpv_ioc/core/enums/enums.dart';
import 'package:mpv_ioc/core/routes/route_constants.dart';
import 'package:mpv_ioc/features/posts/presentation/managers/posts_manager.dart';

import '../../../helpers/test_data.dart';
import '../../../helpers/test_setup.dart';

void main() {
  late PostsManagerImpl manager;

  setUp(() {
    setupGetIt();
    manager = PostsManagerImpl();
  });

  tearDown(() async {
    manager.dispose();
    await tearDownGetIt();
  });

  // ── Construction ───────────────────────────────────────────────

  group('construction', () {
    test('posts starts empty', () {
      expect(manager.posts.value, isEmpty);
    });

    test('selectedPost starts null', () {
      expect(manager.selectedPost.value, isNull);
    });

    test('controllers start empty', () {
      expect(manager.titleController.text, isEmpty);
      expect(manager.bodyController.text, isEmpty);
    });

    test('form is initially invalid (empty required fields)', () {
      expect(manager.isValid().value, isFalse);
    });
  });

  // ── Controller → field sync ────────────────────────────────────

  group('controller to field sync', () {
    test('titleController change updates title field', () {
      manager.titleController.text = 'My title';
      expect(manager.getFieldValue<String>('title'), equals('My title'));
    });

    test('bodyController change updates body field', () {
      manager.bodyController.text = 'My body';
      expect(manager.getFieldValue<String>('body'), equals('My body'));
    });

    test('filling both fields makes form valid', () {
      manager.titleController.text = 'Title';
      manager.bodyController.text  = 'Body';
      expect(manager.isValid().value, isTrue);
    });
  });

  // ── selectPost ────────────────────────────────────────────────

  group('selectPost', () {
    test('sets selectedPost to the given post', () {
      manager.selectPost(tPost1);
      expect(manager.selectedPost.value, equals(tPost1));
    });

    test('populates controllers from post data', () {
      manager.selectPost(tPost1);
      expect(manager.titleController.text, equals(tPost1.title));
      expect(manager.bodyController.text, equals(tPost1.body));
    });

    test('form becomes valid after selectPost with a real post', () {
      manager.selectPost(tPost1);
      expect(manager.isValid().value, isTrue);
    });
  });

  // ── clearSelection ────────────────────────────────────────────

  group('clearSelection', () {
    setUp(() {
      manager.selectPost(tPost1);
    });

    test('nullifies selectedPost', () {
      manager.clearSelection();
      expect(manager.selectedPost.value, isNull);
    });

    test('empties controllers', () {
      manager.clearSelection();
      expect(manager.titleController.text, isEmpty);
      expect(manager.bodyController.text, isEmpty);
    });

    test('form becomes invalid after clearing', () {
      manager.clearSelection();
      expect(manager.isValid().value, isFalse);
    });
  });

  // ── submitPost ────────────────────────────────────────────────

  group('submitPost', () {
    test('does NOT call onSubmitPost when form is invalid', () {
      var called = false;
      manager.onSubmitPost = () => called = true;

      manager.submitPost(); // form is empty → invalid

      expect(called, isFalse);
    });

    test('marks all fields touched when form is invalid', () {
      manager.onSubmitPost = () {};
      manager.submitPost();

      expect(manager.isFieldTouched('title'), isTrue);
      expect(manager.isFieldTouched('body'),  isTrue);
    });

    test('calls onSubmitPost when form is valid', () {
      var called = false;
      manager.onSubmitPost = () => called = true;

      manager.titleController.text = 'Title';
      manager.bodyController.text  = 'Body';
      manager.submitPost();

      expect(called, isTrue);
    });

    test('does not throw when onSubmitPost is null and form is valid', () {
      manager.titleController.text = 'Title';
      manager.bodyController.text  = 'Body';
      expect(() => manager.submitPost(), returnsNormally);
    });
  });

  // ── deletePost ────────────────────────────────────────────────

  group('deletePost', () {
    test('calls onDeletePost with the given id', () {
      var capturedId = -1;
      manager.onDeletePost = (id) => capturedId = id;

      manager.deletePost(42);

      expect(capturedId, equals(42));
    });

    test('does not throw when onDeletePost is null', () {
      expect(() => manager.deletePost(1), returnsNormally);
    });
  });

  // ── refreshPosts ──────────────────────────────────────────────

  group('refreshPosts', () {
    test('calls onFetchPosts', () {
      var called = false;
      manager.onFetchPosts = () => called = true;

      manager.refreshPosts();

      expect(called, isTrue);
    });
  });

  // ── showPostDetail ────────────────────────────────────────────

  group('showPostDetail', () {
    test('emits NavEvent with post_detail route and RouteLevel.top', () async {
      final events = <NavEvent>[];
      final sub = manager.navigationStream.listen(events.add);

      manager.showPostDetail(tPost1);

      await Future.microtask(() {});
      await sub.cancel();

      expect(events, hasLength(1));
      expect(events.first.name,       equals(RouteConstants.postDetail));
      expect(events.first.extra,      equals(tPost1));
      expect(events.first.routeLevel, equals(RouteLevel.top));
    });
  });
}
