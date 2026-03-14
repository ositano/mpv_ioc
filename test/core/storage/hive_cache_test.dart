// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/core/storage/hive_cache_test.dart
//
// HiveCacheImpl — uses hive_test to set up a temp directory so
// Hive can operate without a real filesystem path.

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_test/hive_ce_test.dart';

import 'package:mpv_ioc/core/storage/cache/hive_cache_impl.dart';

void main() {
  late HiveCacheImpl cache;

  setUp(() async {
    await setUpTestHive();
    cache = HiveCacheImpl();
    await cache.init();
  });

  tearDown(() async {
    await tearDownTestHive();
  });

  group('loggedIn', () {
    test('isLoggedIn returns null before being set', () async {
      expect(await cache.isLoggedIn(), isNull);
    });

    test('setLoggedIn true → isLoggedIn returns true', () async {
      await cache.setLoggedIn(true);
      expect(await cache.isLoggedIn(), isTrue);
    });

    test('setLoggedIn false → isLoggedIn returns false', () async {
      await cache.setLoggedIn(false);
      expect(await cache.isLoggedIn(), isFalse);
    });
  });

  group('accessToken', () {
    test('getAccessToken returns null before save', () async {
      expect(await cache.getAccessToken(), isNull);
    });

    test('saveAccessToken → getAccessToken round-trip', () async {
      await cache.saveAccessToken('hive-token-999');
      expect(await cache.getAccessToken(), equals('hive-token-999'));
    });
  });

  group('refreshToken', () {
    test('saveRefreshToken → getRefreshToken round-trip', () async {
      await cache.saveRefreshToken('hive-refresh');
      expect(await cache.getRefreshToken(), equals('hive-refresh'));
    });
  });

  group('themeMode', () {
    test('setThemeMode true persists', () async {
      await cache.setThemeMode(true);
      expect(await cache.getThemeMode(), isTrue);
    });

    test('setThemeMode false persists', () async {
      await cache.setThemeMode(false);
      expect(await cache.getThemeMode(), isFalse);
    });
  });

  group('clear', () {
    test('clear wipes all keys', () async {
      await cache.saveAccessToken('tok');
      await cache.setLoggedIn(true);
      await cache.clear();

      expect(await cache.getAccessToken(), isNull);
      expect(await cache.isLoggedIn(), isNull);
    });
  });
}
