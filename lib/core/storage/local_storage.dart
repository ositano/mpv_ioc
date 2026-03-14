// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/core/storage/local_storage.dart
import 'cache/cache_storage.dart';
import 'database/database_storage.dart';

// Combines both storage layers under one facade.
abstract class LocalStorage implements CacheStorage, DatabaseStorage {}
