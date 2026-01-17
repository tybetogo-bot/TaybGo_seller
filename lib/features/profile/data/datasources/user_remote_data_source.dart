/// Remote data source for user profile
library;

import '../../../../core/network/user_api.dart';

/// Abstract interface for user data source
abstract class UserDataSource {
  /// Get authenticated user's profile
  Future<UserProfile> getProfile();

  /// Update user profile
  Future<UserProfile> updateProfile(Map<String, dynamic> data);

  /// Get seller profile
  Future<BasicProfile> getSellerProfile();

  /// Update seller profile
  Future<BasicProfile> updateSellerProfile(Map<String, dynamic> data);
}

/// Remote data source implementation using UserApi
class UserRemoteDataSource implements UserDataSource {
  UserRemoteDataSource(this._api);

  final UserApi _api;

  @override
  Future<UserProfile> getProfile() async {
    return await _api.getProfile();
  }

  @override
  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    return await _api.updateProfile(data);
  }

  @override
  Future<BasicProfile> getSellerProfile() async {
    return await _api.getSellerProfile();
  }

  @override
  Future<BasicProfile> updateSellerProfile(Map<String, dynamic> data) async {
    return await _api.updateSellerProfile(data);
  }
}
