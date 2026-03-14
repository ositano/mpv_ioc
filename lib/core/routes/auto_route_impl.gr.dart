// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i3;
import 'package:flutter/widgets.dart' as _i4;
import 'package:mpv_ioc/core/data/models/post.dart' as _i5;
import 'package:mpv_ioc/core/routes/auto_route_impl.dart' as _i1;
import 'package:mpv_ioc/features/posts/presentation/screens/posts_riverpod_screen.dart'
    as _i2;

/// generated route for
/// [_i1.PostDetailAutoRoutePage]
class PostDetailRoute extends _i3.PageRouteInfo<PostDetailRouteArgs> {
  PostDetailRoute({
    _i4.Key? key,
    required _i5.Post post,
    List<_i3.PageRouteInfo>? children,
  }) : super(
         PostDetailRoute.name,
         args: PostDetailRouteArgs(key: key, post: post),
         initialChildren: children,
       );

  static const String name = 'PostDetailRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<PostDetailRouteArgs>();
      return _i1.PostDetailAutoRoutePage(key: args.key, post: args.post);
    },
  );
}

class PostDetailRouteArgs {
  const PostDetailRouteArgs({this.key, required this.post});

  final _i4.Key? key;

  final _i5.Post post;

  @override
  String toString() {
    return 'PostDetailRouteArgs{key: $key, post: $post}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! PostDetailRouteArgs) return false;
    return key == other.key && post == other.post;
  }

  @override
  int get hashCode => key.hashCode ^ post.hashCode;
}

/// generated route for
/// [_i1.PostsAutoRoutePage]
class PostsRoute extends _i3.PageRouteInfo<void> {
  const PostsRoute({List<_i3.PageRouteInfo>? children})
    : super(PostsRoute.name, initialChildren: children);

  static const String name = 'PostsRoute';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i1.PostsAutoRoutePage();
    },
  );
}

/// generated route for
/// [_i2.PostsRiverpodScreen]
class PostsRiverpodScreen extends _i3.PageRouteInfo<void> {
  const PostsRiverpodScreen({List<_i3.PageRouteInfo>? children})
    : super(PostsRiverpodScreen.name, initialChildren: children);

  static const String name = 'PostsRiverpodScreen';

  static _i3.PageInfo page = _i3.PageInfo(
    name,
    builder: (data) {
      return const _i2.PostsRiverpodScreen();
    },
  );
}
