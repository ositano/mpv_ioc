// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/features/posts/repository/posts_repository.dart
//
// ─────────────────────────────────────────────────────────────────
//  Repository interface for the Posts feature.
//  The Cubit and the Riverpod StateNotifier both depend on this
//  abstraction — neither cares about ApiServices or IApiClient.
// ─────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';

import '../../../core/api/exception/failure.dart';
import '../../../core/api/responses/api_response.dart';
import '../../../core/api/services/api_services.dart';
import '../../../core/data/models/post.dart';

abstract class PostsRepository {
  Future<Either<Failure, ApiResponse<List<Post>>>> getPosts();
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id);
  Future<Either<Failure, ApiResponse<Post>>> createPost({
    required String title,
    required String body,
  });
  Future<Either<Failure, ApiResponse<Post>>> updatePost({
    required int id,
    required String title,
    required String body,
  });
  Future<Either<Failure, ApiResponse<void>>> deletePost(int id);
}

class PostsRepositoryImpl implements PostsRepository {
  final ApiServices apiServices;
  const PostsRepositoryImpl({required this.apiServices});

  @override
  Future<Either<Failure, ApiResponse<List<Post>>>> getPosts() =>
      apiServices.getPosts();

  @override
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id) =>
      apiServices.getPost(id);

  @override
  Future<Either<Failure, ApiResponse<Post>>> createPost({
    required String title,
    required String body,
  }) =>
      apiServices.createPost(title: title, body: body, userId: 1);

  @override
  Future<Either<Failure, ApiResponse<Post>>> updatePost({
    required int id,
    required String title,
    required String body,
  }) =>
      apiServices.updatePost(id: id, title: title, body: body);

  @override
  Future<Either<Failure, ApiResponse<void>>> deletePost(int id) =>
      apiServices.deletePost(id);
}
