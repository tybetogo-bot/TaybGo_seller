/// User profile state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_api.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/polling_service.dart';
import '../data/datasources/user_remote_data_source.dart';
import '../data/repositories/user_repository.dart';

/// User profile state
class UserProfileState {
  const UserProfileState({this.profile, this.isLoading = false, this.error});

  final UserProfile? profile;
  final bool isLoading;
  final String? error;

  UserProfileState copyWith({
    UserProfile? profile,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return UserProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// User profile notifier (Riverpod 3.x)
class UserProfileNotifier extends Notifier<UserProfileState> {
  late final UserRepository _repository;

  @override
  UserProfileState build() {
    _repository = ref.watch(userRepositoryProvider);
    Future.microtask(() => loadProfile());
    return const UserProfileState(isLoading: true);
  }

  /// Load user profile from API
  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getProfile();

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      state = state.copyWith(profile: result.data, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: $e',
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile({String? name, String? email, int? age}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (age != null) data['age'] = age;

      final result = await _repository.updateProfile(data);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return false;
      }

      state = state.copyWith(profile: result.data, isLoading: false);

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update profile: $e',
      );
      return false;
    }
  }

  /// Update seller profile
  Future<bool> updateSellerProfile(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.updateSellerProfile(data);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return false;
      }

      // Seller profile update returns BasicProfile with name/phone/birthdate/document.
      // Update the existing profile with the new values if we have a profile
      if (state.profile != null && result.data != null) {
        final updatedProfile = UserProfile(
          id: state.profile!.id,
          name: result.data!.name,
          email: state.profile!.email,
          phone: result.data!.phone,
          birthdate: result.data!.birthdate ?? state.profile!.birthdate,
          age: result.data!.age,
          roles: state.profile!.roles,
          createdAt: state.profile!.createdAt,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(profile: updatedProfile, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }

      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update seller profile: $e',
      );
      return false;
    }
  }

  /// Delete user account and all related data
  Future<bool> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.deleteAccount();

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to delete account: $e',
      );
      return false;
    }
  }

  /// Refresh profile
  Future<void> refresh() async {
    await loadProfile();
  }

  /// Silent refresh - only updates UI if data has changed
  /// Used by polling to avoid unnecessary rebuilds
  Future<bool> silentRefresh() async {
    try {
      final result = await _repository.getProfile();

      if (result.failure != null || result.data == null) {
        return false;
      }

      final newProfile = result.data!;

      // Check if data has actually changed
      if (_hasProfileChanged(newProfile)) {
        state = state.copyWith(profile: newProfile, clearError: true);
        return true;
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  /// Compare profile to detect changes
  bool _hasProfileChanged(UserProfile newProfile) {
    if (state.profile == null) return true;

    final oldProfile = state.profile!;

    // Check key fields for changes
    return oldProfile.id != newProfile.id ||
        oldProfile.name != newProfile.name ||
        oldProfile.email != newProfile.email ||
        oldProfile.phone != newProfile.phone ||
        oldProfile.birthdate != newProfile.birthdate ||
        oldProfile.age != newProfile.age ||
        oldProfile.updatedAt != newProfile.updatedAt;
  }

  /// Update address (PATCH /api/addresses/{id}/)
  Future<bool> updateAddress(int addressId, Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.updateAddress(addressId, data);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return false;
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to update address: $e',
      );
      return false;
    }
  }

  /// Create address (POST /api/addresses/)
  Future<Map<String, dynamic>?> createAddress(Map<String, dynamic> data) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.createAddress(data);

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return null;
      }

      state = state.copyWith(isLoading: false);
      return result.data;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to create address: $e',
      );
      return null;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Provider for user data source
final userDataSourceProvider = Provider<UserDataSource>((ref) {
  final api = ref.watch(userApiProvider);
  return UserRemoteDataSource(api);
});

/// Provider for user repository
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final dataSource = ref.watch(userDataSourceProvider);
  return UserRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for user profile state
final userProfileProvider =
    NotifierProvider<UserProfileNotifier, UserProfileState>(
      UserProfileNotifier.new,
    );

/// Provider for seller profile basics (including registration document URL)
final sellerProfileProvider = FutureProvider<BasicProfile?>((ref) async {
  final repository = ref.watch(userRepositoryProvider);
  final result = await repository.getSellerProfile();
  if (result.failure != null) {
    throw Exception(result.failure!.message);
  }
  return result.data;
});

/// Provider for profile polling service
///
/// This provider creates a polling service that refreshes user profile every 5 seconds.
/// Only updates UI when there's new data to avoid unnecessary rebuilds.
/// Usage:
/// ```dart
/// // In a widget or notifier:
/// final pollingNotifier = ref.read(userProfilePollingProvider.notifier);
/// pollingNotifier.start(); // Start polling
/// pollingNotifier.stop();  // Stop polling
/// ```
final userProfilePollingProvider =
    NotifierProvider<UserProfilePollingNotifier, PollingState>(
      UserProfilePollingNotifier.new,
    );

/// Notifier for user profile polling
class UserProfilePollingNotifier extends Notifier<PollingState> {
  PollingService? _service;
  static const _defaultInterval = Duration(seconds: 5);

  @override
  PollingState build() {
    ref.onDispose(() {
      _service?.dispose();
    });

    // Initialize the polling service
    Future.microtask(() => _initializeService());

    return const PollingState(interval: _defaultInterval);
  }

  void _initializeService() {
    _service?.dispose();
    _service = PollingService(
      onPoll: () async {
        // Use silentRefresh to only update UI when data changes
        await ref.read(userProfileProvider.notifier).silentRefresh();
      },
      interval: state.interval,
      debugLabel: 'UserProfilePolling',
    );
  }

  /// Start polling for profile updates
  void start() {
    if (_service == null) {
      _initializeService();
    }
    state = state.copyWith(isEnabled: true);
    _service?.start();
  }

  /// Stop polling
  void stop() {
    state = state.copyWith(isEnabled: false);
    _service?.stop();
  }

  /// Toggle polling on/off
  void toggle() {
    if (state.isEnabled) {
      stop();
    } else {
      start();
    }
  }

  /// Update the polling interval
  void setInterval(Duration interval) {
    state = state.copyWith(interval: interval);
    if (_service != null) {
      final wasPolling = _service!.isPolling;
      _service?.dispose();
      _service = PollingService(
        onPoll: () async {
          // Use silentRefresh to only update UI when data changes
          await ref.read(userProfileProvider.notifier).silentRefresh();
        },
        interval: interval,
        debugLabel: 'UserProfilePolling',
      );
      if (wasPolling) {
        _service?.start();
      }
    }
  }

  /// Trigger an immediate poll
  Future<void> pollNow() async {
    await _service?.pollNow();
  }

  /// Whether polling is currently active
  bool get isPolling => _service?.isPolling ?? false;
}
