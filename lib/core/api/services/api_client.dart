// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/services/api_client.dart
//
// ─────────────────────────────────────────────────────────────────
//  THE key pluggability point for networking.
//  DioApiClient and HttpApiClient both implement this interface.
//  Nothing above this layer knows which HTTP library is in use.
// ─────────────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';

import '../../enums/enums.dart';
import '../exception/failure.dart';
import '../responses/api_response.dart';

abstract class IApiClient {
  /// Standard JSON request.
  Future<Either<Failure, ApiResponse<T>>> request<T>(
    String url,
    MethodType method,
    T Function(dynamic) fromJson,
    dynamic params, {
    Map<String, dynamic>? queryParameters,
    dynamic interceptor,
  });

  /// Multipart / file-upload request.
  Future<Either<Failure, ApiResponse<T>>> multipartRequest<T>(
    String url,
    MethodType method,
    T Function(dynamic) fromJson,
    dynamic params, {
    Map<String, dynamic>? queryParameters,
    dynamic interceptor,
  });
}
