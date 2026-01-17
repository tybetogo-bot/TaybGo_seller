/// Remote data source for addresses
library;

import '../../../../core/network/addresses_api.dart';
import '../models/address_model.dart';

/// Abstract interface for addresses data source
abstract class AddressesDataSource {
  /// Get addresses list with pagination
  Future<List<CustomerAddressModel>> getAddresses({int page = 1});

  /// Get single address by ID
  Future<CustomerAddressModel> getAddressById(int id);

  /// Create a new address
  Future<CustomerAddressModel> createAddress(AddressCreateRequest request);

  /// Update an existing address
  Future<CustomerAddressModel> updateAddress(int id, AddressCreateRequest request);

  /// Partial update an address
  Future<CustomerAddressModel> patchAddress(int id, Map<String, dynamic> data);

  /// Delete an address
  Future<void> deleteAddress(int id);
}

/// Remote data source implementation using AddressesApi
class AddressesRemoteDataSource implements AddressesDataSource {
  AddressesRemoteDataSource(this._api);

  final AddressesApi _api;

  @override
  Future<List<CustomerAddressModel>> getAddresses({int page = 1}) async {
    final response = await _api.getAddresses(page: page);
    return response.results;
  }

  @override
  Future<CustomerAddressModel> getAddressById(int id) async {
    return await _api.getAddressById(id);
  }

  @override
  Future<CustomerAddressModel> createAddress(AddressCreateRequest request) async {
    return await _api.createAddress(request);
  }

  @override
  Future<CustomerAddressModel> updateAddress(int id, AddressCreateRequest request) async {
    return await _api.updateAddress(id, request);
  }

  @override
  Future<CustomerAddressModel> patchAddress(int id, Map<String, dynamic> data) async {
    return await _api.patchAddress(id, data);
  }

  @override
  Future<void> deleteAddress(int id) async {
    await _api.deleteAddress(id);
  }
}
