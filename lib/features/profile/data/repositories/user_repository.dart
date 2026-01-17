/// User profile repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/user_api.dart';
import '../datasources/user_remote_data_source.dart';

/// Result type for repository methods
typedef UserResult<T> = ({Failure? failure, T? data});

/// User repository interface
abstract class UserRepository {
  /// Get authenticated user's profile
  Future<UserResult<UserProfile>> getProfile();

  /// Update user profile
  Future<UserResult<UserProfile>> updateProfile(Map<String, dynamic> data);

  /// Get seller profile (returns BasicProfile with name, phone, age)
  Future<UserResult<BasicProfile>> getSellerProfile();

  /// Update seller profile (returns BasicProfile with name, phone, age)
  Future<UserResult<BasicProfile>> updateSellerProfile(
    Map<String, dynamic> data,
  );
}

/// Implementation of user repository
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl({
    required UserDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final UserDataSource _remoteDataSource;

  @override
  Future<UserResult<UserProfile>> getProfile() async {
    try {
      final profile = await _remoteDataSource.getProfile();
      return (failure: null, data: profile);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<UserResult<UserProfile>> updateProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final profile = await _remoteDataSource.updateProfile(data);
      return (failure: null, data: profile);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<UserResult<BasicProfile>> getSellerProfile() async {
    try {
      final profile = await _remoteDataSource.getSellerProfile();
      return (failure: null, data: profile);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<UserResult<BasicProfile>> updateSellerProfile(
    Map<String, dynamic> data,
  ) async {
    try {
      final profile = await _remoteDataSource.updateSellerProfile(data);
      return (failure: null, data: profile);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }
}
