// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
import 'package:dartz/dartz.dart';
import '../../../core/api/exception/failure.dart';
import '../../../core/api/responses/api_response.dart';
import '../../../core/api/services/api_services.dart';
import '../../../core/data/models/post.dart';
import '../../../core/storage/local_storage.dart';

abstract class PostDetailRepository {
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id);
  Future<Post> getPostDetail(int postId);
}

class PostDetailRepositoryImpl implements PostDetailRepository {
  final ApiServices apiServices;
  final LocalStorage localStorage;
  const PostDetailRepositoryImpl({required this.apiServices, required this.localStorage});
  @override
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id) =>
      apiServices.getPost(id);
  @override
  Future<Post> getPostDetail(int postId) =>
      localStorage.getPost(postId);
}
