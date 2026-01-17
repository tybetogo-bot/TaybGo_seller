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
import '../network/user_api.dart';
import '../../features/auth/data/datasources/auth_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/repositories/auth_repository.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

/// Provider for Dio instance
final dioProvider = Provider<Dio>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ApiClient.getInstance(prefs);
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
  return AuthRepositoryImpl(
    remoteDataSource: dataSource,
    prefs: prefs,
  );
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
