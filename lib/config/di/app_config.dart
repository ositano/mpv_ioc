// Author: Green Onyeji (https://github.com/ositano/) (https://www.linkedin.com/in/green-onyeji-11608a97/)
// lib/config/di/app_config.dart
//
// Single source of truth for environment-specific values.
// Call BuildFlavor.init() in main.dart before anything else.

import '../../core/enums/enums.dart';

BuildFlavor get env => _env;
BuildFlavor _env = BuildFlavor._init(
  flavor: Flavor.debug,
  baseUrl: 'https://jsonplaceholder.typicode.com', // public mock API
  appName: 'Pluggable Arch Sample',
);

class BuildFlavor {
  final String baseUrl;
  final String appName;
  final Flavor flavor;

  BuildFlavor._init({
    required this.flavor,
    required this.baseUrl,
    required this.appName,
  });

  static void init({
    required Flavor flavor,
    required String baseUrl,
    required String appName,
  }) =>
      _env = BuildFlavor._init(
        flavor: flavor,
        baseUrl: baseUrl,
        appName: appName,
      );
}
