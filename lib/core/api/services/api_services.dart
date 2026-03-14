// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/services/api_services.dart
//
// High-level API contract. Repositories depend on this abstraction,
// not on any HTTP library.

import 'package:dartz/dartz.dart';

import '../exception/failure.dart';
import '../responses/api_response.dart';
import '../../data/models/post.dart';

abstract class ApiServices {
  Future<Either<Failure, ApiResponse<List<Post>>>> getPosts();
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id);
  Future<Either<Failure, ApiResponse<Post>>> createPost({
    required String title,
    required String body,
    required int userId,
  });
  Future<Either<Failure, ApiResponse<Post>>> updatePost({
    required int id,
    required String title,
    required String body,
  });
  Future<Either<Failure, ApiResponse<void>>> deletePost(int id);
}
