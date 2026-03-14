// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/api/responses/api_response.dart
//
// The abstraction every service method returns.
// Concrete data never leaks raw maps past this boundary.

abstract class ApiResponse<T> {
  T? get data;
  String? get message;
  bool? get success;
  dynamic get error;
  String? get nextPageUrl;
  int? get total;
  String? get token;
}
