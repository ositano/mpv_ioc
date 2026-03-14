// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/cache/cache_storage.dart
//
// Abstract contract for lightweight key-value cache.
// SharedPrefCacheImpl and HiveCacheImpl both implement this.
// Swap in AppInitializer without touching anything else.
abstract class CacheStorage {
  Future<void> init(); // e.g. Hive.initFlutter() — no-op for SharedPrefs
  Future<bool?> isLoggedIn();
  Future<void> setLoggedIn(bool status);
  Future<void> saveAccessToken(String token);
  Future<String?> getAccessToken();
  Future<void> saveRefreshToken(String token);
  Future<String?> getRefreshToken();
  Future<bool?> getThemeMode();
  Future<void> setThemeMode(bool isDark);
  Future<void> clear();
}
