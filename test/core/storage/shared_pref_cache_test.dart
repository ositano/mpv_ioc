// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/core/storage/shared_pref_cache_test.dart
//
// SharedPrefCacheImpl — uses SharedPreferences.setMockInitialValues()
// so no platform channel is needed.

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mpv_ioc/core/storage/cache/shared_pref_cache_impl.dart';

void main() {
  late SharedPrefCacheImpl cache;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    cache = SharedPrefCacheImpl();
    await cache.init(); // no-op for SharedPrefs but keeps interface consistent
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
      await cache.saveAccessToken('tok-abc-123');
      expect(await cache.getAccessToken(), equals('tok-abc-123'));
    });

    test('saving empty string overwrites old token', () async {
      await cache.saveAccessToken('original');
      await cache.saveAccessToken('');
      expect(await cache.getAccessToken(), equals(''));
    });
  });

  group('refreshToken', () {
    test('saveRefreshToken → getRefreshToken round-trip', () async {
      await cache.saveRefreshToken('refresh-xyz');
      expect(await cache.getRefreshToken(), equals('refresh-xyz'));
    });
  });

  group('themeMode', () {
    test('getThemeMode returns null before set', () async {
      expect(await cache.getThemeMode(), isNull);
    });

    test('setThemeMode true → getThemeMode returns true', () async {
      await cache.setThemeMode(true);
      expect(await cache.getThemeMode(), isTrue);
    });
  });

  group('clear', () {
    test('clear removes all stored values', () async {
      await cache.saveAccessToken('tok');
      await cache.setLoggedIn(true);
      await cache.clear();

      expect(await cache.getAccessToken(), isNull);
      expect(await cache.isLoggedIn(), isNull);
    });
  });
}
