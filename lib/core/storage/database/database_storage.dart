// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/database/database_storage.dart
//
// Abstract contract for structured/relational local storage.
// SqliteDatabaseImpl (sqflite) and IsarDatabaseImpl both implement this.
//
// Expand the interface with your domain-specific methods
// (e.g. saveDraftPost, getCachedFeed) as your app grows.
import '../../data/models/post.dart';

abstract class DatabaseStorage {
  Future<void> init();

  // ── Example: offline draft posts ─────────────────────────────
  Future<void>         savePost(Post post);
  Future<Post> getPost(int postId);
  Future<void>         deletePost(int postId);
}
