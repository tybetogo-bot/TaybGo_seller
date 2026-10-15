/// Auth and refresh work are bound to the login that started the request.
library;

import 'dart:async';

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_config.dart';
import '../../config/constants.dart';
import '../../services/session_lifecycle.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._prefs, {this.onUnauthorized, Dio? refreshDio})
    : _refreshDio =
          refreshDio ??
          Dio(
            BaseOptions(
              baseUrl: AppConfig.apiBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ),
          );

  final SharedPreferences _prefs;
  final Future<void> Function()? onUnauthorized;
  final Dio _refreshDio;
  final _session = SessionLifecycle.instance;
  Future<String?>? _refresh;
  int? _refreshGeneration;

  bool _authEndpoint(String path) =>
      path.contains('/auth/otp/') ||
      path.endsWith('/auth/token/') ||
      path.contains('/auth/token/refresh') ||
      path.contains('/auth/token/blacklist');

  bool _stale(RequestOptions options) =>
      options.extra['anonymous'] != true &&
      options.extra['sessionCleanup'] != true &&
      !_session.isCurrent(options.extra['loginGeneration'] as int);

  DioException _cancel(RequestOptions options) => DioException(
    requestOptions: options,
    type: DioExceptionType.cancel,
    message: 'The login that started this request has ended.',
  );

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.extra.putIfAbsent('loginGeneration', () => _session.generation);
    if (_stale(options)) return handler.reject(_cancel(options));
    if (options.extra['sessionCleanup'] != true &&
        options.extra['anonymous'] != true) {
      final token = _prefs.getString(StorageKeys.authToken);
      if (token != null && token.isNotEmpty && !_authEndpoint(options.path)) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (_stale(response.requestOptions)) {
      return handler.reject(_cancel(response.requestOptions));
    }
    handler.next(response);
  }

  Future<String?> _rotate(int generation) async {
    final refresh = _prefs.getString(StorageKeys.refreshToken);
    if (refresh == null || refresh.isEmpty) return null;
    final tokens = await _session.rotate(generation, () async {
      final response = await _refreshDio.post(
        ApiEndpoints.tokenRefresh,
        data: {'refresh': refresh},
      );
      return (
        response.data['access'] as String,
        response.data['refresh'] as String? ?? refresh,
      );
    });
    if (!_session.isCurrent(generation) || tokens == null) return null;
    final (access, rotated) = tokens;
    return _session.serializeWrite(() async {
      if (!_session.isCurrent(generation)) return null;
      await _prefs.setString(StorageKeys.authToken, access);
      await _prefs.setString(StorageKeys.refreshToken, rotated);
      return access;
    });
  }

  void _forceLogout() {
    // Invalidation is synchronous. Do not await the cleanup barrier here:
    // it drains push registrations, which may include this very request.
    final cleanup = onUnauthorized?.call();
    if (cleanup != null) unawaited(cleanup.catchError((Object _) {}));
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final options = err.requestOptions;
    if (_stale(options)) return handler.next(_cancel(options));
    if (err.response?.statusCode != 401 ||
        _authEndpoint(options.path) ||
        options.extra['skipAuthRefresh'] == true ||
        options.extra['anonymous'] == true) {
      return handler.next(err);
    }
    final generation = options.extra['loginGeneration'] as int;
    if (options.extra['authRetried'] == true) {
      _forceLogout();
      return handler.next(err);
    }

    String? access;
    try {
      // Concurrent 401s share rotation. Requests sent before a completed
      // rotation can use its access token without rotating the old refresh twice.
      final saved = _prefs.getString(StorageKeys.authToken);
      if (saved != null &&
          options.headers['Authorization'] != 'Bearer $saved') {
        access = saved;
      } else {
        if (_refresh == null || _refreshGeneration != generation) {
          _refreshGeneration = generation;
          final work = _rotate(generation);
          _refresh = work;
          work.then<void>(
            (_) {
              if (identical(_refresh, work)) _refresh = null;
            },
            onError: (Object _, StackTrace _) {
              if (identical(_refresh, work)) _refresh = null;
            },
          );
        }
        access = await _refresh;
      }
    } on DioException catch (error) {
      // A transport/server failure is not evidence of a rejected login.
      if (_session.isCurrent(generation) &&
          [400, 401, 403].contains(error.response?.statusCode)) {
        _forceLogout();
      }
      return handler.next(error);
    } catch (_) {
      return handler.next(err);
    }
    if (!_session.isCurrent(generation)) return handler.next(_cancel(options));
    if (access == null) {
      _forceLogout();
      return handler.next(err);
    }
    options.extra['authRetried'] = true;
    options.headers['Authorization'] = 'Bearer $access';
    if (options.path == ApiEndpoints.tokenVerify) {
      options.data = {'token': access};
    }
    // Retry once without recursively rotating. Keep generation checks on the
    // response, and distinguish a retry failure from a refresh rejection.
    try {
      final response = await _refreshDio.fetch(options);
      if (!_session.isCurrent(generation)) {
        return handler.next(_cancel(options));
      }
      return handler.resolve(response);
    } on DioException catch (error) {
      if (_session.isCurrent(generation) && error.response?.statusCode == 401) {
        _forceLogout();
      }
      return handler.next(error);
    }
  }
}
