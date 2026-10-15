import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/constants.dart';
import '../../../core/errors/failures.dart';
import '../../../core/i18n/i18n.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/location_permission_service.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/services/session_lifecycle.dart';
import '../../notifications/application/notifications_notifier.dart';
import '../../orders/application/orders_notifier.dart';
import '../../profile/application/user_profile_notifier.dart';
import '../../restaurant/application/restaurant_state.dart';
import '../data/repositories/auth_repository.dart';

/// Authentication state
sealed class AuthState {
  const AuthState();
}

/// Initial state - checking auth status
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// Loading state
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// OTP has been sent, waiting for verification
class AuthOtpSent extends AuthState {
  const AuthOtpSent({
    required this.phone,
    required this.targetRole,
    this.expiresInSeconds = 60,
    this.debugOtp,
  });

  final String phone;
  final String targetRole;
  final int expiresInSeconds;

  /// Debug OTP (only available in dev/test environments)
  final String? debugOtp;

  /// Formatted phone for display
  String get formattedPhone => phone;
}

/// User is authenticated
class AuthAuthenticated extends AuthState {
  const AuthAuthenticated({required this.phone});

  final String phone;
}

/// User is not authenticated
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// Authentication error
class AuthError extends AuthState {
  const AuthError({required this.message, this.previousState, this.code});

  final String message;
  final AuthState? previousState;
  final String? code;
}

enum SellerAccessStatus { seller, needsOnboarding, forbidden }

