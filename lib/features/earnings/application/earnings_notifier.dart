/// Earnings state management
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../data/datasources/earnings_remote_data_source.dart';
import '../data/models/earning_model.dart';
import '../data/repositories/earnings_repository.dart';

/// Date range filter presets
enum EarningsDateFilter {
  today,
  thisWeek,
  thisMonth,
  custom,
}

/// Earnings state
class EarningsState {
  const EarningsState({
    this.earnings = const [],
    this.summary = const EarningsSummary(
      totalOrders: 0,
      totalEarnings: 0,
      grossSubtotal: 0,
      totalDiscounts: 0,
    ),
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.hasMorePages = true,
    this.dateFilter = EarningsDateFilter.thisMonth,
    this.customFrom,
    this.customTo,
    this.isPaidFilter,
    this.paymentTypeFilter,
  });

  final List<EarningItem> earnings;
  final EarningsSummary summary;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final bool hasMorePages;
  final EarningsDateFilter dateFilter;
  final DateTime? customFrom;
  final DateTime? customTo;
  final bool? isPaidFilter;
  final String? paymentTypeFilter;

  EarningsState copyWith({
    List<EarningItem>? earnings,
    EarningsSummary? summary,
    bool? isLoading,
    String? error,
    bool clearError = false,
    int? currentPage,
    bool? hasMorePages,
    EarningsDateFilter? dateFilter,
    DateTime? customFrom,
    DateTime? customTo,
    bool clearCustomDates = false,
    bool? isPaidFilter,
    bool clearIsPaidFilter = false,
    String? paymentTypeFilter,
    bool clearPaymentTypeFilter = false,
  }) {
    return EarningsState(
      earnings: earnings ?? this.earnings,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMorePages: hasMorePages ?? this.hasMorePages,
      dateFilter: dateFilter ?? this.dateFilter,
      customFrom: clearCustomDates ? null : (customFrom ?? this.customFrom),
      customTo: clearCustomDates ? null : (customTo ?? this.customTo),
      isPaidFilter:
          clearIsPaidFilter ? null : (isPaidFilter ?? this.isPaidFilter),
      paymentTypeFilter: clearPaymentTypeFilter
          ? null
          : (paymentTypeFilter ?? this.paymentTypeFilter),
    );
  }
}

/// Earnings notifier for managing earnings state
class EarningsNotifier extends Notifier<EarningsState> {
  late final EarningsRepository _repository;

  @override
  EarningsState build() {
    _repository = ref.watch(earningsRepositoryProvider);

    // Load initial earnings
    Future.microtask(() => _loadEarnings());
    return const EarningsState(isLoading: true);
  }

  /// Compute date range from filter
  ({String? from, String? to}) _getDateRange() {
    final now = DateTime.now();
    switch (state.dateFilter) {
      case EarningsDateFilter.today:
        final today = DateTime(now.year, now.month, now.day);
        return (
          from: today.toIso8601String(),
          to: now.toIso8601String(),
        );
      case EarningsDateFilter.thisWeek:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
        return (
          from: start.toIso8601String(),
          to: now.toIso8601String(),
        );
      case EarningsDateFilter.thisMonth:
        final monthStart = DateTime(now.year, now.month, 1);
        return (
          from: monthStart.toIso8601String(),
          to: now.toIso8601String(),
        );
      case EarningsDateFilter.custom:
        return (
          from: state.customFrom?.toIso8601String(),
          to: state.customTo?.toIso8601String(),
        );
    }
  }

  /// Load earnings from API
  Future<void> _loadEarnings({int page = 1}) async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final dateRange = _getDateRange();
      final result = await _repository.getEarnings(
        page: page,
        from: dateRange.from,
        to: dateRange.to,
        isPaid: state.isPaidFilter,
        paymentType: state.paymentTypeFilter,
        ordering: '-earned_at',
      );

      if (result.failure != null) {
        state = state.copyWith(
          isLoading: false,
          error: result.failure!.message,
        );
        return;
      }

      final response = result.data!;
      final newEarnings = page == 1
          ? response.results
          : [...state.earnings, ...response.results];

      state = state.copyWith(
        earnings: newEarnings,
        summary: response.summary,
        isLoading: false,
        currentPage: page,
        hasMorePages: response.hasMore,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load earnings: $e',
      );
    }
  }

  /// Refresh earnings (reloads from page 1)
  Future<void> refreshEarnings() async {
    await _loadEarnings(page: 1);
  }

  /// Load next page
  Future<void> loadMore() async {
    if (state.isLoading || !state.hasMorePages) return;
    await _loadEarnings(page: state.currentPage + 1);
  }

  /// Set date filter and reload
  void setDateFilter(EarningsDateFilter filter) {
    state = state.copyWith(dateFilter: filter);
    _loadEarnings();
  }

  /// Set custom date range and reload
  void setCustomDateRange(DateTime from, DateTime to) {
    state = state.copyWith(
      dateFilter: EarningsDateFilter.custom,
      customFrom: from,
      customTo: to,
    );
    _loadEarnings();
  }

  /// Set payment status filter and reload
  void setIsPaidFilter(bool? isPaid) {
    if (isPaid == null) {
      state = state.copyWith(clearIsPaidFilter: true);
    } else {
      state = state.copyWith(isPaidFilter: isPaid);
    }
    _loadEarnings();
  }

  /// Set payment type filter and reload
  void setPaymentTypeFilter(String? paymentType) {
    if (paymentType == null) {
      state = state.copyWith(clearPaymentTypeFilter: true);
    } else {
      state = state.copyWith(paymentTypeFilter: paymentType);
    }
    _loadEarnings();
  }
}

/// Provider for earnings data source
final earningsDataSourceProvider = Provider<EarningsDataSource>((ref) {
  final api = ref.watch(earningsApiProvider);
  return EarningsRemoteDataSource(api);
});

/// Provider for earnings repository
final earningsRepositoryProvider = Provider<EarningsRepository>((ref) {
  final dataSource = ref.watch(earningsDataSourceProvider);
  return EarningsRepositoryImpl(remoteDataSource: dataSource);
});

/// Provider for earnings state
final earningsProvider = NotifierProvider<EarningsNotifier, EarningsState>(
  EarningsNotifier.new,
);
