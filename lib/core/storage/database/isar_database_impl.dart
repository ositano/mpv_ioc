// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/database/isar_database_impl.dart
//
// DatabaseStorage backed by Isar (high-performance NoSQL).
//
// To activate:
//   1. Uncomment isar + isar_flutter_libs in pubspec.yaml
//   2. Run: flutter pub run build_runner build
//   3. Replace the stub body below with real Isar collection calls
//   4. Register with: sl.registerLazySingleton<DatabaseStorage>(() => IsarDatabaseImpl())
//
// The interface is IDENTICAL to SqfliteDatabaseImpl — the rest of the
// app never needs to know which database is running underneath.

// import 'package:isar/isar.dart';
// import 'package:path_provider/path_provider.dart';
import '../../data/models/post.dart';
import 'database_storage.dart';

// @Collection()
// class DraftPost { ... }  ← define your Isar collection here

class IsarDatabaseImpl implements DatabaseStorage {
  // late Isar _isar;

  @override
  Future<void> init() async {
    // final dir = await getApplicationDocumentsDirectory();
    // _isar = await Isar.open([DraftPostSchema], directory: dir.path);
    throw UnimplementedError(
      'Uncomment isar in pubspec.yaml and implement the collection schema.',
    );
  }

  @override
  Future<void> savePost(Post post) =>
      throw UnimplementedError();

  @override
  Future<Post> getPost(int postId) =>
      throw UnimplementedError();

  @override
  Future<void> deletePost(int localId) =>
      throw UnimplementedError();

}
