// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/app.dart
//
// ProviderScope receives the Riverpod overrides bridged from GetIt.
// This is how Riverpod providers get concrete implementations without
// calling GetIt directly in the provider file.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

import 'config/di/app_initializer.dart';
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return _RouterAdapterApp();
  }
}

class RiverPodApp extends StatelessWidget {
  const RiverPodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      // Bridge: Riverpod providers receive the same implementations
      // that GetIt registered — no GetIt calls inside provider files.
      overrides: AppInitializer.riverpodOverrides,
      child: _RouterAdapterApp(),
    );
  }
}

/// Reads the IAppRouter from GetIt — works for both GoRouter and AutoRoute.
class _RouterAdapterApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = GetIt.I<IAppRouter>();
    return MaterialApp.router(
      title: 'Pluggable Flutter Architecture',
      theme: AppTheme.light,
      routerConfig: router.routerConfig,
      debugShowCheckedModeBanner: false,
    );
  }
}
