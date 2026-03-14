// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/data/models/post.dart
//
// Using plain fromJson/toJson here to keep the sample dependency-light.
// In your real project you use freezed — the architecture doesn't care which.

class Post {
  final int? id;
  final int? userId;
  final String title;
  final String body;

  const Post({
    this.id,
    this.userId,
    required this.title,
    required this.body,
  });

  factory Post.fromJson(Map<String, dynamic> json) => Post(
        id: json['id'] as int?,
        userId: json['userId'] as int?,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        if (userId != null) 'userId': userId,
        'title': title,
        'body': body,
      };

  Post copyWith({int? id, int? userId, String? title, String? body}) => Post(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        body: body ?? this.body,
      );
}
