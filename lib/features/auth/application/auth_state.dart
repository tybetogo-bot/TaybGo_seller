import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
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
    this.expiresInSeconds = 60,
    this.debugOtp,
  });

  final String phone;
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
  const AuthError({required this.message, this.previousState});

  final String message;
  final AuthState? previousState;
}

/// Auth notifier for managing authentication state (Riverpod 3.x compatible)
class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository _repository;

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

  /// Request OTP for phone number
  Future<void> requestOtp({required String phone}) async {
    state = const AuthLoading();

    final result = await _repository.requestOtp(phone: phone);

    if (result.failure != null) {
      state = AuthError(
        message: result.failure!.message,
        previousState: const AuthUnauthenticated(),
      );
    } else {
      state = AuthOtpSent(
        phone: phone,
        expiresInSeconds: 60,
        debugOtp: result.data?.otp,
      );
    }
  }

  /// Verify OTP code
  Future<void> verifyOtp(String code) async {
    final currentState = state;

    // Get the OTP state - either from current state or from error's previous state
    AuthOtpSent? otpState;
    if (currentState is AuthOtpSent) {
      otpState = currentState;
    } else if (currentState is AuthError && currentState.previousState is AuthOtpSent) {
      // Allow retry after error by using the previous OTP state
      otpState = currentState.previousState as AuthOtpSent;
    }

    if (otpState == null) {
      state = const AuthError(
        message: 'Invalid state for OTP verification',
      );
      return;
    }

    state = const AuthLoading();

    final result = await _repository.verifyOtp(
      phone: otpState.phone,
      code: code,
    );

    if (result.failure != null) {
      state = AuthError(
        message: result.failure!.message,
        previousState: otpState,
      );
    } else {
      state = AuthAuthenticated(phone: otpState.phone);

      // Trigger restaurant fetch after successful login
      ref.read(restaurantProvider.notifier).fetchRestaurants();
    }
  }

  /// Resend OTP
  Future<void> resendOtp() async {
    final currentState = state;
    if (currentState is! AuthOtpSent) return;

    await requestOtp(phone: currentState.phone);
  }

  /// Go back to phone input (from OTP screen)
  void goBackToPhoneInput() {
    state = const AuthUnauthenticated();
  }

  /// Logout
  Future<void> logout() async {
    state = const AuthLoading();

    await _repository.logout();
    state = const AuthUnauthenticated();
  }

  /// Refresh token
  Future<bool> refreshToken() async {
    final result = await _repository.refreshToken();
    return result.failure == null;
  }

  /// Check if user is logged in
  bool get isLoggedIn => state is AuthAuthenticated;
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
