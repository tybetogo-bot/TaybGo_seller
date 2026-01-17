import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/constants.dart';
import '../providers/providers.dart' show sharedPreferencesProvider;
import 'currencies.dart';
import 'currency_formatter.dart';

/// Currency state containing current currency and exchange rates
class CurrencyState {
  const CurrencyState({
    required this.currency,
    this.exchangeRates = const {},
    this.baseCurrency = 'USD',
  });

  final Currency currency;
  final Map<String, double> exchangeRates;
  final String baseCurrency;

  CurrencyState copyWith({
    Currency? currency,
    Map<String, double>? exchangeRates,
    String? baseCurrency,
  }) {
    return CurrencyState(
      currency: currency ?? this.currency,
      exchangeRates: exchangeRates ?? this.exchangeRates,
      baseCurrency: baseCurrency ?? this.baseCurrency,
    );
  }
}

/// Currency state notifier (Riverpod 3.x)
class CurrencyNotifier extends Notifier<CurrencyState> {
  late SharedPreferences _prefs;

  @override
  CurrencyState build() {
    _prefs = ref.watch(sharedPreferencesProvider);
    return _loadInitialState(_prefs);
  }

  static CurrencyState _loadInitialState(SharedPreferences prefs) {
    final savedCode = prefs.getString(StorageKeys.currency);
    final currency = savedCode != null
        ? (Currencies.getByCode(savedCode) ?? Currencies.defaultCurrency)
        : Currencies.defaultCurrency;

    return CurrencyState(
      currency: currency,
      // Default exchange rates (should be fetched from API in production)
      exchangeRates: _defaultExchangeRates,
    );
  }

  /// Default exchange rates (USD as base)
  static const Map<String, double> _defaultExchangeRates = {
    'USD': 1.0,
    'EUR': 0.92,
    'GBP': 0.79,
    'SAR': 3.75,
    'AED': 3.67,
    'EGP': 30.90,
    'KWD': 0.31,
    'QAR': 3.64,
    'BHD': 0.38,
    'OMR': 0.38,
    'JOD': 0.71,
    'LBP': 89500.0,
    'IQD': 1310.0,
    'JPY': 149.50,
    'CNY': 7.24,
    'INR': 83.12,
    'TRY': 32.05,
  };

  /// Set currency
  Future<void> setCurrency(Currency currency) async {
    state = state.copyWith(currency: currency);
    await _prefs.setString(StorageKeys.currency, currency.code);
  }

  /// Set currency by code
  Future<void> setCurrencyByCode(String code) async {
    final currency = Currencies.getByCode(code);
    if (currency != null) {
      await setCurrency(currency);
    }
  }

  /// Update exchange rates
  void updateExchangeRates(Map<String, double> rates) {
    state = state.copyWith(exchangeRates: rates);
  }

  /// Convert amount from one currency to another
  double convert(double amount, String fromCode, String toCode) {
    if (fromCode == toCode) return amount;

    final fromRate = state.exchangeRates[fromCode] ?? 1.0;
    final toRate = state.exchangeRates[toCode] ?? 1.0;

    // Convert to base currency (USD) then to target
    final inBase = amount / fromRate;
    return inBase * toRate;
  }

  /// Convert amount to current currency
  double convertToCurrent(double amount, String fromCode) {
    return convert(amount, fromCode, state.currency.code);
  }

  /// Format amount in current currency
  String format(num amount, {bool showSymbol = true, bool useCompact = false}) {
    return CurrencyFormatter.format(
      amount,
      currency: state.currency,
      showSymbol: showSymbol,
      useCompact: useCompact,
    );
  }

  /// Format amount with conversion
  String formatWithConversion(
    num amount,
    String fromCode, {
    bool showSymbol = true,
  }) {
    final converted = convertToCurrent(amount.toDouble(), fromCode);
    return format(converted, showSymbol: showSymbol);
  }
}

/// Provider for currency state (Riverpod 3.x)
final currencyProvider = NotifierProvider<CurrencyNotifier, CurrencyState>(
  CurrencyNotifier.new,
);

/// Provider for formatted price
final formattedPriceProvider = Provider.family<String, num>((ref, amount) {
  final currencyNotifier = ref.watch(currencyProvider.notifier);
  return currencyNotifier.format(amount);
});

/// Provider for current currency
final currentCurrencyProvider = Provider<Currency>((ref) {
  return ref.watch(currencyProvider).currency;
});

/// Provider for all available currencies
final availableCurrenciesProvider = Provider<List<Currency>>((ref) {
  return Currencies.all;
});
