// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/services/dio_api_client.dart
//
// Concrete IApiClient backed by the Dio library.
// Swap to HttpApiClient without touching any other file.

import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';

import '../../../config/di/app_config.dart';
import '../../enums/enums.dart';
import '../exception/failure.dart';
import '../network/network_info.dart';
import '../responses/api_response.dart';
import '../responses/api_response_impl.dart';
import 'api_client.dart';

class DioApiClient implements IApiClient {
  late final Dio _dio;
  final NetworkInfo networkInfo;

  DioApiClient({required this.networkInfo}) {
    _dio = Dio(
      BaseOptions(
        baseUrl: env.baseUrl,
        headers: {'content-type': 'application/json'},
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────────

  bool _isSuccess(int? code) => code != null && code >= 200 && code < 300;

  ApiResponse<T> _parseResponse<T>(
    Response response,
    T Function(dynamic) fromJson,
  ) {
    final body = response.data;
    // Support both { data: ... } envelope and raw list/object
    final raw = (body is Map && body.containsKey('data')) ? body['data'] : body;
    return ApiResponseImpl<T>(
      fromJson(raw),
      null,
      body is Map ? body['message'] as String? : null,
      body is Map ? body['success'] as bool? : null,
      body is Map ? body['next_page_url'] as String? : null,
      body is Map ? body['total'] as int? : null,
      body is Map ? body['token'] as String? : null,
    );
  }

  Failure _handleDioError(DioException e) {
    if (e.error is SocketException) return InternetFailure();
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return ConnectionTimeOutFailure();
      case DioExceptionType.badResponse:
        final data = e.response?.data;
        final msg = data is Map ? data['message'] as String? : null;
        return ValidationFailure(msg ?? e.response?.statusMessage ?? 'Error');
      default:
        return UnknownFailure(message: e.message);
    }
  }

  // ── IApiClient ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ApiResponse<T>>> request<T>(
    String url,
    MethodType method,
    T Function(dynamic) fromJson,
    dynamic params, {
    Map<String, dynamic>? queryParameters,
    dynamic interceptor,
  }) async {
    if (interceptor != null) _dio.interceptors.add(interceptor);

    try {
      final Response resp;
      switch (method) {
        case MethodType.post:
          resp = await _dio.post(url,
              data: params, queryParameters: queryParameters);
          break;
        case MethodType.put:
          resp = await _dio.put(url,
              data: params, queryParameters: queryParameters);
          break;
        case MethodType.delete:
          resp = await _dio.delete(url,
              data: params, queryParameters: queryParameters);
          break;
        case MethodType.patch:
          resp = await _dio.patch(url,
              data: params, queryParameters: queryParameters);
          break;
        default:
          resp = await _dio.get(url,
              data: params, queryParameters: queryParameters);
      }

      if (_isSuccess(resp.statusCode)) {
        return right(_parseResponse(resp, fromJson));
      }
      return left(ValidationFailure(resp.statusMessage ?? 'Request failed'));
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (_) {
      return left(BadResponseFailure());
    }
  }

  @override
  Future<Either<Failure, ApiResponse<T>>> multipartRequest<T>(
    String url,
    MethodType method,
    T Function(dynamic) fromJson,
    dynamic params, {
    Map<String, dynamic>? queryParameters,
    dynamic interceptor,
  }) async {
    // Multipart is Dio-specific; params is a FormData
    if (interceptor != null) _dio.interceptors.add(interceptor);

    try {
      final opts = Options(contentType: Headers.multipartFormDataContentType);
      final Response resp = method == MethodType.put
          ? await _dio.put(url,
              data: params, options: opts, queryParameters: queryParameters)
          : await _dio.post(url,
              data: params, options: opts, queryParameters: queryParameters);

      if (_isSuccess(resp.statusCode)) {
        return right(_parseResponse(resp, fromJson));
      }
      return left(ValidationFailure(resp.statusMessage ?? 'Upload failed'));
    } on DioException catch (e) {
      return left(_handleDioError(e));
    } catch (_) {
      return left(BadResponseFailure());
    }
  }
}
