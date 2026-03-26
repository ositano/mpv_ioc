// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/database/sqflite_database_impl.dart
//
// DatabaseStorage backed by SQLite via the sqflite package.
// Register with: sl.registerLazySingleton<DatabaseStorage>(() => SqfliteDatabaseImpl())
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../data/models/post.dart';
import 'database_storage.dart';

class SqfliteDatabaseImpl implements DatabaseStorage {
  static const _dbName    = 'app.db';
  static const _tablePost = 'draft_posts';
  Database? _db;

  @override
  Future<void> init() async {
    final dir  = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);
    _db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_tablePost (
            id      INTEGER PRIMARY KEY AUTOINCREMENT,
            title   TEXT NOT NULL,
            body    TEXT NOT NULL,
            userId  INTEGER NOT NULL DEFAULT 1,
            savedAt TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Database get _database {
    assert(_db != null, 'Call init() before using SqfliteDatabaseImpl');
    return _db!;
  }

  @override
  Future<void> savePost(Post post) async {
    await _database.insert(
      _tablePost,
      {...post.toJson(), 'savedAt': DateTime.now().toIso8601String()},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Post> getPost(int postId) =>
      throw UnimplementedError();

  @override
  Future<void> deletePost(int postId) =>
      _database.delete(_tablePost, where: 'id = ?', whereArgs: [postId]);

}
