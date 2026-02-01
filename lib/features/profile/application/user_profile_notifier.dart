/// User profile state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/user_api.dart';
import '../../../core/providers/providers.dart';
import '../data/datasources/user_remote_data_source.dart';
import '../data/repositories/user_repository.dart';

/// User profile state
class UserProfileState {
  const UserProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
  });

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

      state = state.copyWith(
        profile: result.data,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: $e',
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? name,
    String? email,
    int? age,
  }) async {
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

      state = state.copyWith(
        profile: result.data,
        isLoading: false,
      );

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

      // Seller profile update returns BasicProfile (name, phone, age only)
      // Update the existing profile with the new values if we have a profile
      if (state.profile != null && result.data != null) {
        final updatedProfile = UserProfile(
          id: state.profile!.id,
          name: result.data!.name,
          email: state.profile!.email,
          phone: result.data!.phone,
          age: result.data!.age,
          roles: state.profile!.roles,
          createdAt: state.profile!.createdAt,
          updatedAt: DateTime.now(),
        );
        state = state.copyWith(
          profile: updatedProfile,
          isLoading: false,
        );
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
final userProfileProvider = NotifierProvider<UserProfileNotifier, UserProfileState>(
  UserProfileNotifier.new,
);
