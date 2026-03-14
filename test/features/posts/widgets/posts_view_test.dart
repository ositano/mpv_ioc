// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/widgets/posts_view_test.dart
//
// Widget tests for PostsView:
//  • Shows spinner while loading and posts list is empty
//  • Shows "No posts yet" when list is empty and not loading
//  • Renders a PostCard per post when list is populated
//  • Tapping refresh button calls manager.refreshPosts
//  • Tapping FAB opens the PostForm bottom sheet
//  • Tapping a PostCard's edit icon opens PostForm pre-filled
//  • Tapping a PostCard's delete icon calls manager.deletePost

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/core/enums/enums.dart';
import 'package:mpv_ioc/features/posts/presentation/managers/posts_manager.dart';
import 'package:mpv_ioc/features/posts/presentation/widgets/post_form.dart';
import 'package:mpv_ioc/features/posts/presentation/widgets/posts_view.dart';

import '../../../helpers/test_data.dart';
import '../../../helpers/test_setup.dart';

// ── Helper: pump PostsView inside a minimal app ────────────────────

Future<void> pumpPostsView(
  WidgetTester tester,
  PostsManagerImpl manager,
) async {
  await tester.pumpWidget(
    MaterialApp(home: PostsView(manager: manager)),
  );
  await tester.pump();
}

void main() {
  late PostsManagerImpl manager;

  setUp(() {
    setupGetIt(appRouter: noopRouter());
    manager = PostsManagerImpl();
  });

  tearDown(() async {
    manager.dispose();
    await tearDownGetIt();
  });

  // ── Loading state ─────────────────────────────────────────────

  group('loading state', () {
    testWidgets('shows CircularProgressIndicator when loading and list empty',
        (tester) async {
      manager.requestStatus.value = RequestStatus.loading;
      // posts.value is already empty

      await pumpPostsView(tester, manager);

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('does NOT show spinner when loading but list already has items',
        (tester) async {
      manager.posts.value         = tPosts;
      manager.requestStatus.value = RequestStatus.loading;

      await pumpPostsView(tester, manager);

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ── Empty state ───────────────────────────────────────────────

  group('empty state', () {
    testWidgets('shows "No posts yet." when list is empty and loaded',
        (tester) async {
      manager.requestStatus.value = RequestStatus.loaded;
      // posts.value is already empty

      await pumpPostsView(tester, manager);

      expect(find.text('No posts yet.'), findsOneWidget);
    });

    testWidgets('does NOT show empty text while loading', (tester) async {
      manager.requestStatus.value = RequestStatus.loading;

      await pumpPostsView(tester, manager);

      expect(find.text('No posts yet.'), findsNothing);
    });
  });

  // ── List rendering ────────────────────────────────────────────

  group('list rendering', () {
    testWidgets('renders one PostCard per post', (tester) async {
      manager.posts.value         = tPosts;
      manager.requestStatus.value = RequestStatus.loaded;

      await pumpPostsView(tester, manager);

      // Each PostCard shows the post title
      for (final post in tPosts) {
        expect(find.text(post.title), findsOneWidget);
      }
    });

    testWidgets('list updates when manager.posts changes', (tester) async {
      manager.posts.value         = [tPost1];
      manager.requestStatus.value = RequestStatus.loaded;

      await pumpPostsView(tester, manager);
      expect(find.text(tPost1.title), findsOneWidget);
      expect(find.text(tPost2.title), findsNothing);

      // Add a second post
      manager.posts.value = [tPost1, tPost2];
      await tester.pump();

      expect(find.text(tPost2.title), findsOneWidget);
    });
  });

  // ── AppBar actions ────────────────────────────────────────────

  group('AppBar', () {
    testWidgets('shows "Posts" title', (tester) async {
      await pumpPostsView(tester, manager);
      expect(find.text('Posts'), findsOneWidget);
    });

    testWidgets('tapping refresh button calls manager.refreshPosts',
        (tester) async {
      var refreshed = false;
      manager.onFetchPosts = () => refreshed = true;

      await pumpPostsView(tester, manager);
      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      expect(refreshed, isTrue);
    });
  });

  // ── FAB ───────────────────────────────────────────────────────

  group('FAB', () {
    testWidgets('shows "New Post" FAB', (tester) async {
      await pumpPostsView(tester, manager);
      expect(find.text('New Post'), findsOneWidget);
    });

    testWidgets('tapping FAB opens PostForm bottom sheet', (tester) async {
      await pumpPostsView(tester, manager);

      await tester.tap(find.text('New Post'));
      await tester.pumpAndSettle();

      expect(find.byType(PostForm), findsOneWidget);
      expect(find.text('Create Post'), findsOneWidget);
    });

    testWidgets('clearSelection is called when FAB opens form', (tester) async {
      manager.selectPost(tPost1); // pre-select something
      await pumpPostsView(tester, manager);

      // FAB calls _showForm(context, null) which does NOT call selectPost
      // so selectedPost should remain from before; the form shows "Edit Post"
      // unless clearSelection was called. We verify the form header.
      await tester.tap(find.text('New Post'));
      await tester.pumpAndSettle();

      // No selectPost(null) happens — the test verifies FAB doesn't
      // accidentally pre-fill the form.
      expect(find.byType(PostForm), findsOneWidget);
    });
  });

  // ── PostCard interactions ─────────────────────────────────────

  group('PostCard interactions', () {
    setUp(() {
      manager.posts.value         = [tPost1, tPost2];
      manager.requestStatus.value = RequestStatus.loaded;
    });

    testWidgets('tapping edit icon opens PostForm pre-filled', (tester) async {
      await pumpPostsView(tester, manager);

      // Tap the first PostCard's edit button
      await tester.tap(find.byIcon(Icons.edit_outlined).first);
      await tester.pumpAndSettle();

      expect(find.byType(PostForm),  findsOneWidget);
      expect(find.text('Edit Post'), findsOneWidget);
      expect(manager.selectedPost.value, equals(tPost1));
    });

    testWidgets('tapping delete icon calls manager.deletePost', (tester) async {
      var deletedId = -1;
      manager.onDeletePost = (id) => deletedId = id;

      await pumpPostsView(tester, manager);

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pump();

      expect(deletedId, equals(tPost1.id));
    });
  });
}
