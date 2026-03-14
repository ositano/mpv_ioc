// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/config/di/app_initializer.dart
//
// ─────────────────────────────────────────────────────────────────
//  Single wiring point for the entire app.
//
//  To swap any implementation change ONE line per axis:
//
//  HTTP client   → apiClient:    ApiClientType.dio | .httpClient
//  State mgr     → stateManager: StateManagerType.cubit | .riverpod
//  Router        → router:       RouterType.goRouter | .autoRoute
//  Cache storage → cache:        CacheType.sharedPrefs | .hive
//  DB storage    → database:     DatabaseType.sqflite | .isar
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import '../../core/api/network/network_info.dart';
import '../../core/api/services/api_client.dart';
import '../../core/api/services/api_services.dart';
import '../../core/api/services/api_services_impl.dart';
import '../../core/api/services/dio_api_client.dart';
import '../../core/api/services/http_api_client.dart';
import '../../core/data/models/post.dart';
import '../../core/helpers/widget_helper.dart';
import '../../core/routes/app_router.dart';
import '../../core/routes/auto_route_impl.dart';
import '../../core/routes/go_router_impl.dart';
import '../../core/storage/cache/cache_storage.dart';
import '../../core/storage/cache/hive_cache_impl.dart';
import '../../core/storage/cache/shared_pref_cache_impl.dart';
import '../../core/storage/database/database_storage.dart';
import '../../core/storage/database/isar_database_impl.dart';
import '../../core/storage/database/sqflite_database_impl.dart';
import '../../core/storage/local_storage.dart';
import '../../core/storage/local_storage_impl.dart';
import '../../core/utils/navigation_service.dart';
// Features — Posts (Cubit)
import '../../features/post_detail/presentation/cubits/post_detail_cubit.dart';
import '../../features/post_detail/presentation/managers/post_detail_manager.dart';
import '../../features/post_detail/presentation/screens/post_detail_screen.dart';
import '../../features/post_detail/repository/post_detail_repository.dart';
import '../../features/posts/presentation/cubits/posts_cubit.dart';
import '../../features/posts/presentation/managers/posts_manager.dart';
import '../../features/posts/presentation/riverpod/posts_provider.dart';
import '../../features/posts/presentation/screens/posts_riverpod_screen.dart';
import '../../features/posts/presentation/screens/posts_screen.dart';
import '../../features/posts/repository/posts_repository.dart';

// ── Swap enums ────────────────────────────────────────────────────
enum ApiClientType   { dio, httpClient }
enum StateManagerType{ cubit, riverpod }
enum RouterType      { goRouter, autoRoute }
enum CacheType       { sharedPrefs, hive }
enum DatabaseType    { sqflite, isar }

class AppInitializer {
  static final GetIt sl = GetIt.instance;

  static StateManagerType stateManagerType = StateManagerType.cubit;

  AppInitializer._();

