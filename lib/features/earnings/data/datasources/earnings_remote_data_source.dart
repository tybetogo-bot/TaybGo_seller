/// Remote data source for earnings
library;

import '../../../../core/network/earnings_api.dart';
import '../models/earning_model.dart';

/// Abstract interface for earnings data source
abstract class EarningsDataSource {
  /// Get earnings with optional filters
  Future<EarningsResponse> getEarnings({
    int page = 1,
    int? pageSize,
    int? restaurantId,
    String? from,
    String? to,
    bool? isPaid,
    bool? couponApplied,
    String? paymentType,
    String? ordering,
  });
}

/// Remote data source implementation using EarningsApi
class EarningsRemoteDataSource implements EarningsDataSource {
  EarningsRemoteDataSource(this._api);

  final EarningsApi _api;

  @override
  Future<EarningsResponse> getEarnings({
    int page = 1,
    int? pageSize,
    int? restaurantId,
    String? from,
    String? to,
    bool? isPaid,
    bool? couponApplied,
    String? paymentType,
    String? ordering,
  }) async {
    return await _api.getEarnings(
      page: page,
      pageSize: pageSize,
      restaurantId: restaurantId,
      from: from,
      to: to,
      isPaid: isPaid,
      couponApplied: couponApplied,
      paymentType: paymentType,
      ordering: ordering,
    );
  }
}
