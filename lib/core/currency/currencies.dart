/// Supported currencies configuration
library;

/// Currency model containing all currency properties
class Currency {
  const Currency({
    required this.code,
    required this.symbol,
    required this.name,
    required this.nameAr,
    this.symbolPosition = SymbolPosition.before,
    this.decimalDigits = 2,
    this.decimalSeparator = '.',
    this.thousandSeparator = ',',
  });

  /// ISO 4217 currency code (e.g., USD, EUR)
  final String code;

  /// Currency symbol (e.g., $, €, ر.س)
  final String symbol;

  /// English name
  final String name;

  /// Arabic name
  final String nameAr;

  /// Position of symbol relative to amount
  final SymbolPosition symbolPosition;

  /// Number of decimal places
  final int decimalDigits;

  /// Decimal separator character
  final String decimalSeparator;

  /// Thousand separator character
  final String thousandSeparator;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Currency && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;
}

/// Position of currency symbol
enum SymbolPosition { before, after }

/// All supported currencies
class Currencies {
  Currencies._();

  static const Currency usd = Currency(
    code: 'USD',
    symbol: '\$',
    name: 'US Dollar',
    nameAr: 'دولار أمريكي',
    symbolPosition: SymbolPosition.before,
  );

  static const Currency eur = Currency(
    code: 'EUR',
    symbol: '€',
    name: 'Euro',
    nameAr: 'يورو',
    symbolPosition: SymbolPosition.before,
  );

  static const Currency gbp = Currency(
    code: 'GBP',
    symbol: '£',
    name: 'British Pound',
    nameAr: 'جنيه إسترليني',
    symbolPosition: SymbolPosition.before,
  );

  static const Currency sar = Currency(
    code: 'SAR',
    symbol: 'ر.س',
    name: 'Saudi Riyal',
    nameAr: 'ريال سعودي',
    symbolPosition: SymbolPosition.after,
  );

  static const Currency aed = Currency(
    code: 'AED',
    symbol: 'د.إ',
    name: 'UAE Dirham',
    nameAr: 'درهم إماراتي',
    symbolPosition: SymbolPosition.after,
  );

  static const Currency egp = Currency(
    code: 'EGP',
    symbol: 'ج.م',
    name: 'Egyptian Pound',
    nameAr: 'جنيه مصري',
    symbolPosition: SymbolPosition.after,
  );

  static const Currency kwd = Currency(
    code: 'KWD',
    symbol: 'د.ك',
    name: 'Kuwaiti Dinar',
    nameAr: 'دينار كويتي',
    symbolPosition: SymbolPosition.after,
    decimalDigits: 3,
  );

  static const Currency qar = Currency(
    code: 'QAR',
    symbol: 'ر.ق',
    name: 'Qatari Riyal',
    nameAr: 'ريال قطري',
    symbolPosition: SymbolPosition.after,
  );

  static const Currency bhd = Currency(
    code: 'BHD',
    symbol: 'د.ب',
    name: 'Bahraini Dinar',
    nameAr: 'دينار بحريني',
    symbolPosition: SymbolPosition.after,
    decimalDigits: 3,
  );

  static const Currency omr = Currency(
    code: 'OMR',
    symbol: 'ر.ع',
    name: 'Omani Rial',
    nameAr: 'ريال عماني',
    symbolPosition: SymbolPosition.after,
    decimalDigits: 3,
  );

  static const Currency jod = Currency(
    code: 'JOD',
    symbol: 'د.أ',
    name: 'Jordanian Dinar',
    nameAr: 'دينار أردني',
    symbolPosition: SymbolPosition.after,
    decimalDigits: 3,
  );

  static const Currency lbp = Currency(
    code: 'LBP',
    symbol: 'ل.ل',
    name: 'Lebanese Pound',
    nameAr: 'ليرة لبنانية',
    symbolPosition: SymbolPosition.after,
    decimalDigits: 0,
  );

  static const Currency iqd = Currency(
    code: 'IQD',
    symbol: 'د.ع',
    name: 'Iraqi Dinar',
    nameAr: 'دينار عراقي',
    symbolPosition: SymbolPosition.after,
    decimalDigits: 0,
  );

  static const Currency jpy = Currency(
    code: 'JPY',
    symbol: '¥',
    name: 'Japanese Yen',
    nameAr: 'ين ياباني',
    symbolPosition: SymbolPosition.before,
    decimalDigits: 0,
  );

  static const Currency cny = Currency(
    code: 'CNY',
    symbol: '¥',
    name: 'Chinese Yuan',
    nameAr: 'يوان صيني',
    symbolPosition: SymbolPosition.before,
  );

  static const Currency inr = Currency(
    code: 'INR',
    symbol: '₹',
    name: 'Indian Rupee',
    nameAr: 'روبية هندية',
    symbolPosition: SymbolPosition.before,
  );

  static const Currency try_ = Currency(
    code: 'TRY',
    symbol: '₺',
    name: 'Turkish Lira',
    nameAr: 'ليرة تركية',
    symbolPosition: SymbolPosition.before,
  );

  /// List of all available currencies
  static const List<Currency> all = [
    usd,
    eur,
    gbp,
    sar,
    aed,
    egp,
    kwd,
    qar,
    bhd,
    omr,
    jod,
    lbp,
    iqd,
    jpy,
    cny,
    inr,
    try_,
  ];

  /// Default currency (Euro for European market)
  static const Currency defaultCurrency = eur;

  /// Get currency by code
  static Currency? getByCode(String code) {
    try {
      return all.firstWhere((c) => c.code == code.toUpperCase());
    } catch (_) {
      return null;
    }
  }
}
