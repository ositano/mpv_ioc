// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/services/api_services_impl.dart
//
// Implements ApiServices by delegating to IApiClient.
// Still has zero knowledge of whether Dio or http is underneath.

import 'package:dartz/dartz.dart';

import '../exception/failure.dart';
import '../responses/api_response.dart';
import '../../data/models/post.dart';
import '../../enums/enums.dart';
import 'api_client.dart';
import 'api_services.dart';

class ApiServicesImpl implements ApiServices {
  final IApiClient apiClient;

  const ApiServicesImpl({required this.apiClient});

  @override
  Future<Either<Failure, ApiResponse<List<Post>>>> getPosts() {
    return apiClient.request(
      '/posts',
      MethodType.get,
      (data) => (data as List).map((e) => Post.fromJson(e)).toList(),
      {},
    );
  }

  @override
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id) {
    return apiClient.request(
      '/posts/$id',
      MethodType.get,
      (data) => Post.fromJson(data),
      {},
    );
  }

  @override
  Future<Either<Failure, ApiResponse<Post>>> createPost({
    required String title,
    required String body,
    required int userId,
  }) {
    return apiClient.request(
      '/posts',
      MethodType.post,
      (data) => Post.fromJson(data),
      {'title': title, 'body': body, 'userId': userId},
    );
  }

  @override
  Future<Either<Failure, ApiResponse<Post>>> updatePost({
    required int id,
    required String title,
    required String body,
  }) {
    return apiClient.request(
      '/posts/$id',
      MethodType.put,
      (data) => Post.fromJson(data),
      {'title': title, 'body': body},
    );
  }

  @override
  Future<Either<Failure, ApiResponse<void>>> deletePost(int id) {
    return apiClient.request(
      '/posts/$id',
      MethodType.delete,
      (_) {},
      {},
    );
  }
}
