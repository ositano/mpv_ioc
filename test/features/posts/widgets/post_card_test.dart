// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/features/posts/widgets/post_card_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mpv_ioc/features/posts/presentation/widgets/post_card.dart';

import '../../../helpers/test_data.dart';

Widget _wrap(Widget child) =>
    MaterialApp(home: Scaffold(body: child));

void main() {
  group('PostCard rendering', () {
    testWidgets('displays the post title', (tester) async {
      await tester.pumpWidget(_wrap(PostCard(
        post: tPost1,
        onTap: () {},
        onEdit: () {},
        onDelete: () {},
      )));

      expect(find.text(tPost1.title), findsOneWidget);
    });

    testWidgets('displays the post body (truncated)', (tester) async {
      await tester.pumpWidget(_wrap(PostCard(
        post: tPost1,
        onTap: () {},
        onEdit: () {},
        onDelete: () {},
      )));

      expect(find.textContaining(tPost1.body.substring(0, 5)), findsOneWidget);
    });

    testWidgets('shows the post id chip', (tester) async {
      await tester.pumpWidget(_wrap(PostCard(
        post: tPost1,
        onTap: () {},
        onEdit: () {},
        onDelete: () {},
      )));

      expect(find.text('#${tPost1.id}'), findsOneWidget);
    });

    testWidgets('shows edit and delete icon buttons', (tester) async {
      await tester.pumpWidget(_wrap(PostCard(
        post: tPost1,
        onTap: () {},
        onEdit: () {},
        onDelete: () {},
      )));

      expect(find.byIcon(Icons.edit_outlined),   findsOneWidget);
      expect(find.byIcon(Icons.delete_outline),  findsOneWidget);
    });
  });

  group('PostCard callbacks', () {
    testWidgets('onTap fires when card is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(_wrap(PostCard(
        post: tPost1,
        onTap: () => tapped = true,
        onEdit: () {},
        onDelete: () {},
      )));

      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });

    testWidgets('onEdit fires when edit button is tapped', (tester) async {
      var edited = false;
      await tester.pumpWidget(_wrap(PostCard(
        post: tPost1,
        onTap: () {},
        onEdit: () => edited = true,
        onDelete: () {},
      )));

      await tester.tap(find.byIcon(Icons.edit_outlined));
      expect(edited, isTrue);
    });

    testWidgets('onDelete fires when delete button is tapped', (tester) async {
      var deleted = false;
      await tester.pumpWidget(_wrap(PostCard(
        post: tPost1,
        onTap: () {},
        onEdit: () {},
        onDelete: () => deleted = true,
      )));

      await tester.tap(find.byIcon(Icons.delete_outline));
      expect(deleted, isTrue);
    });
  });
}
