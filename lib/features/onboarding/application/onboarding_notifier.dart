/// Onboarding state management
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/providers/providers.dart';
import '../../../core/network/user_api.dart';
import '../../../core/network/restaurant_api.dart';

/// Onboarding state
sealed class OnboardingState {
  const OnboardingState();
}

class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

class OnboardingLoading extends OnboardingState {
  const OnboardingLoading({this.step = ''});
  final String step;
}

class OnboardingSuccess extends OnboardingState {
  const OnboardingSuccess();
}

class OnboardingError extends OnboardingState {
  const OnboardingError({required this.message});
  final String message;
}

/// Onboarding notifier handles the full onboarding flow:
/// 1. Create seller profile
/// 2. Create address
/// 3. Create restaurant
class OnboardingNotifier extends Notifier<OnboardingState> {
  late final UserApi _userApi;
  late final RestaurantApi _restaurantApi;

  @override
  OnboardingState build() {
    _userApi = ref.watch(userApiProvider);
    _restaurantApi = ref.watch(restaurantApiProvider);
    return const OnboardingInitial();
  }

  /// Submit the full onboarding flow
  Future<void> submitOnboarding({
    // Profile fields
    required String name,
    required String phone,
    int? age,
    // Restaurant fields
    required String restaurantName,
    required String restaurantPhone,
    // Address fields
    required String streetName,
    required String houseNumber,
    required String city,
    required String postalCode,
    required String country,
    String? fullAddress,
    double? lat,
    double? lng,
  }) async {
    try {
      // Step 1: Create seller profile
      state = const OnboardingLoading(step: 'profile');
      await _userApi.createSellerProfile({
        'name': name,
        'phone': phone,
        if (age != null) 'age': age,
      });

      // Step 2: Create address
      state = const OnboardingLoading(step: 'address');
      final addressData = await _userApi.createAddress({
        'label': restaurantName,
        'is_default': true,
        'street_name': streetName,
        'house_number': houseNumber,
        'city': city,
        if (postalCode.isNotEmpty) 'postal_code': postalCode,
        'country': country,
        if (fullAddress != null) 'full_address': fullAddress,
        if (lat != null) 'lat': double.parse(lat.toStringAsFixed(6)),
        if (lng != null) 'lng': double.parse(lng.toStringAsFixed(6)),
      });

      final addressId = addressData['id'];
      if (addressId == null) {
        state = const OnboardingError(
          message: 'Failed to create address. Please try again.',
        );
        return;
      }

      // Step 3: Create restaurant
      state = const OnboardingLoading(step: 'restaurant');
      await _restaurantApi.createRestaurant({
        'name': restaurantName,
        'phone': restaurantPhone,
        'address_id': addressId,
      });

      state = const OnboardingSuccess();
    } on DioException catch (e) {
      // The error interceptor wraps the error as an ApiException with extracted message
      final apiError = e.error;
      if (apiError is ApiException) {
        state = OnboardingError(message: apiError.message);
      } else {
        state = OnboardingError(
          message: e.message ?? 'Something went wrong. Please try again.',
        );
      }
    } catch (e) {
      state = OnboardingError(message: e.toString());
    }
  }

  /// Reset state to initial
  void reset() {
    state = const OnboardingInitial();
  }
}

/// Provider for onboarding state
final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
