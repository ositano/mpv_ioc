// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/database/database_storage.dart
//
// Abstract contract for structured/relational local storage.
// SqliteDatabaseImpl (sqflite) and IsarDatabaseImpl both implement this.
//
// Expand the interface with your domain-specific methods
// (e.g. saveDraftPost, getCachedFeed) as your app grows.
abstract class DatabaseStorage {
  Future<void> init();

  // ── Example: offline draft posts ─────────────────────────────
  Future<void>         saveDraft(Map<String, dynamic> post);
  Future<List<Map<String, dynamic>>> getDrafts();
  Future<void>         deleteDraft(int localId);
  Future<void>         clearDrafts();
}
