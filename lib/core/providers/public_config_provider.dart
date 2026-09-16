import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../config/public_app_config.dart';
import '../network/public_config_api.dart';
import 'providers.dart';

final installedVersionProvider = FutureProvider<String>((ref) async {
  final packageInfo = await PackageInfo.fromPlatform();
  return packageInfo.version;
});

final publicConfigApiProvider = Provider<PublicConfigApi>((ref) {
  return PublicConfigApi(ref.watch(publicDioProvider));
});

final publicAppConfigProvider = FutureProvider<PublicAppConfig>((ref) async {
  final currentVersion = await ref.watch(installedVersionProvider.future);
  return ref
      .watch(publicConfigApiProvider)
      .fetch(currentVersion: currentVersion);
});
