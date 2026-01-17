import 'package:intl/intl.dart';

import 'currencies.dart';

/// Utility class for formatting currency values
class CurrencyFormatter {
  CurrencyFormatter._();

  /// Format a number as currency
  static String format(
    num amount, {
    required Currency currency,
    bool showSymbol = true,
    bool useCompact = false,
  }) {
    final formatter = NumberFormat.currency(
      symbol: showSymbol ? '' : '',
      decimalDigits: currency.decimalDigits,
      locale: 'en_US',
    );

    String formatted;
    if (useCompact && amount.abs() >= 1000) {
      formatted = _formatCompact(amount, currency);
    } else {
      formatted = formatter.format(amount);
      // Apply custom separators
      formatted = formatted
          .replaceAll(',', '#THOUSAND#')
          .replaceAll('.', '#DECIMAL#')
          .replaceAll('#THOUSAND#', currency.thousandSeparator)
          .replaceAll('#DECIMAL#', currency.decimalSeparator);
    }

    if (!showSymbol) return formatted;

    // Apply symbol position
    if (currency.symbolPosition == SymbolPosition.before) {
      return '${currency.symbol}$formatted';
    } else {
      return '$formatted ${currency.symbol}';
    }
  }

  /// Format with compact notation (1K, 1M, etc.)
  static String _formatCompact(num amount, Currency currency) {
    if (amount.abs() >= 1000000000) {
      return '${(amount / 1000000000).toStringAsFixed(1)}B';
    } else if (amount.abs() >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount.abs() >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(currency.decimalDigits);
  }

  /// Format price with optional original price (for discounts)
  static String formatWithDiscount({
    required num currentPrice,
    num? originalPrice,
    required Currency currency,
  }) {
    final current = format(currentPrice, currency: currency);
    if (originalPrice != null && originalPrice > currentPrice) {
      final original = format(originalPrice, currency: currency);
      return '$current (was $original)';
    }
    return current;
  }

  /// Calculate discount percentage
  static int calculateDiscountPercent(num originalPrice, num currentPrice) {
    if (originalPrice <= 0) return 0;
    final discount = ((originalPrice - currentPrice) / originalPrice) * 100;
    return discount.round();
  }

  /// Format as free if zero
  static String formatOrFree(
    num amount, {
    required Currency currency,
    String freeText = 'Free',
  }) {
    if (amount <= 0) return freeText;
    return format(amount, currency: currency);
  }

  /// Parse currency string to number
  static num? parse(String value, {required Currency currency}) {
    try {
      // Remove currency symbol and spaces
      String cleaned = value
          .replaceAll(currency.symbol, '')
          .replaceAll(' ', '')
          .replaceAll(currency.thousandSeparator, '')
          .replaceAll(currency.decimalSeparator, '.');
      return num.parse(cleaned);
    } catch (_) {
      return null;
    }
  }

  /// Format price range
  static String formatRange(
    num minPrice,
    num maxPrice, {
    required Currency currency,
  }) {
    if (minPrice == maxPrice) {
      return format(minPrice, currency: currency);
    }
    final min = format(minPrice, currency: currency, showSymbol: false);
    final max = format(maxPrice, currency: currency);

    if (currency.symbolPosition == SymbolPosition.before) {
      return '${currency.symbol}$min - $max';
    } else {
      return '$min - $max';
    }
  }
}
