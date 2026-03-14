// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/widgets/post_form_test.dart
//
// Widget tests for PostForm:
//  • Renders "Create Post" heading when no post is selected
//  • Renders "Edit Post" heading when a post is pre-selected
//  • Title and body TextFields display controller text
//  • Save button is disabled while form is invalid
//  • Save button is enabled when form is valid
//  • Save button shows loading spinner when requestStatus == loading
//  • Tapping Save calls manager.submitPost
//  • Tapping close icon calls manager.clearSelection and pops

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mpv_ioc/core/enums/enums.dart';
import 'package:mpv_ioc/features/posts/presentation/managers/posts_manager.dart';
import 'package:mpv_ioc/features/posts/presentation/widgets/post_form.dart';

import '../../../helpers/test_data.dart';
import '../../../helpers/test_setup.dart';

// ── Helpers ────────────────────────────────────────────────────────

Widget _pumpForm(PostsManagerImpl manager) {
  return MaterialApp(
    home: Scaffold(
      body: SingleChildScrollView(
        child: PostForm(manager: manager),
      ),
    ),
  );
}

void main() {
  late PostsManagerImpl manager;

  setUp(() {
    setupGetIt();
    manager = PostsManagerImpl();
  });

  tearDown(() async {
    manager.dispose();
    await tearDownGetIt();
  });

  // ── Heading ────────────────────────────────────────────────────

  group('heading', () {
    testWidgets('shows "Create Post" when no post is selected', (tester) async {
      await tester.pumpWidget(_pumpForm(manager));
      expect(find.text('Create Post'), findsOneWidget);
      expect(find.text('Edit Post'),   findsNothing);
    });

    testWidgets('shows "Edit Post" when a post is selected', (tester) async {
      manager.selectPost(tPost1);
      await tester.pumpWidget(_pumpForm(manager));
      await tester.pump();

      expect(find.text('Edit Post'),   findsOneWidget);
      expect(find.text('Create Post'), findsNothing);
    });
  });

  // ── TextFields ────────────────────────────────────────────────

  group('TextFields', () {
    testWidgets('renders Title and Body fields', (tester) async {
      await tester.pumpWidget(_pumpForm(manager));

      expect(find.widgetWithText(TextField, 'Title'), findsNothing); // label ≠ text
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('title field shows controller text', (tester) async {
      manager.titleController.text = 'Prefilled title';
      await tester.pumpWidget(_pumpForm(manager));
      await tester.pump();

      expect(find.text('Prefilled title'), findsOneWidget);
    });

    testWidgets('body field shows controller text', (tester) async {
      manager.bodyController.text = 'Prefilled body';
      await tester.pumpWidget(_pumpForm(manager));
      await tester.pump();

      expect(find.text('Prefilled body'), findsOneWidget);
    });

    testWidgets('typing in title field updates manager field value',
        (tester) async {
      await tester.pumpWidget(_pumpForm(manager));

      final titleField = find.byType(TextField).first;
      await tester.enterText(titleField, 'Typed title');
      await tester.pump();

      expect(manager.getFieldValue<String>('title'), equals('Typed title'));
    });
  });

  // ── Save button state ─────────────────────────────────────────

  group('Save button', () {
    testWidgets('Save Post button is present', (tester) async {
      await tester.pumpWidget(_pumpForm(manager));
      expect(find.text('Save Post'), findsOneWidget);
    });

    testWidgets('button callback is null (disabled) when form is invalid',
        (tester) async {
      await tester.pumpWidget(_pumpForm(manager));
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Post'),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('button callback is non-null (enabled) when form is valid',
        (tester) async {
      manager.titleController.text = 'Title';
      manager.bodyController.text  = 'Body';

      await tester.pumpWidget(_pumpForm(manager));
      await tester.pump();

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Post'),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('shows CircularProgressIndicator when loading', (tester) async {
      manager.titleController.text = 'T';
      manager.bodyController.text  = 'B';
      manager.requestStatus.value  = RequestStatus.loading;

      await tester.pumpWidget(_pumpForm(manager));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Save Post'), findsNothing);
    });
  });

  // ── Submit callback ───────────────────────────────────────────

  group('submit', () {
    testWidgets('tapping Save calls manager.submitPost', (tester) async {
      var submitted = false;
      manager.onSubmitPost = () => submitted = true;
      manager.titleController.text = 'Valid title';
      manager.bodyController.text  = 'Valid body';

      await tester.pumpWidget(_pumpForm(manager));
      await tester.pump();

      await tester.tap(find.text('Save Post'));
      await tester.pump();

      expect(submitted, isTrue);
    });
  });

  // ── Validation errors ─────────────────────────────────────────

  group('validation errors', () {
    testWidgets('shows title error after touch with empty value',
        (tester) async {
      await tester.pumpWidget(_pumpForm(manager));

      // Touch the title field (tap it) to trigger touched state
      await tester.tap(find.byType(TextField).first);
      await tester.pump();

      // Force the error to show by marking touched directly
      manager.updateField('title', '');
      await tester.pump();

      expect(find.text('Title is required'), findsOneWidget);
    });
  });
}
