/// Addresses API service for address management
library;

import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../../features/addresses/data/models/address_model.dart';
import 'restaurant_api.dart';

/// Addresses API service
class AddressesApi {
  final Dio _dio;

  AddressesApi(this._dio);

  void _log(String message, {Object? error, StackTrace? stackTrace}) {
    if (kDebugMode) {
      developer.log(
        message,
        name: 'AddressesApi',
        error: error,
        stackTrace: stackTrace,
      );
      // ignore: avoid_print
      print('[AddressesApi] $message');
      if (error != null) {
        // ignore: avoid_print
        print('[AddressesApi] Error: $error');
      }
    }
  }

  /// List user addresses
  /// GET /api/addresses/
  Future<PaginatedResponse<CustomerAddressModel>> getAddresses({
    int page = 1,
  }) async {
    _log('Getting addresses, page: $page');
    try {
      final response = await _dio.get(
        '/api/addresses/',
        queryParameters: {'page': page},
      );
      _log('Get addresses response: ${response.statusCode}');
      return PaginatedResponse.fromJson(
        response.data as Map<String, dynamic>,
        CustomerAddressModel.fromJson,
      );
    } on DioException catch (e) {
      _log('DioException getting addresses', error: e);
      _log('Status code: ${e.response?.statusCode}');
      _log('Response data: ${e.response?.data}');
      rethrow;
    }
  }

  /// Get address by ID
  /// GET /api/addresses/{id}/
  Future<CustomerAddressModel> getAddressById(int id) async {
    _log('Getting address by ID: $id');
    final response = await _dio.get('/api/addresses/$id/');
    _log('Get address response: ${response.statusCode}');
    return CustomerAddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a new address
  /// POST /api/addresses/
  Future<CustomerAddressModel> createAddress(AddressCreateRequest request) async {
    final requestJson = request.toJson();
    _log('Creating address with data: $requestJson');

    try {
      final response = await _dio.post(
        '/api/addresses/',
        data: requestJson,
      );
      _log('Create address response status: ${response.statusCode}');
      _log('Create address response data: ${response.data}');

      final address = CustomerAddressModel.fromJson(response.data as Map<String, dynamic>);
      _log('Successfully created address with ID: ${address.id}');
      return address;
    } on DioException catch (e) {
      _log('DioException creating address', error: e);
      _log('Status code: ${e.response?.statusCode}');
      _log('Response data: ${e.response?.data}');
      _log('Request data sent: $requestJson');
      rethrow;
    } catch (e, stackTrace) {
      _log('Unexpected error creating address', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Update an address (full update)
  /// PUT /api/addresses/{id}/
  Future<CustomerAddressModel> updateAddress(int id, AddressCreateRequest request) async {
    final response = await _dio.put(
      '/api/addresses/$id/',
      data: request.toJson(),
    );
    return CustomerAddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Partial update an address
  /// PATCH /api/addresses/{id}/
  Future<CustomerAddressModel> patchAddress(int id, Map<String, dynamic> data) async {
    final response = await _dio.patch(
      '/api/addresses/$id/',
      data: data,
    );
    return CustomerAddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Delete an address
  /// DELETE /api/addresses/{id}/
  Future<void> deleteAddress(int id) async {
    await _dio.delete('/api/addresses/$id/');
  }
}
