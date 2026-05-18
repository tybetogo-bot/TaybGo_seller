/// User API service for profile management
library;

import 'package:dio/dio.dart';

import '../config/constants.dart';

int? _calculateAgeFromBirthdate(DateTime? birthdate) {
  if (birthdate == null) return null;

  final now = DateTime.now();
  var age = now.year - birthdate.year;
  final birthdayPassedThisYear =
      now.month > birthdate.month ||
      (now.month == birthdate.month && now.day >= birthdate.day);
  if (!birthdayPassedThisYear) {
    age -= 1;
  }

  return age < 0 ? 0 : age;
}

String _formatDate(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  return '${date.year}-$month-$day';
}

/// User profile model for /api/me/ endpoint (UserMe schema)
class UserProfile {
  final String id;
  final String? name;
  final String? email;
  final String phone;
  final DateTime? birthdate;
  final int? age;
  final List<String> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.id,
    this.name,
    this.email,
    required this.phone,
    this.birthdate,
    this.age,
    this.roles = const [UserRoles.seller],
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    // Handle roles as either a list or a single string
    List<String> parseRoles(dynamic rolesJson) {
      if (rolesJson is List) {
        return rolesJson.map((r) => r.toString()).toList();
      } else if (rolesJson is String) {
        return [rolesJson];
      }
      return [UserRoles.seller];
    }

    final parsedBirthdate = json['birthdate'] != null
        ? DateTime.tryParse(json['birthdate'].toString())
        : null;

    return UserProfile(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String?,
      email: json['email'] as String?,
      phone: json['phone']?.toString() ?? '',
      birthdate: parsedBirthdate,
      age:
          (json['age'] as num?)?.toInt() ??
          _calculateAgeFromBirthdate(parsedBirthdate),
      roles: parseRoles(json['roles'] ?? json['role']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  /// Get primary role (first role in list)
  String get role => roles.isNotEmpty ? roles.first : UserRoles.seller;

  /// Check if user has a specific role
  bool hasRole(String role) => roles.contains(role);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      'phone': phone,
      if (birthdate != null) 'birthdate': _formatDate(birthdate!),
      if (age != null) 'age': age,
      'roles': roles,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }
}

/// Basic profile model for seller profile endpoints (BasicProfileResponse schema)
/// Contains seller basics plus optional registration document URL.
class BasicProfile {
  final String? name;
  final String phone;
  final DateTime? birthdate;
  final String? restaurantRegistrationLicenseDocument;
  // Keep age for backward compatibility in UI code that still expects it.
  final int? age;

  BasicProfile({
    this.name,
    required this.phone,
    this.birthdate,
    this.restaurantRegistrationLicenseDocument,
    this.age,
  });

  factory BasicProfile.fromJson(Map<String, dynamic> json) {
    final parsedBirthdate = json['birthdate'] != null
        ? DateTime.tryParse(json['birthdate'].toString())
        : null;

    return BasicProfile(
      name: json['name'] as String?,
      phone: json['phone']?.toString() ?? '',
      birthdate: parsedBirthdate,
      restaurantRegistrationLicenseDocument:
          json['restaurant_registration_license_document'] as String?,
      age:
          (json['age'] as num?)?.toInt() ??
          _calculateAgeFromBirthdate(parsedBirthdate),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      'phone': phone,
      if (birthdate != null) 'birthdate': _formatDate(birthdate!),
      if (restaurantRegistrationLicenseDocument != null)
        'restaurant_registration_license_document':
            restaurantRegistrationLicenseDocument,
    };
  }
}

/// User API service
class UserApi {
  final Dio _dio;

  UserApi(this._dio);

  /// Get authenticated user's profile
  /// GET /api/me/
  Future<UserProfile> getProfile() async {
    final response = await _dio.get('/api/me/');
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update user profile
  /// PATCH /api/me/
  Future<UserProfile> updateProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/me/', data: data);
    return UserProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Get seller profile
  /// GET /api/seller/profile/
  Future<BasicProfile> getSellerProfile() async {
    final response = await _dio.get('/api/seller/profile/');
    return BasicProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create seller profile
  /// POST /api/seller/profile/
  Future<BasicProfile> createSellerProfile(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/seller/profile/', data: data);
    return BasicProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Update seller profile
  /// PATCH /api/seller/profile/
  Future<BasicProfile> updateSellerProfile(Map<String, dynamic> data) async {
    final response = await _dio.patch('/api/seller/profile/', data: data);
    return BasicProfile.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete seller profile
  /// DELETE /api/seller/profile/
  Future<void> deleteSellerProfile() async {
    await _dio.delete('/api/seller/profile/');
  }

  /// Delete authenticated user's account and all related data
  /// DELETE /api/me/
  Future<void> deleteAccount() async {
    await _dio.delete('/api/me/');
  }

  /// List saved addresses for the authenticated user
  /// GET /api/addresses/
  Future<List<Map<String, dynamic>>> listAddresses() async {
    final response = await _dio.get('/api/addresses/');
    final data = response.data;
    if (data is Map<String, dynamic> && data['results'] is List) {
      return List<Map<String, dynamic>>.from(data['results'] as List);
    }
    if (data is List) {
      return List<Map<String, dynamic>>.from(data);
    }
    return [];
  }

  /// Create an address
  /// POST /api/addresses/
  Future<Map<String, dynamic>> createAddress(Map<String, dynamic> data) async {
    final response = await _dio.post('/api/addresses/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Update an address (partial)
  /// PATCH /api/addresses/{id}/
  Future<Map<String, dynamic>> updateAddress(
    int id,
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.patch('/api/addresses/$id/', data: data);
    return response.data as Map<String, dynamic>;
  }

  /// Submit full onboarding (profile + address + restaurant) in one call
  /// POST /api/seller/onboarding/
  Future<Map<String, dynamic>> submitOnboarding(
    Map<String, dynamic> data,
  ) async {
    final response = await _dio.post('/api/seller/onboarding/', data: data);
    return response.data as Map<String, dynamic>;
  }
}
