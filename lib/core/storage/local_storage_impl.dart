// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/local_storage_impl.dart
import '../data/models/post.dart';
import 'cache/cache_storage.dart';
import 'database/database_storage.dart';
import 'local_storage.dart';

class LocalStorageImpl implements LocalStorage {
  final CacheStorage cache;
  final DatabaseStorage db;

  LocalStorageImpl({required this.cache, required this.db});

  // ── CacheStorage ────────────────────────────────────────────────
  @override Future<void>    init()                    => cache.init();
  @override Future<bool?>   isLoggedIn()              => cache.isLoggedIn();
  @override Future<void>    setLoggedIn(bool s)       => cache.setLoggedIn(s);
  @override Future<void>    saveAccessToken(String t) => cache.saveAccessToken(t);
  @override Future<String?> getAccessToken()          => cache.getAccessToken();
  @override Future<void>    saveRefreshToken(String t)=> cache.saveRefreshToken(t);
  @override Future<String?> getRefreshToken()         => cache.getRefreshToken();
  @override Future<bool?>   getThemeMode()            => cache.getThemeMode();
  @override Future<void>    setThemeMode(bool d)      => cache.setThemeMode(d);
  @override Future<void>    clear()                   => cache.clear();

  // ── DatabaseStorage ─────────────────────────────────────────────
  @override Future<void>                       savePost(Post p)  => db.savePost(p);
  @override Future<Post> getPost(int postId)                     => db.getPost(postId);
  @override Future<void>                       deletePost(int id) => db.deletePost(id);
}
