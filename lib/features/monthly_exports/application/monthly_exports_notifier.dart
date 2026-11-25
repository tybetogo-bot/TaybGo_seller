import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/constants.dart';
import '../../../core/providers/providers.dart';
import '../../../core/services/session_lifecycle.dart';
import '../../restaurant/application/restaurant_state.dart';
import '../data/monthly_export_model.dart';

class MonthlyExportsState {
  final List<SellerMonthlyExport> exports;
  final bool isLoading;
  final String? error;
  final int? selectedYear;
  final int? selectedMonth;
  final int? downloadingExportId;

  const MonthlyExportsState({
    this.exports = const [],
    this.isLoading = false,
    this.error,
    this.selectedYear,
    this.selectedMonth,
    this.downloadingExportId,
  });

  MonthlyExportsState copyWith({
    List<SellerMonthlyExport>? exports,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? selectedYear,
    bool clearYear = false,
    int? selectedMonth,
    bool clearMonth = false,
    int? downloadingExportId,
    bool clearDownloadingId = false,
  }) {
    return MonthlyExportsState(
      exports: exports ?? this.exports,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedYear: clearYear ? null : (selectedYear ?? this.selectedYear),
      selectedMonth: clearMonth ? null : (selectedMonth ?? this.selectedMonth),
      downloadingExportId: clearDownloadingId
          ? null
          : (downloadingExportId ?? this.downloadingExportId),
    );
  }
}

class MonthlyExportsNotifier extends Notifier<MonthlyExportsState> {
  late final Dio _dio;

  @override
  MonthlyExportsState build() {
    _dio = ref.watch(dioProvider);
    ref.watch(selectedRestaurantIdProvider);
    Future.microtask(() => loadExports());
    return const MonthlyExportsState();
  }

  Future<void> loadExports({
    int? year,
    int? month,
    bool clearYear = false,
    bool clearMonth = false,
  }) async {
    final generation = SessionLifecycle.instance.generation;
    final selectedRestaurantId = ref.read(selectedRestaurantIdProvider);
    if (!ref.mounted ||
        !SessionLifecycle.instance.isAuthenticated(generation)) {
      return;
    }

    final nextYear = clearYear ? null : (year ?? state.selectedYear);
    final nextMonth = clearMonth ? null : (month ?? state.selectedMonth);
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedYear: nextYear,
      clearYear: clearYear,
      selectedMonth: nextMonth,
      clearMonth: clearMonth,
    );

    try {
      final params = <String, dynamic>{
        if (selectedRestaurantId != null && selectedRestaurantId.isNotEmpty)
          'restaurant_id': selectedRestaurantId,
        if (nextYear != null) 'year': nextYear,
        if (nextMonth != null) 'month': nextMonth,
      };
      final response = await _dio.get(
        ApiEndpoints.sellerMonthlyExports,
        queryParameters: params,
      );
      if (!ref.mounted ||
          !SessionLifecycle.instance.isAuthenticated(generation) ||
          ref.read(selectedRestaurantIdProvider) != selectedRestaurantId) {
        return;
      }

      final data = response.data;
      final listRaw = data is Map<String, dynamic>
          ? (data['results'] as List?) ?? const []
          : (data is List ? data : const []);

      final parsed = listRaw
          .whereType<Map>()
          .map(
            (e) => SellerMonthlyExport.fromJson(Map<String, dynamic>.from(e)),
          )
          .toList(growable: false);

      state = state.copyWith(exports: parsed, isLoading: false);
    } catch (e) {
      if (!ref.mounted ||
          !SessionLifecycle.instance.isAuthenticated(generation) ||
          ref.read(selectedRestaurantIdProvider) != selectedRestaurantId) {
        return;
      }
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refetch statement detail to obtain a fresh short-lived signed download URL.
  Future<String?> fetchFreshDownloadUrl(SellerMonthlyExport export) async {
    final generation = SessionLifecycle.instance.generation;
    final selectedRestaurantId = ref.read(selectedRestaurantIdProvider);
    if (!ref.mounted ||
        !SessionLifecycle.instance.isAuthenticated(generation)) {
      return null;
    }

    state = state.copyWith(downloadingExportId: export.id, clearError: true);
    try {
      final response = await _dio.get(
        ApiEndpoints.sellerMonthlyExportDetail(export.id),
      );
      if (!ref.mounted ||
          !SessionLifecycle.instance.isAuthenticated(generation) ||
          ref.read(selectedRestaurantIdProvider) != selectedRestaurantId) {
        return null;
      }
      final detail = SellerMonthlyExport.fromJson(
        Map<String, dynamic>.from(response.data as Map),
      );
      state = state.copyWith(clearDownloadingId: true);
      return detail.downloadUrl ?? export.downloadUrl;
    } catch (e) {
      if (!ref.mounted ||
          !SessionLifecycle.instance.isAuthenticated(generation)) {
        return null;
      }
      state = state.copyWith(
        clearDownloadingId: true,
        error: e.toString(),
      );
      return null;
    }
  }
}

final monthlyExportsProvider =
    NotifierProvider<MonthlyExportsNotifier, MonthlyExportsState>(
      MonthlyExportsNotifier.new,
    );
