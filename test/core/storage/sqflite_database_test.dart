// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/core/storage/sqflite_database_test.dart
//
// SqfliteDatabaseImpl — uses sqflite_common_ffi for an in-memory
// SQLite database that runs on all platforms including CI.

import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'package:mpv_ioc/core/storage/database/sqflite_database_impl.dart';

void main() {
  late SqfliteDatabaseImpl db;

  setUpAll(() {
    // Initialise the FFI-based sqflite for non-mobile platforms
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    db = SqfliteDatabaseImpl();
    await db.init(); // creates in-memory DB via sqflite_common_ffi
  });

  tearDown(() async {
    await db.clearDrafts();
  });

  final tDraft1 = {'title': 'Draft 1', 'body': 'Body 1', 'userId': 1};
  final tDraft2 = {'title': 'Draft 2', 'body': 'Body 2', 'userId': 1};

  group('saveDraft / getDrafts', () {
    test('getDrafts returns empty list initially', () async {
      final drafts = await db.getDrafts();
      expect(drafts, isEmpty);
    });

    test('saveDraft adds one entry', () async {
      await db.saveDraft(tDraft1);
      final drafts = await db.getDrafts();
      expect(drafts, hasLength(1));
      expect(drafts.first['title'], equals('Draft 1'));
    });

    test('multiple saveDraft calls accumulate', () async {
      await db.saveDraft(tDraft1);
      await db.saveDraft(tDraft2);
      final drafts = await db.getDrafts();
      expect(drafts, hasLength(2));
    });

    test('getDrafts returns in descending savedAt order', () async {
      await db.saveDraft(tDraft1);
      await Future.delayed(const Duration(milliseconds: 10));
      await db.saveDraft(tDraft2);

      final drafts = await db.getDrafts();
      // Draft2 was saved later so should come first (DESC order)
      expect(drafts.first['title'], equals('Draft 2'));
    });

    test('saveDraft stores all provided fields', () async {
      await db.saveDraft({'title': 'T', 'body': 'B', 'userId': 7});
      final drafts = await db.getDrafts();

      expect(drafts.first['title'],  equals('T'));
      expect(drafts.first['body'],   equals('B'));
      expect(drafts.first['userId'], equals(7));
      expect(drafts.first['savedAt'], isNotNull);
    });
  });

  group('deleteDraft', () {
    test('deletes only the specified record by local id', () async {
      await db.saveDraft(tDraft1);
      await db.saveDraft(tDraft2);

      final before = await db.getDrafts();
      final idToDelete = before.first['id'] as int;

      await db.deleteDraft(idToDelete);

      final after = await db.getDrafts();
      expect(after, hasLength(1));
      expect(
        after.every((d) => d['id'] != idToDelete),
        isTrue,
      );
    });

    test('deleting a non-existent id does not throw', () async {
      await db.saveDraft(tDraft1);
      expect(() => db.deleteDraft(99999), returnsNormally);
    });
  });

  group('clearDrafts', () {
    test('removes all drafts', () async {
      await db.saveDraft(tDraft1);
      await db.saveDraft(tDraft2);
      await db.clearDrafts();

      expect(await db.getDrafts(), isEmpty);
    });

    test('clearDrafts on empty table does not throw', () async {
      expect(() => db.clearDrafts(), returnsNormally);
    });
  });
}
