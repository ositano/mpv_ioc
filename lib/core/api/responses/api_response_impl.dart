// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/responses/api_response_impl.dart

import 'api_response.dart';

class ApiResponseImpl<T> implements ApiResponse<T> {
  final T? _data;
  final String? _message;
  final dynamic _error;
  final bool? _success;
  final String? _nextPageUrl;
  final int? _total;
  final String? _token;

  const ApiResponseImpl(
    this._data,
    this._error,
    this._message,
    this._success,
    this._nextPageUrl,
    this._total,
    this._token,
  );

  @override
  T? get data => _data;

  @override
  String? get message => _message ?? '';

  @override
  dynamic get error => _error;

  @override
  bool? get success => _success ?? false;

  @override
  String? get nextPageUrl => _nextPageUrl ?? '';

  @override
  int? get total => _total ?? 0;

  @override
  String? get token => _token;
}
