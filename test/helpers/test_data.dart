// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/helpers/test_data.dart
//
// Centralised test fixtures. All tests import their fake objects from
// here so a model change only needs updating in one place.

import 'package:dartz/dartz.dart';

import 'package:mpv_ioc/core/api/responses/api_response.dart';
import 'package:mpv_ioc/core/api/responses/api_response_impl.dart';
import 'package:mpv_ioc/core/api/exception/failure.dart';
import 'package:mpv_ioc/core/data/models/post.dart';

// ── Fake posts ─────────────────────────────────────────────────────

const tPost1 = Post(id: 1, userId: 1, title: 'First post', body: 'Body one');
const tPost2 = Post(id: 2, userId: 1, title: 'Second post', body: 'Body two');
const tPost3 = Post(id: 3, userId: 2, title: 'Third post', body: 'Body three');

const tPosts = [tPost1, tPost2, tPost3];

const tNewPost = Post(id: 101, userId: 1, title: 'New title', body: 'New body');
const tUpdatedPost = Post(id: 1, userId: 1, title: 'Updated', body: 'Updated body');

// ── ApiResponse helpers ────────────────────────────────────────────

ApiResponse<T> successResponse<T>(T data, {String message = 'Success'}) =>
    ApiResponseImpl<T>(data, null, message, true, null, null, null);

ApiResponse<T> pagedResponse<T>(T data,
    {String? nextPage, int? total}) =>
    ApiResponseImpl<T>(data, null, 'OK', true, nextPage, total, null);

// Typical server JSON envelopes
Map<String, dynamic> get tPostsEnvelope => {
      'data': tPosts.map((p) => p.toJson()).toList(),
      'message': 'Success',
      'success': true,
      'next_page_url': null,
      'total': 3,
    };

Map<String, dynamic> get tPostEnvelope => {
      'data': tPost1.toJson(),
      'message': 'Created',
      'success': true,
    };

Map<String, dynamic> get tRawListJson =>
    {'items': tPosts.map((p) => p.toJson()).toList()};

// ── Either shortcuts ───────────────────────────────────────────────

Either<Failure, ApiResponse<List<Post>>> get tPostsRight =>
    Right(successResponse(tPosts));

Either<Failure, ApiResponse<Post>> get tPostRight =>
    Right(successResponse(tPost1));

Either<Failure, ApiResponse<Post>> get tNewPostRight =>
    Right(successResponse(tNewPost));

Either<Failure, ApiResponse<Post>> get tUpdatedPostRight =>
    Right(successResponse(tUpdatedPost));

Either<Failure, ApiResponse<void>> get tDeleteRight =>
    Right(successResponse<void>(null));

Either<Failure, ApiResponse<List<Post>>> get tFailureLeft =>
    Left(const ValidationFailure('Something went wrong'));

Either<Failure, ApiResponse<Post>> get tPostFailureLeft =>
    Left(const ValidationFailure('Not found'));

const tValidationFailure = ValidationFailure('Validation error');
final tServerFailure = ServerFailure();
final tInternetFailure = InternetFailure();
