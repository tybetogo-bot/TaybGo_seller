/// Riverpod providers for dependency injection
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/api_client.dart';
import '../network/auth_api.dart';
import '../network/restaurant_api.dart';
import '../network/menu_api.dart';
import '../network/orders_api.dart';
import '../network/coupons_api.dart';
import '../network/support_api.dart';
import '../network/user_api.dart';
import '../../features/support/data/repositories/support_repository.dart';
import '../services/cloudinary_service.dart';
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Global callback for handling unauthorized access (401 errors)
/// This is set from the main app initialization to avoid circular dependencies
void Function()? globalUnauthorizedCallback;

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);

  return ApiClient.getInstance(
    prefs,
    onUnauthorized: () async {
      // Call the global callback if set
      globalUnauthorizedCallback?.call();
    },
  );
});

/// Provider for AuthApi
final authApiProvider = Provider<AuthApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AuthApi(dio);
});

/// Provider for AuthDataSource
final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  final authApi = ref.watch(authApiProvider);
  return AuthRemoteDataSource(authApi);
});

/// Provider for AuthRepository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthRepositoryImpl(remoteDataSource: dataSource, prefs: prefs);
});

/// Provider for RestaurantApi
final restaurantApiProvider = Provider<RestaurantApi>((ref) {
  final dio = ref.watch(dioProvider);
  return RestaurantApi(dio);
});

/// Provider for MenuApi
final menuApiProvider = Provider<MenuApi>((ref) {
  final dio = ref.watch(dioProvider);
  return MenuApi(dio);
});

/// Provider for OrdersApi
final ordersApiProvider = Provider<OrdersApi>((ref) {
  final dio = ref.watch(dioProvider);
  return OrdersApi(dio);
});

/// Provider for CouponsApi
final couponsApiProvider = Provider<CouponsApi>((ref) {
  final dio = ref.watch(dioProvider);
  return CouponsApi(dio);
});

/// Provider for UserApi
final userApiProvider = Provider<UserApi>((ref) {
  final dio = ref.watch(dioProvider);
  return UserApi(dio);
});

/// Provider for dedicated Cloudinary Dio instance (no auth interceptor)
final cloudinaryDioProvider = Provider<Dio>((ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    ),
  );
});

/// Provider for CloudinaryService
final cloudinaryServiceProvider = Provider<CloudinaryService>((ref) {
  final dio = ref.watch(cloudinaryDioProvider);
  return CloudinaryService(dio);
});

/// Provider for public Dio instance (no auth interceptor)
/// Used for public-facing APIs that don't require authentication (e.g., public menu)
final publicDioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final authenticatedDio = ApiClient.getInstance(prefs);

  return Dio(
    BaseOptions(
      baseUrl: authenticatedDio.options.baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );
});

/// Provider for public MenuApi (no authentication required)
final publicMenuApiProvider = Provider<MenuApi>((ref) {
  final dio = ref.watch(publicDioProvider);
  return MenuApi(dio);
});

/// Provider for public RestaurantApi (no authentication required)
final publicRestaurantApiProvider = Provider<RestaurantApi>((ref) {
  final dio = ref.watch(publicDioProvider);
  return RestaurantApi(dio);
});

/// Provider for SupportApi
final supportApiProvider = Provider<SupportApi>((ref) {
  final dio = ref.watch(dioProvider);
  return SupportApi(dio);
});

/// Provider for SupportRepository
final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final api = ref.watch(supportApiProvider);
  return SupportRepositoryImpl(api: api);
});
