/// Addresses repository interface and implementation
library;

import 'package:dio/dio.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../datasources/addresses_remote_data_source.dart';
import '../models/address_model.dart';

/// Result type for repository methods
typedef AddressesResult<T> = ({Failure? failure, T? data});

/// Addresses repository interface
abstract class AddressesRepository {
  /// Get addresses list with pagination
  Future<AddressesResult<List<CustomerAddressModel>>> getAddresses({int page = 1});

  /// Get single address by ID
  Future<AddressesResult<CustomerAddressModel>> getAddressById(int id);

  /// Create a new address
  Future<AddressesResult<CustomerAddressModel>> createAddress(AddressCreateRequest request);

  /// Update an existing address
  Future<AddressesResult<CustomerAddressModel>> updateAddress(int id, AddressCreateRequest request);

  /// Partial update an address
  Future<AddressesResult<CustomerAddressModel>> patchAddress(int id, Map<String, dynamic> data);

  /// Delete an address
  Future<AddressesResult<void>> deleteAddress(int id);
}

/// Implementation of addresses repository
class AddressesRepositoryImpl implements AddressesRepository {
  AddressesRepositoryImpl({
    required AddressesDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  final AddressesDataSource _remoteDataSource;

  @override
  Future<AddressesResult<List<CustomerAddressModel>>> getAddresses({int page = 1}) async {
    try {
      final addresses = await _remoteDataSource.getAddresses(page: page);
      return (failure: null, data: addresses);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } on NetworkException catch (e) {
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<AddressesResult<CustomerAddressModel>> getAddressById(int id) async {
    try {
      final address = await _remoteDataSource.getAddressById(id);
      return (failure: null, data: address);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<AddressesResult<CustomerAddressModel>> createAddress(AddressCreateRequest request) async {
    try {
      final address = await _remoteDataSource.createAddress(request);
      return (failure: null, data: address);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<AddressesResult<CustomerAddressModel>> updateAddress(int id, AddressCreateRequest request) async {
    try {
      final address = await _remoteDataSource.updateAddress(id, request);
      return (failure: null, data: address);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<AddressesResult<CustomerAddressModel>> patchAddress(int id, Map<String, dynamic> data) async {
    try {
      final address = await _remoteDataSource.patchAddress(id, data);
      return (failure: null, data: address);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }

  @override
  Future<AddressesResult<void>> deleteAddress(int id) async {
    try {
      await _remoteDataSource.deleteAddress(id);
      return (failure: null, data: null);
    } on DioException catch (e) {
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: const NetworkFailure(message: 'Network error occurred'),
        data: null,
      );
    } catch (e) {
      return (
        failure: const ServerFailure(message: 'An unexpected error occurred'),
        data: null,
      );
    }
  }
}
