/// Country model for phone number country codes
class Country {
  const Country({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
    this.maxLength = 10,
    this.minLength = 6,
  });

  /// Country name in English
  final String name;

  /// ISO 3166-1 alpha-2 country code (e.g., AT, DE)
  final String code;

  /// International dialing code (e.g., +43, +49)
  final String dialCode;

  /// Country flag emoji
  final String flag;

  /// Maximum phone number length (excluding country code)
  final int maxLength;

  /// Minimum phone number length (excluding country code)
  final int minLength;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country && runtimeType == other.runtimeType && code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => '$flag $name ($dialCode)';
}

/// All supported countries with focus on European countries
class Countries {
  Countries._();

  // Default country (Austria)
  static const Country austria = Country(
    name: 'Austria',
    code: 'AT',
    dialCode: '+43',
    flag: '\u{1F1E6}\u{1F1F9}',
    maxLength: 13,
    minLength: 4,
  );

  static const Country germany = Country(
    name: 'Germany',
    code: 'DE',
    dialCode: '+49',
    flag: '\u{1F1E9}\u{1F1EA}',
    maxLength: 12,
    minLength: 5,
  );

  static const Country france = Country(
    name: 'France',
    code: 'FR',
    dialCode: '+33',
    flag: '\u{1F1EB}\u{1F1F7}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country switzerland = Country(
    name: 'Switzerland',
    code: 'CH',
    dialCode: '+41',
    flag: '\u{1F1E8}\u{1F1ED}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country italy = Country(
    name: 'Italy',
    code: 'IT',
    dialCode: '+39',
    flag: '\u{1F1EE}\u{1F1F9}',
    maxLength: 10,
    minLength: 9,
  );

  static const Country spain = Country(
    name: 'Spain',
    code: 'ES',
    dialCode: '+34',
    flag: '\u{1F1EA}\u{1F1F8}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country netherlands = Country(
    name: 'Netherlands',
    code: 'NL',
    dialCode: '+31',
    flag: '\u{1F1F3}\u{1F1F1}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country belgium = Country(
    name: 'Belgium',
    code: 'BE',
    dialCode: '+32',
    flag: '\u{1F1E7}\u{1F1EA}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country portugal = Country(
    name: 'Portugal',
    code: 'PT',
    dialCode: '+351',
    flag: '\u{1F1F5}\u{1F1F9}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country poland = Country(
    name: 'Poland',
    code: 'PL',
    dialCode: '+48',
    flag: '\u{1F1F5}\u{1F1F1}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country czechRepublic = Country(
    name: 'Czech Republic',
    code: 'CZ',
    dialCode: '+420',
    flag: '\u{1F1E8}\u{1F1FF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country hungary = Country(
    name: 'Hungary',
    code: 'HU',
    dialCode: '+36',
    flag: '\u{1F1ED}\u{1F1FA}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country slovakia = Country(
    name: 'Slovakia',
    code: 'SK',
    dialCode: '+421',
    flag: '\u{1F1F8}\u{1F1F0}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country slovenia = Country(
    name: 'Slovenia',
    code: 'SI',
    dialCode: '+386',
    flag: '\u{1F1F8}\u{1F1EE}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country croatia = Country(
    name: 'Croatia',
    code: 'HR',
    dialCode: '+385',
    flag: '\u{1F1ED}\u{1F1F7}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country unitedKingdom = Country(
    name: 'United Kingdom',
    code: 'GB',
    dialCode: '+44',
    flag: '\u{1F1EC}\u{1F1E7}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country ireland = Country(
    name: 'Ireland',
    code: 'IE',
    dialCode: '+353',
    flag: '\u{1F1EE}\u{1F1EA}',
    maxLength: 9,
    minLength: 7,
  );

  static const Country sweden = Country(
    name: 'Sweden',
    code: 'SE',
    dialCode: '+46',
    flag: '\u{1F1F8}\u{1F1EA}',
    maxLength: 9,
    minLength: 7,
  );

  static const Country norway = Country(
    name: 'Norway',
    code: 'NO',
    dialCode: '+47',
    flag: '\u{1F1F3}\u{1F1F4}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country denmark = Country(
    name: 'Denmark',
    code: 'DK',
    dialCode: '+45',
    flag: '\u{1F1E9}\u{1F1F0}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country finland = Country(
    name: 'Finland',
    code: 'FI',
    dialCode: '+358',
    flag: '\u{1F1EB}\u{1F1EE}',
    maxLength: 10,
    minLength: 6,
  );

  static const Country greece = Country(
    name: 'Greece',
    code: 'GR',
    dialCode: '+30',
    flag: '\u{1F1EC}\u{1F1F7}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country romania = Country(
    name: 'Romania',
    code: 'RO',
    dialCode: '+40',
    flag: '\u{1F1F7}\u{1F1F4}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country bulgaria = Country(
    name: 'Bulgaria',
    code: 'BG',
    dialCode: '+359',
    flag: '\u{1F1E7}\u{1F1EC}',
    maxLength: 9,
    minLength: 8,
  );

  /// List of all European countries sorted alphabetically
  static const List<Country> european = [
    austria,
    belgium,
    bulgaria,
    croatia,
    czechRepublic,
    denmark,
    finland,
    france,
    germany,
    greece,
    hungary,
    ireland,
    italy,
    netherlands,
    norway,
    poland,
    portugal,
    romania,
    slovakia,
    slovenia,
    spain,
    sweden,
    switzerland,
    unitedKingdom,
  ];

  /// All countries (currently only European)
  static const List<Country> all = european;

  /// Default country (Austria as specified)
  static const Country defaultCountry = austria;

  /// Get country by ISO code
  static Country? getByCode(String code) {
    try {
      return all.firstWhere(
        (c) => c.code.toUpperCase() == code.toUpperCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Get country by dial code
  static Country? getByDialCode(String dialCode) {
    final normalized = dialCode.startsWith('+') ? dialCode : '+$dialCode';
    try {
      return all.firstWhere((c) => c.dialCode == normalized);
    } catch (_) {
      return null;
    }
  }

  /// Search countries by name or code
  static List<Country> search(String query) {
    final q = query.toLowerCase().trim();
    if (q.isEmpty) return all;

    return all.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q) ||
          c.dialCode.contains(q);
    }).toList();
  }
}
