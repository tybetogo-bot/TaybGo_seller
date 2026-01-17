/// Addresses API service for address management
library;

import 'package:dio/dio.dart';

import '../../features/addresses/data/models/address_model.dart';
import 'restaurant_api.dart';

/// Addresses API service
class AddressesApi {
  final Dio _dio;

  AddressesApi(this._dio);

  /// List user addresses
  /// GET /api/addresses/
  Future<PaginatedResponse<CustomerAddressModel>> getAddresses({
    int page = 1,
  }) async {
    final response = await _dio.get(
      '/api/addresses/',
      queryParameters: {'page': page},
    );

    return PaginatedResponse.fromJson(
      response.data as Map<String, dynamic>,
      CustomerAddressModel.fromJson,
    );
  }

  /// Get address by ID
  /// GET /api/addresses/{id}/
  Future<CustomerAddressModel> getAddressById(int id) async {
    final response = await _dio.get('/api/addresses/$id/');
    return CustomerAddressModel.fromJson(response.data as Map<String, dynamic>);
  }

  /// Create a new address
  /// POST /api/addresses/
  Future<CustomerAddressModel> createAddress(AddressCreateRequest request) async {
    final response = await _dio.post(
      '/api/addresses/',
      data: request.toJson(),
    );
    return CustomerAddressModel.fromJson(response.data as Map<String, dynamic>);
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
