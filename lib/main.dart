// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/main.dart
//
// ─────────────────────────────────────────────────────────────────
//  Every pluggable axis is controlled from here.
//  Change a single enum value to swap an entire layer.
//
//  Axis              Option A (default)      Option B
//  ─────────────── ─────────────────────── ─────────────────────
//  HTTP client       ApiClientType.dio       .httpClient
//  State manager     StateManagerType.cubit  .riverpod
//  Router            RouterType.goRouter     .autoRoute
//  Cache storage     CacheType.sharedPrefs   .hive
//  DB storage        DatabaseType.sqflite    .isar  (needs setup)
// ─────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

import 'app.dart';
import 'config/di/app_config.dart';
import 'config/di/app_initializer.dart';
import 'core/enums/enums.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  BuildFlavor.init(
    flavor: Flavor.debug,
    baseUrl: const String.fromEnvironment(
      'BASE_URL',
      defaultValue: 'https://jsonplaceholder.typicode.com',
    ),
    appName: 'Pluggable Arch Sample',
  );

  await AppInitializer.init(
    apiClient: ApiClientType.httpClient, // ← swap: .httpClient
    stateManager: StateManagerType.riverpod, // ← swap: .riverpod
    router: RouterType.autoRoute, // ← swap: .autoRoute
    cache: CacheType.sharedPrefs, // ← swap: .hive
    database: DatabaseType.sqflite, // ← swap: .isar
  );

  runApp(
    AppInitializer.stateManagerType == StateManagerType.cubit
        ? const App()
        : const RiverPodApp(),
  );
}
