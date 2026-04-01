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

  /// Delete user account
  Future<void> deleteAccount();

  /// List saved addresses
  Future<List<Map<String, dynamic>>> listAddresses();

  /// Create a new address
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> data);

  /// Update an existing address
  Future<Map<String, dynamic>> updateAddress(int id, Map<String, dynamic> data);
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

  @override
  Future<void> deleteAccount() async {
    await _api.deleteAccount();
  }

  @override
  Future<List<Map<String, dynamic>>> listAddresses() async {
    return await _api.listAddresses();
  }

  @override
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> data) async {
    return await _api.createAddress(data);
  }

  @override
  Future<Map<String, dynamic>> updateAddress(
    int id,
    Map<String, dynamic> data,
  ) async {
    return await _api.updateAddress(id, data);
  }
}
