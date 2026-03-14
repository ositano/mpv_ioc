// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
import 'package:dartz/dartz.dart';
import '../../../core/api/exception/failure.dart';
import '../../../core/api/responses/api_response.dart';
import '../../../core/api/services/api_services.dart';
import '../../../core/data/models/post.dart';

abstract class PostDetailRepository {
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id);
}

class PostDetailRepositoryImpl implements PostDetailRepository {
  final ApiServices apiServices;
  const PostDetailRepositoryImpl({required this.apiServices});
  @override
  Future<Either<Failure, ApiResponse<Post>>> getPost(int id) =>
      apiServices.getPost(id);
}
