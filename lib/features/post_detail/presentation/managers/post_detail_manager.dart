// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
import 'package:flutter/material.dart';
import '../../../../core/data/models/post.dart';
import '../../../../core/manager/state_manager.dart';

abstract class PostDetailManager extends StateManager {
  ValueNotifier<Post?> get post;
  VoidCallback? onLoad;
  void load();
}

class PostDetailManagerImpl extends StateManager implements PostDetailManager {
  @override late final ValueNotifier<Post?> post;
  @override VoidCallback? onLoad;
  final Post initialPost;

  PostDetailManagerImpl({required this.initialPost}) {
    post = ValueNotifier<Post?>(initialPost);
  }

  @override void load() => onLoad?.call();

  @override
  void dispose() {
    post.dispose();
    super.dispose();
  }
}
