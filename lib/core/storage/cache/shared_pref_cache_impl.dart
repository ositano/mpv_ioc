// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/cache/shared_pref_cache_impl.dart
//
// CacheStorage backed by SharedPreferences.
// Register with: sl.registerLazySingleton<CacheStorage>(() => SharedPrefCacheImpl())
import 'package:shared_preferences/shared_preferences.dart';
import 'cache_storage.dart';

class SharedPrefCacheImpl implements CacheStorage {
  static const _kLoggedIn = 'logged_in';
  static const _kToken    = 'access_token';
  static const _kRefresh  = 'refresh_token';
  static const _kTheme    = 'theme_dark';

  Future<SharedPreferences> get _p => SharedPreferences.getInstance();

  // SharedPreferences needs no async init
  @override Future<void>    init()                    async {}
  @override Future<bool?>   isLoggedIn()              async => (await _p).getBool(_kLoggedIn);
  @override Future<void>    setLoggedIn(bool s)       async => (await _p).setBool(_kLoggedIn, s);
  @override Future<void>    saveAccessToken(String t) async => (await _p).setString(_kToken, t);
  @override Future<String?> getAccessToken()          async => (await _p).getString(_kToken);
  @override Future<void>    saveRefreshToken(String t)async => (await _p).setString(_kRefresh, t);
  @override Future<String?> getRefreshToken()         async => (await _p).getString(_kRefresh);
  @override Future<bool?>   getThemeMode()            async => (await _p).getBool(_kTheme);
  @override Future<void>    setThemeMode(bool d)      async => (await _p).setBool(_kTheme, d);
  @override Future<void>    clear()                   async => (await _p).clear();
}
