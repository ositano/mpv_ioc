// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)

import 'package:flutter/material.dart';
import '../../../../core/components/app_button.dart';
import '../../../../core/enums/enums.dart';
import '../managers/posts_manager.dart';

class PostForm extends StatelessWidget {
  final PostsManager manager;
  const PostForm({super.key, required this.manager});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              ValueListenableBuilder(
                valueListenable: manager.selectedPost,
                builder: (_, post, __) => Text(
                  post != null ? 'Edit Post' : 'Create Post',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  manager.clearSelection();
                  Navigator.of(context).pop();
                },
              )
            ],
          ),
          const SizedBox(height: 16),
          // Title
          ValueListenableBuilder<String>(
            valueListenable: manager.getFieldListenable('title'),
            builder: (_, __, ___) => TextField(
              controller: manager.titleController,
              decoration: InputDecoration(
                labelText: 'Title',
                errorText: manager.getFieldError('title'),
              ),
              onTap: manager.touchField('title'),
            ),
          ),
          const SizedBox(height: 12),
          // Body
          ValueListenableBuilder<String>(
            valueListenable: manager.getFieldListenable('body'),
            builder: (_, __, ___) => TextField(
              controller: manager.bodyController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'Body',
                alignLabelWithHint: true,
                errorText: manager.getFieldError('body'),
              ),
              onTap: manager.touchField('body'),
            ),
          ),
          const SizedBox(height: 20),
          ValueListenableBuilder<bool>(
            valueListenable: manager.isValid(),
            builder: (_, valid, __) => ValueListenableBuilder<RequestStatus>(
              valueListenable: manager.requestStatus,
              builder: (_, status, __) => AppButton(
                label: 'Save Post',
                onPressed: status == RequestStatus.loading ? null : manager.submitPost,
                isLoading: status == RequestStatus.loading,
                icon: Icons.check,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
