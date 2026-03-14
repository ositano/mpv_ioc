// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/integration/posts_navigation_test.dart
//
// Integration test: full GoRouter navigation flow.
//
// Verifies end-to-end behaviour with real GoRouter (not mocked),
// real PostsCubit, real PostsManagerImpl, and a mocked repository.
//
// Flow tested:
//  1. App launches → PostsCubitScreen renders PostsView
//  2. Posts load → list of PostCards appears
//  3. Tapping a PostCard → pushes post_detail route → PostDetailView
//  4. Tapping back arrow → pops back to PostsView
//  5. Tapping FAB → bottom sheet with PostForm opens
//  6. Filling form and saving → new post appears at top of list
//  7. Tapping delete on a card → post is removed from list

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';

import 'package:mpv_ioc/core/api/exception/failure.dart';
import 'package:mpv_ioc/core/helpers/widget_helper.dart';
import 'package:mpv_ioc/core/routes/app_router.dart';
import 'package:mpv_ioc/core/routes/route_constants.dart';
import 'package:mpv_ioc/core/theme/app_theme.dart';
import 'package:mpv_ioc/core/utils/global_variables.dart';
import 'package:mpv_ioc/core/utils/navigation_service.dart';
import 'package:mpv_ioc/features/post_detail/presentation/screens/post_detail_screen.dart';
import 'package:mpv_ioc/features/post_detail/presentation/managers/post_detail_manager.dart';
import 'package:mpv_ioc/features/post_detail/presentation/cubits/post_detail_cubit.dart';
import 'package:mpv_ioc/features/post_detail/repository/post_detail_repository.dart';
import 'package:mpv_ioc/features/posts/presentation/cubits/posts_cubit.dart';
import 'package:mpv_ioc/features/posts/presentation/managers/posts_manager.dart';
import 'package:mpv_ioc/features/posts/presentation/screens/posts_screen.dart';
import 'package:mpv_ioc/core/data/models/post.dart';

import '../helpers/mocks.mocks.dart';
import '../helpers/test_data.dart';
import '../helpers/test_setup.dart';

// ── Test-scoped DI setup ───────────────────────────────────────────

late MockPostsRepository       mockPostsRepo;
late MockPostDetailRepository  mockDetailRepo;

void _setupDI() {
  final nav = NavigationService();
  sl.registerSingleton<NavigationService>(nav);
  sl.registerSingleton<IWidgetHelper>(WidgetHelperImpl());

  mockPostsRepo  = MockPostsRepository();
  mockDetailRepo = MockPostDetailRepository();

  // Stub default responses
  when(mockPostsRepo.getPosts())
      .thenAnswer((_) async => tPostsRight);
  when(mockDetailRepo.getPost(any))
      .thenAnswer((_) async => tPostRight);
  when(mockPostsRepo.createPost(
          title: anyNamed('title'), body: anyNamed('body')))
      .thenAnswer((_) async => tNewPostRight);
  when(mockPostsRepo.deletePost(any))
      .thenAnswer((_) async => tDeleteRight);

  // Register with factory so each screen creation gets a fresh instance
  sl.registerFactory<PostsManager>(() => PostsManagerImpl());
  sl.registerFactory<PostsCubit>(
    () => PostsCubit(manager: sl(), repository: mockPostsRepo),
  );
  sl.registerFactory<PostsScreen>(() => const PostsCubitScreen());

  sl.registerFactoryParam<PostDetailManager, Post, void>(
    (post, _) => PostDetailManagerImpl(initialPost: post),
  );
  sl.registerFactoryParam<PostDetailCubit, Post, void>(
    (post, _) => PostDetailCubit(
      manager:    sl<PostDetailManager>(param1: post),
      repository: mockDetailRepo,
    ),
  );
  sl.registerFactoryParam<PostDetailScreen, Post, void>(
    (post, _) => PostDetailCubitScreen(post: post),
  );
}

// ── Minimal router wired to GetIt — mirrors GoRouterImpl ──────────

GoRouter _buildRouter() => GoRouter(
      navigatorKey: GlobalVariables.rootNavigatorKey,
      initialLocation: '/${RouteConstants.posts}',
      routes: [
        GoRoute(
          path: '/${RouteConstants.posts}',
          name: RouteConstants.posts,
          pageBuilder: (_, __) =>
              MaterialPage(child: GetIt.I<PostsScreen>()),
          routes: [
            GoRoute(
              path: RouteConstants.postDetail,
              name: RouteConstants.postDetail,
              parentNavigatorKey: GlobalVariables.rootNavigatorKey,
              pageBuilder: (_, state) => MaterialPage(
                child: GetIt.I<PostDetailScreen>(
                  param1: state.extra as Post,
                ),
              ),
            ),
          ],
        ),
      ],
    );

