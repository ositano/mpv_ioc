// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/services/http_api_client.dart
//
// ─────────────────────────────────────────────────────────────────
//  Concrete IApiClient backed by the `http` package.
//  Identical interface to DioApiClient — swap it in app_initializer.dart
//  with a single line change and zero other modifications.
//
//  Note: multipartRequest uses http.MultipartRequest.
// ─────────────────────────────────────────────────────────────────

import 'dart:convert';
import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:http/http.dart' as http;

import '../../../config/di/app_config.dart';
import '../../enums/enums.dart';
import '../exception/failure.dart';
import '../network/network_info.dart';
import '../responses/api_response.dart';
import '../responses/api_response_impl.dart';
import 'api_client.dart';

class HttpApiClient implements IApiClient {
  final NetworkInfo networkInfo;
  final http.Client _client;

  // Optional bearer-token storage hook (set by interceptor equivalent)
  String? _bearerToken;
  void setBearerToken(String? token) => _bearerToken = token;

  HttpApiClient({required this.networkInfo, http.Client? client})
      : _client = client ?? http.Client();

  // ── Helpers ───────────────────────────────────────────────────────

  bool _isSuccess(int code) => code >= 200 && code < 300;

  Uri _uri(String path, {Map<String, dynamic>? queryParameters}) {
    final base = Uri.parse(env.baseUrl);
    return Uri(
      scheme: base.scheme,
      host: base.host,
      port: base.port,
      path: '${base.path}$path',
      queryParameters: queryParameters?.map(
        (k, v) => MapEntry(k, v.toString()),
      ),
    );
  }

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (_bearerToken != null && _bearerToken!.isNotEmpty)
          'Authorization': 'Bearer $_bearerToken',
      };

  ApiResponse<T> _parse<T>(http.Response resp, T Function(dynamic) fromJson) {
    final body = jsonDecode(resp.body) as dynamic;
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

  Failure _handleError(Object e) {
    if (e is SocketException) return InternetFailure();
    if (e is http.ClientException) return ConnectionTimeOutFailure();
    return UnknownFailure(message: e.toString());
  }

  // ── IApiClient ────────────────────────────────────────────────────

  @override
  Future<Either<Failure, ApiResponse<T>>> request<T>(
    String url,
    MethodType method,
    T Function(dynamic) fromJson,
    dynamic params, {
    Map<String, dynamic>? queryParameters,
    dynamic interceptor, // not used in http – handled via setBearerToken()
  }) async {
    try {
      final uri = _uri(url, queryParameters: queryParameters);
      final body = params != null ? jsonEncode(params) : null;
      final headers = _headers();

      http.Response resp;
      switch (method) {
        case MethodType.post:
          resp = await _client.post(uri, headers: headers, body: body);
          break;
        case MethodType.put:
          resp = await _client.put(uri, headers: headers, body: body);
          break;
        case MethodType.delete:
          resp = await _client.delete(uri, headers: headers, body: body);
          break;
        case MethodType.patch:
          resp = await _client.patch(uri, headers: headers, body: body);
          break;
        default:
          resp = await _client.get(uri, headers: headers);
      }

      if (_isSuccess(resp.statusCode)) return right(_parse(resp, fromJson));

      final errBody = jsonDecode(resp.body);
      final msg = errBody is Map ? errBody['message'] as String? : null;
      return left(ValidationFailure(msg ?? 'Request failed'));
    } catch (e) {
      return left(_handleError(e));
    }
  }

  /// Multipart upload using dart:http's MultipartRequest.
  @override
  Future<Either<Failure, ApiResponse<T>>> multipartRequest<T>(
    String url,
    MethodType method,
    T Function(dynamic) fromJson,
    dynamic params, {
    Map<String, dynamic>? queryParameters,
    dynamic interceptor,
  }) async {
    try {
      final uri = _uri(url, queryParameters: queryParameters);
      final req = http.MultipartRequest(
        method == MethodType.put ? 'PUT' : 'POST',
        uri,
      );

      if (_bearerToken != null && _bearerToken!.isNotEmpty) {
        req.headers['Authorization'] = 'Bearer $_bearerToken';
      }

      // params is expected to be Map<String, dynamic> with String/File values
      if (params is Map<String, dynamic>) {
        for (final entry in params.entries) {
          if (entry.value is File) {
            final file = entry.value as File;
            req.files.add(
              await http.MultipartFile.fromPath(entry.key, file.path),
            );
          } else if (entry.value != null) {
            req.fields[entry.key] = entry.value.toString();
          }
        }
      }

      final streamed = await req.send();
      final resp = await http.Response.fromStream(streamed);

      if (_isSuccess(resp.statusCode)) return right(_parse(resp, fromJson));

      final errBody = jsonDecode(resp.body);
      final msg = errBody is Map ? errBody['message'] as String? : null;
      return left(ValidationFailure(msg ?? 'Upload failed'));
    } catch (e) {
      return left(_handleError(e));
    }
  }
}
