/// Addresses repository interface and implementation
library;

import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

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

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'AddressesRepository',
        error: error,
        stackTrace: stackTrace,
      );
      // ignore: avoid_print
      print('[AddressesRepository] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[AddressesRepository] Error: $error');
      }
    }
  }

  String _extractErrorMessage(DioException e) {
    final response = e.response;
    if (response != null) {
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final errorMsg = data['detail'] ??
            data['message'] ??
            data['error'] ??
            data['non_field_errors']?.toString() ??
            data.toString();
        return errorMsg.toString();
      }
      return data?.toString() ?? e.message ?? 'Unknown error';
    }
    return e.message ?? 'Network error occurred';
  }

  @override
  Future<AddressesResult<List<CustomerAddressModel>>> getAddresses({int page = 1}) async {
    _log('Getting addresses, page: $page');
    try {
      final addresses = await _remoteDataSource.getAddresses(page: page);
      _log('Got ${addresses.length} addresses');
      return (failure: null, data: addresses);
    } on DioException catch (e, stackTrace) {
      _log('DioException getting addresses', error: e, stackTrace: stackTrace);
      _log('Status: ${e.response?.statusCode}, Data: ${e.response?.data}');
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: ServerFailure(message: _extractErrorMessage(e)),
        data: null,
      );
    } on NetworkException catch (e) {
      _log('NetworkException getting addresses: ${e.message}');
      return (failure: NetworkFailure(message: e.message), data: null);
    } catch (e, stackTrace) {
      _log('Unexpected error getting addresses', error: e, stackTrace: stackTrace);
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  @override
  Future<AddressesResult<CustomerAddressModel>> getAddressById(int id) async {
    _log('Getting address by ID: $id');
    try {
      final address = await _remoteDataSource.getAddressById(id);
      _log('Got address: ${address.id}');
      return (failure: null, data: address);
    } on DioException catch (e, stackTrace) {
      _log('DioException getting address', error: e, stackTrace: stackTrace);
      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ServerFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: ServerFailure(message: _extractErrorMessage(e)),
        data: null,
      );
    } catch (e, stackTrace) {
      _log('Unexpected error getting address', error: e, stackTrace: stackTrace);
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
        data: null,
      );
    }
  }

  @override
  Future<AddressesResult<CustomerAddressModel>> createAddress(AddressCreateRequest request) async {
    _log('=== CREATE ADDRESS START ===');
    _log('Request data: ${request.toJson()}');
    try {
      final address = await _remoteDataSource.createAddress(request);
      _log('=== CREATE ADDRESS SUCCESS ===');
      _log('Created address ID: ${address.id}');
      return (failure: null, data: address);
    } on DioException catch (e, stackTrace) {
      _log('=== CREATE ADDRESS FAILED ===', error: e, stackTrace: stackTrace);
      _log('Status code: ${e.response?.statusCode}');
      _log('Response data: ${e.response?.data}');

      final errorMessage = _extractErrorMessage(e);
      _log('Extracted error: $errorMessage');

      final apiError = e.error;
      if (apiError is ApiException) {
        return (
          failure: ValidationFailure(message: apiError.message),
          data: null,
        );
      }
      return (
        failure: ServerFailure(message: errorMessage),
        data: null,
      );
    } catch (e, stackTrace) {
      _log('=== CREATE ADDRESS EXCEPTION ===', error: e, stackTrace: stackTrace);
      return (
        failure: ServerFailure(message: 'An unexpected error occurred: $e'),
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