// ── Helper: pump the full app ─────────────────────────────────────

class _TestApp extends StatelessWidget {
  final GoRouter router;
  const _TestApp({required this.router});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp.router(
        theme:        AppTheme.light,
        routerConfig: router,
      ),
    );
  }
}

Future<void> pumpApp(WidgetTester tester) async {
  // Register IAppRouter so RouteHelper and ViewListenerWidget resolve it
  if (!sl.isRegistered<IAppRouter>()) {
    final router = _buildRouter();
    sl.registerSingleton<IAppRouter>(MockIAppRouter());
    await tester.pumpWidget(_TestApp(router: router));
  } else {
    final router = _buildRouter();
    await tester.pumpWidget(_TestApp(router: router));
  }
  // Allow initial navigation + async fetch to complete
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

void main() {
  setUp(() {
    setupGetIt();
    _setupDI();
  });

  tearDown(() async {
    await tearDownGetIt();
  });

  // ── 1. Initial render ─────────────────────────────────────────

  testWidgets('1. App launches and shows PostsView with post list',
      (tester) async {
    await pumpApp(tester);

    // AppBar title
    expect(find.text('Posts'), findsOneWidget);

    // All three posts from tPosts should appear
    for (final post in tPosts) {
      expect(find.text(post.title), findsOneWidget);
    }
  });

  // ── 2. Navigate to post detail ────────────────────────────────

  testWidgets('2. Tapping a PostCard navigates to PostDetailView',
      (tester) async {
    await pumpApp(tester);

    // Tap the first PostCard
    await tester.tap(find.text(tPost1.title));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // PostDetailView shows the post id chip
    expect(find.textContaining('Post #${tPost1.id}'), findsOneWidget);
    expect(find.text(tPost1.title), findsWidgets);
  });

  // ── 3. Back navigation ────────────────────────────────────────

  testWidgets('3. Back arrow from detail returns to posts list',
      (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text(tPost1.title));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Tap back
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    // PostsView is back
    expect(find.text('Posts'),           findsOneWidget);
    expect(find.text(tPost1.title),      findsOneWidget);
  });

  // ── 4. Open create form ───────────────────────────────────────

  testWidgets('4. FAB opens PostForm bottom sheet', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.text('New Post'));
    await tester.pumpAndSettle();

    expect(find.text('Create Post'), findsOneWidget);
    expect(find.text('Save Post'),   findsOneWidget);
  });

  // ── 5. Create post ────────────────────────────────────────────

  testWidgets('5. Filling and saving form adds post to the list',
      (tester) async {
    await pumpApp(tester);

    // Open form
    await tester.tap(find.text('New Post'));
    await tester.pumpAndSettle();

    // Fill title and body
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), 'New title');
    await tester.enterText(fields.at(1), 'New body');
    await tester.pump();

    // Tap Save
    await tester.tap(find.text('Save Post'));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Form closed, new post appears at top
    expect(find.text('New title'),   findsOneWidget);
    expect(find.text('Create Post'), findsNothing);
  });

  // ── 6. Delete post ────────────────────────────────────────────

  testWidgets('6. Tapping delete removes post from list', (tester) async {
    await pumpApp(tester);

    // Verify it's there
    expect(find.text(tPost1.title), findsOneWidget);

    // Delete the first post
    await tester.tap(find.byIcon(Icons.delete_outline).first);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text(tPost1.title), findsNothing);
  });

  // ── 7. Refresh ────────────────────────────────────────────────

  testWidgets('7. Tapping refresh re-fetches posts', (tester) async {
    await pumpApp(tester);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // getPosts should have been called at least twice (initial + refresh)
    verify(mockPostsRepo.getPosts()).called(greaterThanOrEqualTo(2));
  });

  // ── 8. Error state ────────────────────────────────────────────

  testWidgets('8. Network error shows snackbar message', (tester) async {
    when(mockPostsRepo.getPosts()).thenAnswer(
      (_) async => Left(InternetFailure()),
    );

    await pumpApp(tester);

    expect(
      find.textContaining('No internet connection'),
      findsOneWidget,
    );
  });
}
