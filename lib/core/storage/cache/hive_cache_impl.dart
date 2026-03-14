// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/cache/hive_cache_impl.dart
//
// CacheStorage backed by Hive (fast NoSQL box).
// Register with: sl.registerLazySingleton<CacheStorage>(() => HiveCacheImpl())
//
// Call await sl<CacheStorage>().init() in AppInitializer before use.
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'cache_storage.dart';

class HiveCacheImpl implements CacheStorage {
  static const _boxName  = 'app_cache';
  static const _kLoggedIn = 'logged_in';
  static const _kToken    = 'access_token';
  static const _kRefresh  = 'refresh_token';
  static const _kTheme    = 'theme_dark';

  late Box _box;

  /// Must be called once before any other method.
  @override
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  @override Future<bool?>   isLoggedIn()              async => _box.get(_kLoggedIn) as bool?;
  @override Future<void>    setLoggedIn(bool s)       async => _box.put(_kLoggedIn, s);
  @override Future<void>    saveAccessToken(String t) async => _box.put(_kToken, t);
  @override Future<String?> getAccessToken()          async => _box.get(_kToken) as String?;
  @override Future<void>    saveRefreshToken(String t)async => _box.put(_kRefresh, t);
  @override Future<String?> getRefreshToken()         async => _box.get(_kRefresh) as String?;
  @override Future<bool?>   getThemeMode()            async => _box.get(_kTheme) as bool?;
  @override Future<void>    setThemeMode(bool d)      async => _box.put(_kTheme, d);
  @override Future<void>    clear()                   async => _box.clear();
}
