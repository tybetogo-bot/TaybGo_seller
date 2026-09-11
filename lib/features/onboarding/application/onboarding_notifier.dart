/// Onboarding state management
library;

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/exceptions.dart';
import '../../../core/i18n/i18n.dart';
import '../../../core/providers/providers.dart';
import '../../../core/network/user_api.dart';

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

/// Onboarding notifier handles the full onboarding flow
/// using the single POST /api/seller/onboarding/ endpoint.
class OnboardingNotifier extends Notifier<OnboardingState> {
  late final UserApi _userApi;

  @override
  OnboardingState build() {
    _userApi = ref.watch(userApiProvider);
    return const OnboardingInitial();
  }

  /// Submit the full onboarding flow in a single API call
  Future<void> submitOnboarding({
    // Profile fields
    required String name,
    required String email,
    required String phone,
    DateTime? birthdate,
    required String registrationDocumentUrl,
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
      if (registrationDocumentUrl.trim().isEmpty) {
        state = const OnboardingError(
          message: 'Registration document is required.',
        );
        return;
      }

      state = const OnboardingLoading();

      await _userApi.submitOnboarding({
        'seller_profile': {
          'name': name,
          'email': email,
          'phone': phone,
          if (birthdate != null) 'birthdate': _formatDate(birthdate),
          'restaurant_registration_license_document': registrationDocumentUrl
              .trim(),
        },
        'address': {
          'label': restaurantName,
          'is_default': true,
          'street_name': streetName,
          'house_number': houseNumber,
          'city': city,
          if (postalCode.isNotEmpty) 'postal_code': postalCode,
          'country': country,
          if (fullAddress != null) 'full_address': fullAddress,
          if (lat != null) 'lat': lat.toStringAsFixed(6),
          if (lng != null) 'lng': lng.toStringAsFixed(6),
        },
        'restaurant': {'name': restaurantName, 'phone': restaurantPhone},
      });

      state = const OnboardingSuccess();
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        if (apiError.statusCode == 409) {
          state = OnboardingError(
            message: 'errors.auth.phoneAlreadyRegistered'.tr,
          );
        } else {
          state = OnboardingError(message: apiError.message);
        }
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

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}

/// Provider for onboarding state
final onboardingProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>(
      OnboardingNotifier.new,
    );