  // ── Public entry point ──────────────────────────────────────────
  static Future<void> init({
    ApiClientType    apiClient    = ApiClientType.dio,
    StateManagerType stateManager = StateManagerType.cubit,
    RouterType       router       = RouterType.goRouter,
    CacheType        cache        = CacheType.sharedPrefs,
    DatabaseType     database     = DatabaseType.sqflite,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();

    await _registerInfrastructure(
      apiClient: apiClient,
      cache:     cache,
      database:  database,
    );
    _registerRepositories();
    _registerManagers();
    _registerCubits();
    _registerScreens(stateManager: stateManager);
    _registerRouter(router: router);
    _registerHelpers();
  }

  // ── Riverpod overrides ─────────────────────────────────────────
  // Call ProviderScope(overrides: AppInitializer.riverpodOverrides)
  // in app.dart so Riverpod providers receive the same concrete
  // implementations registered in GetIt — without calling GetIt
  // directly inside the provider file.
  static List<Override> get riverpodOverrides => [
    postsRepositoryProvider.overrideWith(
      (_) => PostsRepositoryImpl(apiServices: sl<ApiServices>()),
    ),
  ];

  // ── Infrastructure ─────────────────────────────────────────────
  static Future<void> _registerInfrastructure({
    required ApiClientType    apiClient,
    required CacheType        cache,
    required DatabaseType     database,
  }) async {
    sl.registerSingleton<NavigationService>(NavigationService());
    sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl());

    // ── Cache storage: swap here ──────────────────────────────────
    switch (cache) {
      case CacheType.sharedPrefs:
        sl.registerLazySingleton<CacheStorage>(
          () => SharedPrefCacheImpl(),
        );
        break;
      case CacheType.hive:
        final hive = HiveCacheImpl();
        await hive.init(); // Hive needs async init
        sl.registerLazySingleton<CacheStorage>(() => hive);
        break;
    }

    // ── Database storage: swap here ───────────────────────────────
    switch (database) {
      case DatabaseType.sqflite:
        final db = SqfliteDatabaseImpl();
        await db.init();
        sl.registerLazySingleton<DatabaseStorage>(() => db);
        break;
      case DatabaseType.isar:
        final db = IsarDatabaseImpl();
        await db.init(); // throws UnimplementedError until activated
        sl.registerLazySingleton<DatabaseStorage>(() => db);
        break;
    }

    sl.registerLazySingleton<LocalStorage>(
      () => LocalStorageImpl(
        cache: sl<CacheStorage>(),
        db:    sl<DatabaseStorage>(),
      ),
    );

    // ── HTTP client: swap here ────────────────────────────────────
    switch (apiClient) {
      case ApiClientType.dio:
        sl.registerLazySingleton<IApiClient>(
          () => DioApiClient(networkInfo: sl()),
        );
        break;
      case ApiClientType.httpClient:
        sl.registerLazySingleton<IApiClient>(
          () => HttpApiClient(networkInfo: sl()),
        );
        break;
    }

    sl.registerLazySingleton<ApiServices>(
      () => ApiServicesImpl(apiClient: sl()),
    );
  }

  // ── Repositories ───────────────────────────────────────────────
  static void _registerRepositories() {
    sl.registerFactory<PostsRepository>(
      () => PostsRepositoryImpl(apiServices: sl()),
    );
    sl.registerFactory<PostDetailRepository>(
      () => PostDetailRepositoryImpl(apiServices: sl()),
    );
  }

  // ── Managers ───────────────────────────────────────────────────
  static void _registerManagers() {
    sl.registerFactory<PostsManager>(() => PostsManagerImpl());
    sl.registerFactoryParam<PostDetailManager, Post, void>(
      (post, _) => PostDetailManagerImpl(initialPost: post),
    );
  }

  // ── Cubits ─────────────────────────────────────────────────────
  static void _registerCubits() {
    sl.registerFactory<PostsCubit>(
      () => PostsCubit(manager: sl(), repository: sl()),
    );
    sl.registerFactoryParam<PostDetailCubit, Post, void>(
      (post, _) => PostDetailCubit(
        manager:    sl<PostDetailManager>(param1: post),
        repository: sl(),
      ),
    );
  }

  // ── Screens (the IoC pivot point) ──────────────────────────────
  // Change ONE registration here to swap the entire state management
  // layer for a feature. The router never imports concrete screens.
  static void _registerScreens({
    required StateManagerType stateManager,
  }) {
    stateManagerType = stateManager;
    switch (stateManager) {
      case StateManagerType.cubit:
        sl.registerFactory<PostsScreen>(() => const PostsCubitScreen());
        break;
      case StateManagerType.riverpod:
        sl.registerFactory<PostsScreen>(
          () => const PostsRiverpodScreen(),
        );
        break;
    }

    // PostDetailScreen — only Cubit for now (you can add Riverpod variant same way)
    sl.registerFactoryParam<PostDetailScreen, Post, void>(
      (post, _) => PostDetailCubitScreen(post: post),
    );
  }

  // ── Router: swap here ──────────────────────────────────────────
  static void _registerRouter({required RouterType router}) {
    switch (router) {
      case RouterType.goRouter:
        sl.registerSingleton<IAppRouter>(GoRouterImpl());
        break;
      case RouterType.autoRoute:
        sl.registerSingleton<IAppRouter>(AutoRouteImpl());
        break;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────
  static void _registerHelpers() {
    sl.registerSingleton<IWidgetHelper>(WidgetHelperImpl());
  }

  static Future<void> reset() => sl.reset();
}
