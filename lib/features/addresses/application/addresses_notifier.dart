import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/addresses_api.dart';
import '../../../core/providers/providers.dart';
import '../data/datasources/addresses_remote_data_source.dart';
import '../data/models/address_model.dart';
import '../data/repositories/addresses_repository.dart';

/// Addresses state
class AddressesState {
  const AddressesState({
    this.addresses = const [],
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.selectedAddress,
  });

  final List<CustomerAddressModel> addresses;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePages;
  final CustomerAddressModel? selectedAddress;

  AddressesState copyWith({
    List<CustomerAddressModel>? addresses,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMorePages,
    CustomerAddressModel? selectedAddress,
    bool clearSelectedAddress = false,
  }) {
    return AddressesState(
      addresses: addresses ?? this.addresses,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      selectedAddress: clearSelectedAddress ? null : (selectedAddress ?? this.selectedAddress),
    );
  }
}

/// Addresses notifier for managing address state (Riverpod 3.x)
class AddressesNotifier extends Notifier<AddressesState> {
  late final AddressesRepository _repository;

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'AddressesNotifier',
        error: error,
        stackTrace: stackTrace,
      );
      // ignore: avoid_print
      print('[AddressesNotifier] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[AddressesNotifier] Error: $error');
      }
    }
  }

  @override
  AddressesState build() {
    _repository = ref.watch(addressesRepositoryProvider);

    // Load initial addresses
    Future.microtask(() => _loadAddresses());
    return const AddressesState(isLoading: true);
  }

  /// Load addresses from API
  Future<void> _loadAddresses({int page = 1}) async {
    _log('Loading addresses, page: $page');
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final result = await _repository.getAddresses(page: page);

      if (result.failure != null) {
        _log('Failed to load addresses: ${result.failure!.message}');
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      _log('Loaded ${result.data?.length ?? 0} addresses');
      state = state.copyWith(
        addresses: result.data ?? [],
        isLoading: false,
        currentPage: page,
      );
    } catch (e, stackTrace) {
      _log('Exception loading addresses', error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load addresses: $e',
      );
    }
  }

  /// Refresh addresses
  Future<void> refreshAddresses() async {
    await _loadAddresses(page: 1);
  }

  /// Create a new address
  Future<CustomerAddressModel?> createAddress(AddressCreateRequest request) async {
    _log('=== CREATE ADDRESS START ===');
    _log('Request: ${request.toJson()}');
    state = state.copyWith(clearError: true);

    try {
      _log('Calling repository.createAddress...');
      final result = await _repository.createAddress(request);

      if (result.failure != null) {
        _log('=== CREATE ADDRESS FAILED ===');
        _log('Failure message: ${result.failure!.message}');
        state = state.copyWith(error: result.failure!.message);
        return null;
      }

      _log('=== CREATE ADDRESS SUCCESS ===');
      _log('Created address ID: ${result.data?.id}');

      // Add to local state
      final updatedAddresses = [...state.addresses, result.data!];
      state = state.copyWith(addresses: updatedAddresses);

      return result.data;
    } catch (e, stackTrace) {
      _log('=== CREATE ADDRESS EXCEPTION ===', error: e, stackTrace: stackTrace);
      state = state.copyWith(error: 'Failed to create address: $e');
      return null;
    }
  }

  /// Update an existing address
  Future<CustomerAddressModel?> updateAddress(int id, AddressCreateRequest request) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.updateAddress(id, request);

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return null;
      }

      // Update local state
      final index = state.addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        final updatedAddresses = List<CustomerAddressModel>.from(state.addresses);
        updatedAddresses[index] = result.data!;
        state = state.copyWith(addresses: updatedAddresses);
      }

      return result.data;
    } catch (e) {
      state = state.copyWith(error: 'Failed to update address: $e');
      return null;
    }
  }

  /// Delete an address
  Future<bool> deleteAddress(int id) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.deleteAddress(id);

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return false;
      }

      // Remove from local state
      final updatedAddresses = state.addresses.where((a) => a.id != id).toList();
      state = state.copyWith(
        addresses: updatedAddresses,
        clearSelectedAddress: state.selectedAddress?.id == id,
      );

      return true;
    } catch (e) {
      state = state.copyWith(error: 'Failed to delete address: $e');
      return false;
    }
  }

  /// Select an address
  void selectAddress(CustomerAddressModel address) {
    state = state.copyWith(selectedAddress: address);
  }

  /// Clear selected address
  void clearSelectedAddress() {
    state = state.copyWith(clearSelectedAddress: true);
  }

  /// Get address by ID from local state
  CustomerAddressModel? getAddress(int id) {
    try {
      return state.addresses.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Fetch address by ID from API
  Future<CustomerAddressModel?> fetchAddressById(int id) async {
    state = state.copyWith(clearError: true);

    try {
      final result = await _repository.getAddressById(id);

      if (result.failure != null) {
        state = state.copyWith(error: result.failure!.message);
        return null;
      }

      // Update local state if address exists in list
      final index = state.addresses.indexWhere((a) => a.id == id);
      if (index != -1) {
        final updatedAddresses = List<CustomerAddressModel>.from(state.addresses);
        updatedAddresses[index] = result.data!;
        state = state.copyWith(addresses: updatedAddresses);
      }

      return result.data;
    } catch (e) {
      state = state.copyWith(error: 'Failed to fetch address: $e');
      return null;
    }
  }
}

/// Provider for addresses API
final addressesApiProvider = Provider<AddressesApi>((ref) {
  final dio = ref.watch(dioProvider);
  return AddressesApi(dio);
});

/// Provider for addresses data source
final addressesDataSourceProvider = Provider<AddressesDataSource>((ref) {
  final api = ref.watch(addressesApiProvider);
  return AddressesRemoteDataSource(api);
});

/// Provider for addresses repository
final addressesRepositoryProvider = Provider<AddressesRepository>((ref) {
  final dataSource = ref.watch(addressesDataSourceProvider);
  return AddressesRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for addresses state (Riverpod 3.x)
final addressesProvider = NotifierProvider<AddressesNotifier, AddressesState>(
  AddressesNotifier.new,
);

/// Provider for selected address
final selectedAddressProvider = Provider<CustomerAddressModel?>((ref) {
  return ref.watch(addressesProvider).selectedAddress;
});

/// Provider for a specific address by ID
final addressByIdProvider = Provider.family<CustomerAddressModel?, int>((ref, id) {
  final addressesState = ref.watch(addressesProvider);
  try {
    return addressesState.addresses.firstWhere((a) => a.id == id);
  } catch (_) {
    return null;
  }
});
