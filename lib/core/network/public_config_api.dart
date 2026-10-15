import 'package:dio/dio.dart';

import '../config/constants.dart';
import '../config/public_app_config.dart';

class PublicConfigApi {
  const PublicConfigApi(this._dio);

  final Dio _dio;

  Future<PublicAppConfig> fetch({required String currentVersion}) async {
    final response = await _dio.get<Map<String, dynamic>>(
      ApiEndpoints.configPublic,
      // Cache-bust without a non-safelisted Cache-Control request header.
      queryParameters: {
        'current_version': currentVersion,
        '_': DateTime.now().millisecondsSinceEpoch,
      },
      options: Options(extra: {'anonymous': true}),
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('Public configuration response was empty.');
    }
    return PublicAppConfig.fromJson(data);
  }
}
