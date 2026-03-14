// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// test/helpers/mocks.dart
//
// Run `flutter pub run build_runner build --delete-conflicting-outputs`
// to generate mocks.mocks.dart from this file.
//
// All test files import from this single generated file — one place
// to update when new abstractions are added.

import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';

import 'package:mpv_ioc/core/api/network/network_info.dart';
import 'package:mpv_ioc/core/api/services/api_client.dart';
import 'package:mpv_ioc/core/api/services/api_services.dart';
import 'package:mpv_ioc/core/helpers/widget_helper.dart';
import 'package:mpv_ioc/core/routes/app_router.dart';
import 'package:mpv_ioc/core/storage/cache/cache_storage.dart';
import 'package:mpv_ioc/core/storage/database/database_storage.dart';
import 'package:mpv_ioc/core/utils/navigation_service.dart';
import 'package:mpv_ioc/features/post_detail/repository/post_detail_repository.dart';
import 'package:mpv_ioc/features/posts/repository/posts_repository.dart';

@GenerateMocks([
  // Core infrastructure
  NetworkInfo,
  IApiClient,
  ApiServices,
  IAppRouter,
  NavigationService,
  // Storage
  CacheStorage,
  DatabaseStorage,
  // Feature repositories
  PostsRepository,
  PostDetailRepository,
  // UI helpers
  IWidgetHelper,
  // http.Client — for HttpApiClient tests
  http.Client,
])
void main() {}
