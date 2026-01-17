/// Notifications repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/notifications_remote_data_source.dart';
import '../models/notification_model.dart';

/// Result type for repository methods
typedef NotificationsResult<T> = ({Failure? failure, T? data});

/// Notifications repository interface
abstract class NotificationsRepository {
  /// Get all notifications for the authenticated user
  Future<NotificationsResult<List<NotificationModel>>> getNotifications();

  /// Mark a single notification as read
  Future<NotificationsResult<NotificationModel>> markAsRead(int notificationId);

  /// Mark multiple notifications as read
  Future<NotificationsResult<void>> markAllAsRead(List<int> notificationIds);

  /// Delete a notification
  Future<NotificationsResult<void>> deleteNotification(int notificationId);

  /// Register device token for push notifications
  Future<NotificationsResult<void>> registerDeviceToken({
    required String token,
    String? deviceType,
  });
}

/// Implementation of notifications repository
class NotificationsRepositoryImpl implements NotificationsRepository {
  NotificationsRepositoryImpl({
    required NotificationsDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final NotificationsDataSource _remoteDataSource;

  @override
  Future<NotificationsResult<List<NotificationModel>>> getNotifications() async {
    try {
      final notifications = await _remoteDataSource.getNotifications();
      return (failure: null, data: notifications);
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
  Future<NotificationsResult<NotificationModel>> markAsRead(int notificationId) async {
    try {
      final notification = await _remoteDataSource.markAsRead(notificationId);
      return (failure: null, data: notification);
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
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<NotificationsResult<void>> markAllAsRead(List<int> notificationIds) async {
    try {
      await _remoteDataSource.markAllAsRead(notificationIds);
      return (failure: null, data: null);
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
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<NotificationsResult<void>> deleteNotification(int notificationId) async {
    try {
      await _remoteDataSource.deleteNotification(notificationId);
      return (failure: null, data: null);
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
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<NotificationsResult<void>> registerDeviceToken({
    required String token,
    String? deviceType,
  }) async {
    try {
      await _remoteDataSource.registerDeviceToken(
        token: token,
        deviceType: deviceType,
      );
      return (failure: null, data: null);
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
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }
}