/// Auth notifier for managing authentication state (Riverpod 3.x compatible)
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;
  bool _isValidatingSession = false;
  int _authAttempt = 0;
  final _session = SessionLifecycle.instance;

  @override
  AuthState build() {
    _repository = ref.watch(authRepositoryProvider);
    // Check auth status synchronously since SharedPreferences is already initialized
    return _getInitialAuthState();
  }

  /// Get initial auth state synchronously
  AuthState _getInitialAuthState() {
    try {
      print('🔵 [AuthNotifier] Checking auth status...');
      final isAuth = _repository.isAuthenticated();
      print('🔵 [AuthNotifier] isAuthenticated: $isAuth');

      if (isAuth) {
        final phone = _repository.getStoredPhone();
        print('🔵 [AuthNotifier] Stored phone: $phone');
        if (phone != null) {
          print('🟢 [AuthNotifier] Returning AuthAuthenticated');
          return AuthAuthenticated(phone: phone);
        }
      }
      print('🟡 [AuthNotifier] Returning AuthUnauthenticated');
      return const AuthUnauthenticated();
    } catch (e, stack) {
      print('🔴 [AuthNotifier] Error checking auth status: $e');
      print('🔴 [AuthNotifier] Stack: $stack');
      return const AuthUnauthenticated();
    }
  }

  Future<void> loginWithPassword({
    required String phone,
    required String password,
  }) async {
    if (_session.authenticated) await _endSession(manual: true);
    final attempt = ++_authAttempt;
    await _session.settled;
    if (attempt != _authAttempt) return;
    state = const AuthLoading();
    final result = await _repository.loginWithPassword(
      phone: phone,
      password: password,
    );

    if (attempt != _authAttempt || _session.closing) return;
    if (result.failure != null) {
      state = AuthError(
        message: result.failure!.message,
        code: result.failure is AuthFailure
            ? (result.failure! as AuthFailure).code
            : null,
        previousState: const AuthUnauthenticated(),
      );
      return;
    }

    await _completeSellerAuthentication(
      phone: phone,
      previousState: const AuthUnauthenticated(),
    );
  }

  /// Request OTP for phone number
  Future<void> requestOtp({
    required String phone,
    String targetRole = UserRoles.seller,
  }) async {
    final attempt = ++_authAttempt;
    state = const AuthLoading();

    final result = await _repository.requestOtp(
      phone: phone,
      targetRole: targetRole,
    );
    if (attempt != _authAttempt) return;

    if (result.failure != null) {
      state = AuthError(
        message: result.failure!.message,
        code: result.failure is AuthFailure
            ? (result.failure! as AuthFailure).code
            : null,
        previousState: const AuthUnauthenticated(),
      );
    } else {
      state = AuthOtpSent(
        phone: phone,
        targetRole: targetRole,
        expiresInSeconds: 60,
        debugOtp: result.data?.otp,
      );
    }
  }

  /// Verify OTP code
  Future<void> verifyOtp(String code) async {
    final attempt = ++_authAttempt;
    final currentState = state;

    // Get the OTP state - either from current state or from error's previous state
    AuthOtpSent? otpState;
    if (currentState is AuthOtpSent) {
      otpState = currentState;
    } else if (currentState is AuthError &&
        currentState.previousState is AuthOtpSent) {
      // Allow retry after error by using the previous OTP state
      otpState = currentState.previousState as AuthOtpSent;
    }

    if (otpState == null) {
      state = const AuthError(message: 'Invalid state for OTP verification');
      return;
    }

    state = const AuthLoading();

    final result = await _repository.verifyOtp(
      phone: otpState.phone,
      code: code,
      targetRole: otpState.targetRole,
    );
    if (attempt != _authAttempt || _session.closing) return;

    if (result.failure != null) {
      state = AuthError(
        message: result.failure!.message,
        previousState: otpState,
      );
    } else {
      await _completeSellerAuthentication(
        phone: otpState.phone,
        previousState: otpState,
      );
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    final currentState = state;
    if (currentState is! AuthOtpSent) return;

    await requestOtp(
      phone: currentState.phone,
      targetRole: currentState.targetRole,
    );
  }

  /// Go back to phone input (from OTP screen)
  void goBackToPhoneInput() {
    _authAttempt++;
    state = const AuthUnauthenticated();
  }

  void clearError() {
    if (state is AuthError) state = const AuthUnauthenticated();
  }

  /// Logout
  Future<void> logout() => _endSession(manual: true);

  Future<void> _endSession({bool manual = false}) {
    _authAttempt++;
    final prefs = ref.read(sharedPreferencesProvider);
    final access = prefs.getString(StorageKeys.authToken);
    final token = prefs.getString(StorageKeys.fcmToken);
    final push = ref.read(pushNotificationServiceProvider);
    // Stop registration and navigation before any await or HTTP request.
    push.pause();
    state = const AuthUnauthenticated();
    ref.read(locationPermissionAutoRequestProvider.notifier).clear();
    ref.read(notificationsPollingProvider.notifier).stop();
    ref.read(ordersPollingProvider.notifier).stop();
    ref.read(userProfilePollingProvider.notifier).stop();
    return _session.end(() async {
      try {
        await _session.drainPush();
        if (manual) {
          // A token may have finished creation while logout was starting.
          final device = token ?? prefs.getString(StorageKeys.fcmToken);
          if (device != null) {
            try {
              await ref
                  .read(notificationsApiProvider)
                  .unregisterDeviceToken(token: device, access: access);
            } catch (_) {}
          }
          try {
            await _repository.logout();
          } catch (_) {}
        }
      } finally {
        try {
          await push.cleanup();
        } finally {
          await _repository.clearAuthData();
        }
      }
    });
  }

  /// Proactively validate the stored session before using protected routes.
  Future<bool> validateSession() async {
    if (_isValidatingSession) {
      return state is AuthAuthenticated;
    }

    if (state is! AuthAuthenticated) {
      return false;
    }

    final generation = _session.generation;
    _isValidatingSession = true;
    try {
      final isValid = await _repository.validateStoredSession();
      if (!_session.isCurrent(generation)) return false;
      final accessStatus = isValid
          ? await _getSellerAccessStatus()
          : SellerAccessStatus.forbidden;
      if (!_session.isCurrent(generation)) return false;
      if (!isValid || accessStatus == SellerAccessStatus.forbidden) {
        await _endSession();
        return false;
      }

      if (accessStatus == SellerAccessStatus.needsOnboarding) {
        ref.read(restaurantProvider.notifier).setOnboardingPending();
      }

      return true;
    } finally {
      _isValidatingSession = false;
    }
  }

  /// Clear local auth state after an unauthorized response elsewhere in the app.
  Future<void> handleUnauthorized() => _endSession();

  /// Refresh token
  Future<bool> refreshToken() async {
    final generation = _session.generation;
    final result = await _repository.refreshToken();
    if (!_session.isCurrent(generation)) return false;
    if ([400, 401, 403].contains(result.failure?.statusCode)) {
      await _endSession();
    }
    return result.failure == null;
  }

  /// Check if user is logged in
  bool get isLoggedIn => state is AuthAuthenticated;

  Future<void> _completeSellerAuthentication({
    required String phone,
    required AuthState previousState,
  }) async {
    final generation = _session.generation;
    final accessStatus = await _getSellerAccessStatus();
    if (!_session.isCurrent(generation)) return;
    if (accessStatus == SellerAccessStatus.forbidden) {
      await _endSession();
      state = AuthError(
        message: 'errors.auth.forbidden'.tr,
        previousState: previousState,
      );
      return;
    }

    _session.accept(generation);
    state = AuthAuthenticated(phone: phone);
    ref.read(locationPermissionAutoRequestProvider.notifier).queueAfterLogin();

    if (accessStatus == SellerAccessStatus.needsOnboarding) {
      ref.read(restaurantProvider.notifier).setOnboardingPending();
    } else {
      ref.read(restaurantProvider.notifier).fetchRestaurants();
    }
  }

  Future<SellerAccessStatus> _getSellerAccessStatus() async {
    try {
      final profile = await ref.read(userApiProvider).getProfile();
      if (profile.hasRole(UserRoles.seller)) {
        return SellerAccessStatus.seller;
      }

      if (profile.roles.isEmpty) {
        return SellerAccessStatus.needsOnboarding;
      }

      return SellerAccessStatus.forbidden;
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      if (statusCode == 401 || statusCode == 403) {
        return SellerAccessStatus.forbidden;
      }
      return SellerAccessStatus.seller;
    } catch (_) {
      return SellerAccessStatus.seller;
    }
  }
}

/// Provider for auth state (Riverpod 3.x style)
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

/// Provider to check if user is authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider) is AuthAuthenticated;
});

/// Provider for current user phone
final currentUserPhoneProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  if (authState is AuthAuthenticated) {
    return authState.phone;
  }
  return null;
});
