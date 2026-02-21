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

/// All supported countries worldwide
class Countries {
  Countries._();

  // ──────────────────────────────────────────────
  // DEFAULT COUNTRY
  // ──────────────────────────────────────────────

  static const Country austria = Country(
    name: 'Austria',
    code: 'AT',
    dialCode: '+43',
    flag: '\u{1F1E6}\u{1F1F9}',
    maxLength: 13,
    minLength: 4,
  );

  // ──────────────────────────────────────────────
  // EUROPEAN COUNTRIES
  // ──────────────────────────────────────────────

  static const Country albania = Country(
    name: 'Albania',
    code: 'AL',
    dialCode: '+355',
    flag: '\u{1F1E6}\u{1F1F1}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country andorra = Country(
    name: 'Andorra',
    code: 'AD',
    dialCode: '+376',
    flag: '\u{1F1E6}\u{1F1E9}',
    maxLength: 6,
    minLength: 6,
  );

  static const Country belarus = Country(
    name: 'Belarus',
    code: 'BY',
    dialCode: '+375',
    flag: '\u{1F1E7}\u{1F1FE}',
    maxLength: 10,
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

  static const Country bosniaAndHerzegovina = Country(
    name: 'Bosnia and Herzegovina',
    code: 'BA',
    dialCode: '+387',
    flag: '\u{1F1E7}\u{1F1E6}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country bulgaria = Country(
    name: 'Bulgaria',
    code: 'BG',
    dialCode: '+359',
    flag: '\u{1F1E7}\u{1F1EC}',
    maxLength: 9,
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

  static const Country cyprus = Country(
    name: 'Cyprus',
    code: 'CY',
    dialCode: '+357',
    flag: '\u{1F1E8}\u{1F1FE}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country czechRepublic = Country(
    name: 'Czech Republic',
    code: 'CZ',
    dialCode: '+420',
    flag: '\u{1F1E8}\u{1F1FF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country denmark = Country(
    name: 'Denmark',
    code: 'DK',
    dialCode: '+45',
    flag: '\u{1F1E9}\u{1F1F0}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country estonia = Country(
    name: 'Estonia',
    code: 'EE',
    dialCode: '+372',
    flag: '\u{1F1EA}\u{1F1EA}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country finland = Country(
    name: 'Finland',
    code: 'FI',
    dialCode: '+358',
    flag: '\u{1F1EB}\u{1F1EE}',
    maxLength: 10,
    minLength: 6,
  );

  static const Country france = Country(
    name: 'France',
    code: 'FR',
    dialCode: '+33',
    flag: '\u{1F1EB}\u{1F1F7}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country germany = Country(
    name: 'Germany',
    code: 'DE',
    dialCode: '+49',
    flag: '\u{1F1E9}\u{1F1EA}',
    maxLength: 12,
    minLength: 5,
  );

  static const Country greece = Country(
    name: 'Greece',
    code: 'GR',
    dialCode: '+30',
    flag: '\u{1F1EC}\u{1F1F7}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country hungary = Country(
    name: 'Hungary',
    code: 'HU',
    dialCode: '+36',
    flag: '\u{1F1ED}\u{1F1FA}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country iceland = Country(
    name: 'Iceland',
    code: 'IS',
    dialCode: '+354',
    flag: '\u{1F1EE}\u{1F1F8}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country ireland = Country(
    name: 'Ireland',
    code: 'IE',
    dialCode: '+353',
    flag: '\u{1F1EE}\u{1F1EA}',
    maxLength: 9,
    minLength: 7,
  );

  static const Country italy = Country(
    name: 'Italy',
    code: 'IT',
    dialCode: '+39',
    flag: '\u{1F1EE}\u{1F1F9}',
    maxLength: 10,
    minLength: 9,
  );

  static const Country kosovo = Country(
    name: 'Kosovo',
    code: 'XK',
    dialCode: '+383',
    flag: '\u{1F1FD}\u{1F1F0}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country latvia = Country(
    name: 'Latvia',
    code: 'LV',
    dialCode: '+371',
    flag: '\u{1F1F1}\u{1F1FB}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country liechtenstein = Country(
    name: 'Liechtenstein',
    code: 'LI',
    dialCode: '+423',
    flag: '\u{1F1F1}\u{1F1EE}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country lithuania = Country(
    name: 'Lithuania',
    code: 'LT',
    dialCode: '+370',
    flag: '\u{1F1F1}\u{1F1F9}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country luxembourg = Country(
    name: 'Luxembourg',
    code: 'LU',
    dialCode: '+352',
    flag: '\u{1F1F1}\u{1F1FA}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country malta = Country(
    name: 'Malta',
    code: 'MT',
    dialCode: '+356',
    flag: '\u{1F1F2}\u{1F1F9}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country moldova = Country(
    name: 'Moldova',
    code: 'MD',
    dialCode: '+373',
    flag: '\u{1F1F2}\u{1F1E9}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country monaco = Country(
    name: 'Monaco',
    code: 'MC',
    dialCode: '+377',
    flag: '\u{1F1F2}\u{1F1E8}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country montenegro = Country(
    name: 'Montenegro',
    code: 'ME',
    dialCode: '+382',
    flag: '\u{1F1F2}\u{1F1EA}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country netherlands = Country(
    name: 'Netherlands',
    code: 'NL',
    dialCode: '+31',
    flag: '\u{1F1F3}\u{1F1F1}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country northMacedonia = Country(
    name: 'North Macedonia',
    code: 'MK',
    dialCode: '+389',
    flag: '\u{1F1F2}\u{1F1F0}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country norway = Country(
    name: 'Norway',
    code: 'NO',
    dialCode: '+47',
    flag: '\u{1F1F3}\u{1F1F4}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country poland = Country(
    name: 'Poland',
    code: 'PL',
    dialCode: '+48',
    flag: '\u{1F1F5}\u{1F1F1}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country portugal = Country(
    name: 'Portugal',
    code: 'PT',
    dialCode: '+351',
    flag: '\u{1F1F5}\u{1F1F9}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country romania = Country(
    name: 'Romania',
    code: 'RO',
    dialCode: '+40',
    flag: '\u{1F1F7}\u{1F1F4}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country russia = Country(
    name: 'Russia',
    code: 'RU',
    dialCode: '+7',
    flag: '\u{1F1F7}\u{1F1FA}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country sanMarino = Country(
    name: 'San Marino',
    code: 'SM',
    dialCode: '+378',
    flag: '\u{1F1F8}\u{1F1F2}',
    maxLength: 10,
    minLength: 6,
  );

  static const Country serbia = Country(
    name: 'Serbia',
    code: 'RS',
    dialCode: '+381',
    flag: '\u{1F1F7}\u{1F1F8}',
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

  static const Country spain = Country(
    name: 'Spain',
    code: 'ES',
    dialCode: '+34',
    flag: '\u{1F1EA}\u{1F1F8}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country sweden = Country(
    name: 'Sweden',
    code: 'SE',
    dialCode: '+46',
    flag: '\u{1F1F8}\u{1F1EA}',
    maxLength: 9,
    minLength: 7,
  );

  static const Country switzerland = Country(
    name: 'Switzerland',
    code: 'CH',
    dialCode: '+41',
    flag: '\u{1F1E8}\u{1F1ED}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country ukraine = Country(
    name: 'Ukraine',
    code: 'UA',
    dialCode: '+380',
    flag: '\u{1F1FA}\u{1F1E6}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country unitedKingdom = Country(
    name: 'United Kingdom',
    code: 'GB',
    dialCode: '+44',
    flag: '\u{1F1EC}\u{1F1E7}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country vaticanCity = Country(
    name: 'Vatican City',
    code: 'VA',
    dialCode: '+379',
    flag: '\u{1F1FB}\u{1F1E6}',
    maxLength: 10,
    minLength: 6,
  );

  // ──────────────────────────────────────────────
  // NORTH AMERICAN COUNTRIES
  // ──────────────────────────────────────────────

  static const Country antiguaAndBarbuda = Country(
    name: 'Antigua and Barbuda',
    code: 'AG',
    dialCode: '+1268',
    flag: '\u{1F1E6}\u{1F1EC}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country bahamas = Country(
    name: 'Bahamas',
    code: 'BS',
    dialCode: '+1242',
    flag: '\u{1F1E7}\u{1F1F8}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country barbados = Country(
    name: 'Barbados',
    code: 'BB',
    dialCode: '+1246',
    flag: '\u{1F1E7}\u{1F1E7}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country belize = Country(
    name: 'Belize',
    code: 'BZ',
    dialCode: '+501',
    flag: '\u{1F1E7}\u{1F1FF}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country canada = Country(
    name: 'Canada',
    code: 'CA',
    dialCode: '+1',
    flag: '\u{1F1E8}\u{1F1E6}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country costaRica = Country(
    name: 'Costa Rica',
    code: 'CR',
    dialCode: '+506',
    flag: '\u{1F1E8}\u{1F1F7}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country cuba = Country(
    name: 'Cuba',
    code: 'CU',
    dialCode: '+53',
    flag: '\u{1F1E8}\u{1F1FA}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country dominica = Country(
    name: 'Dominica',
    code: 'DM',
    dialCode: '+1767',
    flag: '\u{1F1E9}\u{1F1F2}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country dominicanRepublic = Country(
    name: 'Dominican Republic',
    code: 'DO',
    dialCode: '+1809',
    flag: '\u{1F1E9}\u{1F1F4}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country elSalvador = Country(
    name: 'El Salvador',
    code: 'SV',
    dialCode: '+503',
    flag: '\u{1F1F8}\u{1F1FB}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country grenada = Country(
    name: 'Grenada',
    code: 'GD',
    dialCode: '+1473',
    flag: '\u{1F1EC}\u{1F1E9}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country guatemala = Country(
    name: 'Guatemala',
    code: 'GT',
    dialCode: '+502',
    flag: '\u{1F1EC}\u{1F1F9}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country haiti = Country(
    name: 'Haiti',
    code: 'HT',
    dialCode: '+509',
    flag: '\u{1F1ED}\u{1F1F9}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country honduras = Country(
    name: 'Honduras',
    code: 'HN',
    dialCode: '+504',
    flag: '\u{1F1ED}\u{1F1F3}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country jamaica = Country(
    name: 'Jamaica',
    code: 'JM',
    dialCode: '+1876',
    flag: '\u{1F1EF}\u{1F1F2}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country mexico = Country(
    name: 'Mexico',
    code: 'MX',
    dialCode: '+52',
    flag: '\u{1F1F2}\u{1F1FD}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country nicaragua = Country(
    name: 'Nicaragua',
    code: 'NI',
    dialCode: '+505',
    flag: '\u{1F1F3}\u{1F1EE}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country panama = Country(
    name: 'Panama',
    code: 'PA',
    dialCode: '+507',
    flag: '\u{1F1F5}\u{1F1E6}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country saintKittsAndNevis = Country(
    name: 'Saint Kitts and Nevis',
    code: 'KN',
    dialCode: '+1869',
    flag: '\u{1F1F0}\u{1F1F3}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country saintLucia = Country(
    name: 'Saint Lucia',
    code: 'LC',
    dialCode: '+1758',
    flag: '\u{1F1F1}\u{1F1E8}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country saintVincentAndTheGrenadines = Country(
    name: 'Saint Vincent and the Grenadines',
    code: 'VC',
    dialCode: '+1784',
    flag: '\u{1F1FB}\u{1F1E8}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country trinidadAndTobago = Country(
    name: 'Trinidad and Tobago',
    code: 'TT',
    dialCode: '+1868',
    flag: '\u{1F1F9}\u{1F1F9}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country unitedStates = Country(
    name: 'United States',
    code: 'US',
    dialCode: '+1',
    flag: '\u{1F1FA}\u{1F1F8}',
    maxLength: 10,
    minLength: 10,
  );

  // ──────────────────────────────────────────────
  // SOUTH AMERICAN COUNTRIES
  // ──────────────────────────────────────────────

  static const Country argentina = Country(
    name: 'Argentina',
    code: 'AR',
    dialCode: '+54',
    flag: '\u{1F1E6}\u{1F1F7}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country bolivia = Country(
    name: 'Bolivia',
    code: 'BO',
    dialCode: '+591',
    flag: '\u{1F1E7}\u{1F1F4}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country brazil = Country(
    name: 'Brazil',
    code: 'BR',
    dialCode: '+55',
    flag: '\u{1F1E7}\u{1F1F7}',
    maxLength: 11,
    minLength: 10,
  );

  static const Country chile = Country(
    name: 'Chile',
    code: 'CL',
    dialCode: '+56',
    flag: '\u{1F1E8}\u{1F1F1}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country colombia = Country(
    name: 'Colombia',
    code: 'CO',
    dialCode: '+57',
    flag: '\u{1F1E8}\u{1F1F4}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country ecuador = Country(
    name: 'Ecuador',
    code: 'EC',
    dialCode: '+593',
    flag: '\u{1F1EA}\u{1F1E8}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country guyana = Country(
    name: 'Guyana',
    code: 'GY',
    dialCode: '+592',
    flag: '\u{1F1EC}\u{1F1FE}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country paraguay = Country(
    name: 'Paraguay',
    code: 'PY',
    dialCode: '+595',
    flag: '\u{1F1F5}\u{1F1FE}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country peru = Country(
    name: 'Peru',
    code: 'PE',
    dialCode: '+51',
    flag: '\u{1F1F5}\u{1F1EA}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country suriname = Country(
    name: 'Suriname',
    code: 'SR',
    dialCode: '+597',
    flag: '\u{1F1F8}\u{1F1F7}',
    maxLength: 7,
    minLength: 6,
  );

  static const Country uruguay = Country(
    name: 'Uruguay',
    code: 'UY',
    dialCode: '+598',
    flag: '\u{1F1FA}\u{1F1FE}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country venezuela = Country(
    name: 'Venezuela',
    code: 'VE',
    dialCode: '+58',
    flag: '\u{1F1FB}\u{1F1EA}',
    maxLength: 10,
    minLength: 10,
  );

  // ──────────────────────────────────────────────
  // ASIAN COUNTRIES
  // ──────────────────────────────────────────────

  static const Country afghanistan = Country(
    name: 'Afghanistan',
    code: 'AF',
    dialCode: '+93',
    flag: '\u{1F1E6}\u{1F1EB}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country armenia = Country(
    name: 'Armenia',
    code: 'AM',
    dialCode: '+374',
    flag: '\u{1F1E6}\u{1F1F2}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country azerbaijan = Country(
    name: 'Azerbaijan',
    code: 'AZ',
    dialCode: '+994',
    flag: '\u{1F1E6}\u{1F1FF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country bangladesh = Country(
    name: 'Bangladesh',
    code: 'BD',
    dialCode: '+880',
    flag: '\u{1F1E7}\u{1F1E9}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country bhutan = Country(
    name: 'Bhutan',
    code: 'BT',
    dialCode: '+975',
    flag: '\u{1F1E7}\u{1F1F9}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country brunei = Country(
    name: 'Brunei',
    code: 'BN',
    dialCode: '+673',
    flag: '\u{1F1E7}\u{1F1F3}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country cambodia = Country(
    name: 'Cambodia',
    code: 'KH',
    dialCode: '+855',
    flag: '\u{1F1F0}\u{1F1ED}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country china = Country(
    name: 'China',
    code: 'CN',
    dialCode: '+86',
    flag: '\u{1F1E8}\u{1F1F3}',
    maxLength: 11,
    minLength: 11,
  );

  static const Country georgia = Country(
    name: 'Georgia',
    code: 'GE',
    dialCode: '+995',
    flag: '\u{1F1EC}\u{1F1EA}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country hongKong = Country(
    name: 'Hong Kong',
    code: 'HK',
    dialCode: '+852',
    flag: '\u{1F1ED}\u{1F1F0}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country india = Country(
    name: 'India',
    code: 'IN',
    dialCode: '+91',
    flag: '\u{1F1EE}\u{1F1F3}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country indonesia = Country(
    name: 'Indonesia',
    code: 'ID',
    dialCode: '+62',
    flag: '\u{1F1EE}\u{1F1E9}',
    maxLength: 12,
    minLength: 9,
  );

  static const Country japan = Country(
    name: 'Japan',
    code: 'JP',
    dialCode: '+81',
    flag: '\u{1F1EF}\u{1F1F5}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country kazakhstan = Country(
    name: 'Kazakhstan',
    code: 'KZ',
    dialCode: '+7',
    flag: '\u{1F1F0}\u{1F1FF}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country kyrgyzstan = Country(
    name: 'Kyrgyzstan',
    code: 'KG',
    dialCode: '+996',
    flag: '\u{1F1F0}\u{1F1EC}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country laos = Country(
    name: 'Laos',
    code: 'LA',
    dialCode: '+856',
    flag: '\u{1F1F1}\u{1F1E6}',
    maxLength: 10,
    minLength: 8,
  );

  static const Country macau = Country(
    name: 'Macau',
    code: 'MO',
    dialCode: '+853',
    flag: '\u{1F1F2}\u{1F1F4}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country malaysia = Country(
    name: 'Malaysia',
    code: 'MY',
    dialCode: '+60',
    flag: '\u{1F1F2}\u{1F1FE}',
    maxLength: 10,
    minLength: 9,
  );

  static const Country maldives = Country(
    name: 'Maldives',
    code: 'MV',
    dialCode: '+960',
    flag: '\u{1F1F2}\u{1F1FB}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country mongolia = Country(
    name: 'Mongolia',
    code: 'MN',
    dialCode: '+976',
    flag: '\u{1F1F2}\u{1F1F3}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country myanmar = Country(
    name: 'Myanmar',
    code: 'MM',
    dialCode: '+95',
    flag: '\u{1F1F2}\u{1F1F2}',
    maxLength: 10,
    minLength: 7,
  );

  static const Country nepal = Country(
    name: 'Nepal',
    code: 'NP',
    dialCode: '+977',
    flag: '\u{1F1F3}\u{1F1F5}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country northKorea = Country(
    name: 'North Korea',
    code: 'KP',
    dialCode: '+850',
    flag: '\u{1F1F0}\u{1F1F5}',
    maxLength: 10,
    minLength: 6,
  );

  static const Country pakistan = Country(
    name: 'Pakistan',
    code: 'PK',
    dialCode: '+92',
    flag: '\u{1F1F5}\u{1F1F0}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country philippines = Country(
    name: 'Philippines',
    code: 'PH',
    dialCode: '+63',
    flag: '\u{1F1F5}\u{1F1ED}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country singapore = Country(
    name: 'Singapore',
    code: 'SG',
    dialCode: '+65',
    flag: '\u{1F1F8}\u{1F1EC}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country southKorea = Country(
    name: 'South Korea',
    code: 'KR',
    dialCode: '+82',
    flag: '\u{1F1F0}\u{1F1F7}',
    maxLength: 11,
    minLength: 9,
  );

  static const Country sriLanka = Country(
    name: 'Sri Lanka',
    code: 'LK',
    dialCode: '+94',
    flag: '\u{1F1F1}\u{1F1F0}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country taiwan = Country(
    name: 'Taiwan',
    code: 'TW',
    dialCode: '+886',
    flag: '\u{1F1F9}\u{1F1FC}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country tajikistan = Country(
    name: 'Tajikistan',
    code: 'TJ',
    dialCode: '+992',
    flag: '\u{1F1F9}\u{1F1EF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country thailand = Country(
    name: 'Thailand',
    code: 'TH',
    dialCode: '+66',
    flag: '\u{1F1F9}\u{1F1ED}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country timorLeste = Country(
    name: 'Timor-Leste',
    code: 'TL',
    dialCode: '+670',
    flag: '\u{1F1F9}\u{1F1F1}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country turkmenistan = Country(
    name: 'Turkmenistan',
    code: 'TM',
    dialCode: '+993',
    flag: '\u{1F1F9}\u{1F1F2}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country uzbekistan = Country(
    name: 'Uzbekistan',
    code: 'UZ',
    dialCode: '+998',
    flag: '\u{1F1FA}\u{1F1FF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country vietnam = Country(
    name: 'Vietnam',
    code: 'VN',
    dialCode: '+84',
    flag: '\u{1F1FB}\u{1F1F3}',
    maxLength: 10,
    minLength: 9,
  );

  // ──────────────────────────────────────────────
  // MIDDLE EASTERN COUNTRIES
  // ──────────────────────────────────────────────

  static const Country bahrain = Country(
    name: 'Bahrain',
    code: 'BH',
    dialCode: '+973',
    flag: '\u{1F1E7}\u{1F1ED}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country iraq = Country(
    name: 'Iraq',
    code: 'IQ',
    dialCode: '+964',
    flag: '\u{1F1EE}\u{1F1F6}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country iran = Country(
    name: 'Iran',
    code: 'IR',
    dialCode: '+98',
    flag: '\u{1F1EE}\u{1F1F7}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country israel = Country(
    name: 'Israel',
    code: 'IL',
    dialCode: '+972',
    flag: '\u{1F1EE}\u{1F1F1}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country jordan = Country(
    name: 'Jordan',
    code: 'JO',
    dialCode: '+962',
    flag: '\u{1F1EF}\u{1F1F4}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country kuwait = Country(
    name: 'Kuwait',
    code: 'KW',
    dialCode: '+965',
    flag: '\u{1F1F0}\u{1F1FC}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country lebanon = Country(
    name: 'Lebanon',
    code: 'LB',
    dialCode: '+961',
    flag: '\u{1F1F1}\u{1F1E7}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country oman = Country(
    name: 'Oman',
    code: 'OM',
    dialCode: '+968',
    flag: '\u{1F1F4}\u{1F1F2}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country palestine = Country(
    name: 'Palestine',
    code: 'PS',
    dialCode: '+970',
    flag: '\u{1F1F5}\u{1F1F8}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country qatar = Country(
    name: 'Qatar',
    code: 'QA',
    dialCode: '+974',
    flag: '\u{1F1F6}\u{1F1E6}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country saudiArabia = Country(
    name: 'Saudi Arabia',
    code: 'SA',
    dialCode: '+966',
    flag: '\u{1F1F8}\u{1F1E6}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country syria = Country(
    name: 'Syria',
    code: 'SY',
    dialCode: '+963',
    flag: '\u{1F1F8}\u{1F1FE}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country turkey = Country(
    name: 'Turkey',
    code: 'TR',
    dialCode: '+90',
    flag: '\u{1F1F9}\u{1F1F7}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country unitedArabEmirates = Country(
    name: 'United Arab Emirates',
    code: 'AE',
    dialCode: '+971',
    flag: '\u{1F1E6}\u{1F1EA}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country yemen = Country(
    name: 'Yemen',
    code: 'YE',
    dialCode: '+967',
    flag: '\u{1F1FE}\u{1F1EA}',
    maxLength: 9,
    minLength: 9,
  );

  // ──────────────────────────────────────────────
  // AFRICAN COUNTRIES
  // ──────────────────────────────────────────────

  static const Country algeria = Country(
    name: 'Algeria',
    code: 'DZ',
    dialCode: '+213',
    flag: '\u{1F1E9}\u{1F1FF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country angola = Country(
    name: 'Angola',
    code: 'AO',
    dialCode: '+244',
    flag: '\u{1F1E6}\u{1F1F4}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country benin = Country(
    name: 'Benin',
    code: 'BJ',
    dialCode: '+229',
    flag: '\u{1F1E7}\u{1F1EF}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country botswana = Country(
    name: 'Botswana',
    code: 'BW',
    dialCode: '+267',
    flag: '\u{1F1E7}\u{1F1FC}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country burkinaFaso = Country(
    name: 'Burkina Faso',
    code: 'BF',
    dialCode: '+226',
    flag: '\u{1F1E7}\u{1F1EB}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country burundi = Country(
    name: 'Burundi',
    code: 'BI',
    dialCode: '+257',
    flag: '\u{1F1E7}\u{1F1EE}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country capeVerde = Country(
    name: 'Cape Verde',
    code: 'CV',
    dialCode: '+238',
    flag: '\u{1F1E8}\u{1F1FB}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country cameroon = Country(
    name: 'Cameroon',
    code: 'CM',
    dialCode: '+237',
    flag: '\u{1F1E8}\u{1F1F2}',
    maxLength: 9,
    minLength: 8,
  );

  static const Country centralAfricanRepublic = Country(
    name: 'Central African Republic',
    code: 'CF',
    dialCode: '+236',
    flag: '\u{1F1E8}\u{1F1EB}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country chad = Country(
    name: 'Chad',
    code: 'TD',
    dialCode: '+235',
    flag: '\u{1F1F9}\u{1F1E9}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country comoros = Country(
    name: 'Comoros',
    code: 'KM',
    dialCode: '+269',
    flag: '\u{1F1F0}\u{1F1F2}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country congoBrazzaville = Country(
    name: 'Congo (Brazzaville)',
    code: 'CG',
    dialCode: '+242',
    flag: '\u{1F1E8}\u{1F1EC}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country congoKinshasa = Country(
    name: 'Congo (Kinshasa)',
    code: 'CD',
    dialCode: '+243',
    flag: '\u{1F1E8}\u{1F1E9}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country coteDIvoire = Country(
    name: "Cote d'Ivoire",
    code: 'CI',
    dialCode: '+225',
    flag: '\u{1F1E8}\u{1F1EE}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country djibouti = Country(
    name: 'Djibouti',
    code: 'DJ',
    dialCode: '+253',
    flag: '\u{1F1E9}\u{1F1EF}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country egypt = Country(
    name: 'Egypt',
    code: 'EG',
    dialCode: '+20',
    flag: '\u{1F1EA}\u{1F1EC}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country equatorialGuinea = Country(
    name: 'Equatorial Guinea',
    code: 'GQ',
    dialCode: '+240',
    flag: '\u{1F1EC}\u{1F1F6}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country eritrea = Country(
    name: 'Eritrea',
    code: 'ER',
    dialCode: '+291',
    flag: '\u{1F1EA}\u{1F1F7}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country eswatini = Country(
    name: 'Eswatini',
    code: 'SZ',
    dialCode: '+268',
    flag: '\u{1F1F8}\u{1F1FF}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country ethiopia = Country(
    name: 'Ethiopia',
    code: 'ET',
    dialCode: '+251',
    flag: '\u{1F1EA}\u{1F1F9}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country gabon = Country(
    name: 'Gabon',
    code: 'GA',
    dialCode: '+241',
    flag: '\u{1F1EC}\u{1F1E6}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country gambia = Country(
    name: 'Gambia',
    code: 'GM',
    dialCode: '+220',
    flag: '\u{1F1EC}\u{1F1F2}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country ghana = Country(
    name: 'Ghana',
    code: 'GH',
    dialCode: '+233',
    flag: '\u{1F1EC}\u{1F1ED}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country guinea = Country(
    name: 'Guinea',
    code: 'GN',
    dialCode: '+224',
    flag: '\u{1F1EC}\u{1F1F3}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country guineaBissau = Country(
    name: 'Guinea-Bissau',
    code: 'GW',
    dialCode: '+245',
    flag: '\u{1F1EC}\u{1F1FC}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country kenya = Country(
    name: 'Kenya',
    code: 'KE',
    dialCode: '+254',
    flag: '\u{1F1F0}\u{1F1EA}',
    maxLength: 10,
    minLength: 9,
  );

  static const Country lesotho = Country(
    name: 'Lesotho',
    code: 'LS',
    dialCode: '+266',
    flag: '\u{1F1F1}\u{1F1F8}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country liberia = Country(
    name: 'Liberia',
    code: 'LR',
    dialCode: '+231',
    flag: '\u{1F1F1}\u{1F1F7}',
    maxLength: 9,
    minLength: 7,
  );

  static const Country libya = Country(
    name: 'Libya',
    code: 'LY',
    dialCode: '+218',
    flag: '\u{1F1F1}\u{1F1FE}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country madagascar = Country(
    name: 'Madagascar',
    code: 'MG',
    dialCode: '+261',
    flag: '\u{1F1F2}\u{1F1EC}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country malawi = Country(
    name: 'Malawi',
    code: 'MW',
    dialCode: '+265',
    flag: '\u{1F1F2}\u{1F1FC}',
    maxLength: 9,
    minLength: 7,
  );

  static const Country mali = Country(
    name: 'Mali',
    code: 'ML',
    dialCode: '+223',
    flag: '\u{1F1F2}\u{1F1F1}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country mauritania = Country(
    name: 'Mauritania',
    code: 'MR',
    dialCode: '+222',
    flag: '\u{1F1F2}\u{1F1F7}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country mauritius = Country(
    name: 'Mauritius',
    code: 'MU',
    dialCode: '+230',
    flag: '\u{1F1F2}\u{1F1FA}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country morocco = Country(
    name: 'Morocco',
    code: 'MA',
    dialCode: '+212',
    flag: '\u{1F1F2}\u{1F1E6}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country mozambique = Country(
    name: 'Mozambique',
    code: 'MZ',
    dialCode: '+258',
    flag: '\u{1F1F2}\u{1F1FF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country namibia = Country(
    name: 'Namibia',
    code: 'NA',
    dialCode: '+264',
    flag: '\u{1F1F3}\u{1F1E6}',
    maxLength: 9,
    minLength: 7,
  );

  static const Country niger = Country(
    name: 'Niger',
    code: 'NE',
    dialCode: '+227',
    flag: '\u{1F1F3}\u{1F1EA}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country nigeria = Country(
    name: 'Nigeria',
    code: 'NG',
    dialCode: '+234',
    flag: '\u{1F1F3}\u{1F1EC}',
    maxLength: 10,
    minLength: 10,
  );

  static const Country rwanda = Country(
    name: 'Rwanda',
    code: 'RW',
    dialCode: '+250',
    flag: '\u{1F1F7}\u{1F1FC}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country saoTomeAndPrincipe = Country(
    name: 'Sao Tome and Principe',
    code: 'ST',
    dialCode: '+239',
    flag: '\u{1F1F8}\u{1F1F9}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country senegal = Country(
    name: 'Senegal',
    code: 'SN',
    dialCode: '+221',
    flag: '\u{1F1F8}\u{1F1F3}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country seychelles = Country(
    name: 'Seychelles',
    code: 'SC',
    dialCode: '+248',
    flag: '\u{1F1F8}\u{1F1E8}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country sierraLeone = Country(
    name: 'Sierra Leone',
    code: 'SL',
    dialCode: '+232',
    flag: '\u{1F1F8}\u{1F1F1}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country somalia = Country(
    name: 'Somalia',
    code: 'SO',
    dialCode: '+252',
    flag: '\u{1F1F8}\u{1F1F4}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country southAfrica = Country(
    name: 'South Africa',
    code: 'ZA',
    dialCode: '+27',
    flag: '\u{1F1FF}\u{1F1E6}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country southSudan = Country(
    name: 'South Sudan',
    code: 'SS',
    dialCode: '+211',
    flag: '\u{1F1F8}\u{1F1F8}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country sudan = Country(
    name: 'Sudan',
    code: 'SD',
    dialCode: '+249',
    flag: '\u{1F1F8}\u{1F1E9}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country tanzania = Country(
    name: 'Tanzania',
    code: 'TZ',
    dialCode: '+255',
    flag: '\u{1F1F9}\u{1F1FF}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country togo = Country(
    name: 'Togo',
    code: 'TG',
    dialCode: '+228',
    flag: '\u{1F1F9}\u{1F1EC}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country tunisia = Country(
    name: 'Tunisia',
    code: 'TN',
    dialCode: '+216',
    flag: '\u{1F1F9}\u{1F1F3}',
    maxLength: 8,
    minLength: 8,
  );

  static const Country uganda = Country(
    name: 'Uganda',
    code: 'UG',
    dialCode: '+256',
    flag: '\u{1F1FA}\u{1F1EC}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country zambia = Country(
    name: 'Zambia',
    code: 'ZM',
    dialCode: '+260',
    flag: '\u{1F1FF}\u{1F1F2}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country zimbabwe = Country(
    name: 'Zimbabwe',
    code: 'ZW',
    dialCode: '+263',
    flag: '\u{1F1FF}\u{1F1FC}',
    maxLength: 9,
    minLength: 9,
  );

  // ──────────────────────────────────────────────
  // OCEANIAN COUNTRIES
  // ──────────────────────────────────────────────

  static const Country australia = Country(
    name: 'Australia',
    code: 'AU',
    dialCode: '+61',
    flag: '\u{1F1E6}\u{1F1FA}',
    maxLength: 9,
    minLength: 9,
  );

  static const Country fiji = Country(
    name: 'Fiji',
    code: 'FJ',
    dialCode: '+679',
    flag: '\u{1F1EB}\u{1F1EF}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country kiribati = Country(
    name: 'Kiribati',
    code: 'KI',
    dialCode: '+686',
    flag: '\u{1F1F0}\u{1F1EE}',
    maxLength: 8,
    minLength: 5,
  );

  static const Country marshallIslands = Country(
    name: 'Marshall Islands',
    code: 'MH',
    dialCode: '+692',
    flag: '\u{1F1F2}\u{1F1ED}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country micronesia = Country(
    name: 'Micronesia',
    code: 'FM',
    dialCode: '+691',
    flag: '\u{1F1EB}\u{1F1F2}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country nauru = Country(
    name: 'Nauru',
    code: 'NR',
    dialCode: '+674',
    flag: '\u{1F1F3}\u{1F1F7}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country newZealand = Country(
    name: 'New Zealand',
    code: 'NZ',
    dialCode: '+64',
    flag: '\u{1F1F3}\u{1F1FF}',
    maxLength: 10,
    minLength: 8,
  );

  static const Country palau = Country(
    name: 'Palau',
    code: 'PW',
    dialCode: '+680',
    flag: '\u{1F1F5}\u{1F1FC}',
    maxLength: 7,
    minLength: 7,
  );

  static const Country papuaNewGuinea = Country(
    name: 'Papua New Guinea',
    code: 'PG',
    dialCode: '+675',
    flag: '\u{1F1F5}\u{1F1EC}',
    maxLength: 8,
    minLength: 7,
  );

  static const Country samoa = Country(
    name: 'Samoa',
    code: 'WS',
    dialCode: '+685',
    flag: '\u{1F1FC}\u{1F1F8}',
    maxLength: 7,
    minLength: 5,
  );

  static const Country solomonIslands = Country(
    name: 'Solomon Islands',
    code: 'SB',
    dialCode: '+677',
    flag: '\u{1F1F8}\u{1F1E7}',
    maxLength: 7,
    minLength: 5,
  );

  static const Country tonga = Country(
    name: 'Tonga',
    code: 'TO',
    dialCode: '+676',
    flag: '\u{1F1F9}\u{1F1F4}',
    maxLength: 7,
    minLength: 5,
  );

  static const Country tuvalu = Country(
    name: 'Tuvalu',
    code: 'TV',
    dialCode: '+688',
    flag: '\u{1F1F9}\u{1F1FB}',
    maxLength: 6,
    minLength: 5,
  );

  static const Country vanuatu = Country(
    name: 'Vanuatu',
    code: 'VU',
    dialCode: '+678',
    flag: '\u{1F1FB}\u{1F1FA}',
    maxLength: 7,
    minLength: 5,
  );

  // ──────────────────────────────────────────────
  // REGION LISTS (sorted alphabetically)
  // ──────────────────────────────────────────────

  /// European countries sorted alphabetically
  static const List<Country> european = [
    albania,
    andorra,
    austria,
    belarus,
    belgium,
    bosniaAndHerzegovina,
    bulgaria,
    croatia,
    cyprus,
    czechRepublic,
    denmark,
    estonia,
    finland,
    france,
    georgia,
    germany,
    greece,
    hungary,
    iceland,
    ireland,
    italy,
    kosovo,
    latvia,
    liechtenstein,
    lithuania,
    luxembourg,
    malta,
    moldova,
    monaco,
    montenegro,
    netherlands,
    northMacedonia,
    norway,
    poland,
    portugal,
    romania,
    russia,
    sanMarino,
    serbia,
    slovakia,
    slovenia,
    spain,
    sweden,
    switzerland,
    ukraine,
    unitedKingdom,
    vaticanCity,
  ];

  /// North American countries sorted alphabetically
  static const List<Country> northAmerican = [
    antiguaAndBarbuda,
    bahamas,
    barbados,
    belize,
    canada,
    costaRica,
    cuba,
    dominica,
    dominicanRepublic,
    elSalvador,
    grenada,
    guatemala,
    haiti,
    honduras,
    jamaica,
    mexico,
    nicaragua,
    panama,
    saintKittsAndNevis,
    saintLucia,
    saintVincentAndTheGrenadines,
    trinidadAndTobago,
    unitedStates,
  ];

  /// South American countries sorted alphabetically
  static const List<Country> southAmerican = [
    argentina,
    bolivia,
    brazil,
    chile,
    colombia,
    ecuador,
    guyana,
    paraguay,
    peru,
    suriname,
    uruguay,
    venezuela,
  ];

  /// Asian countries sorted alphabetically
  static const List<Country> asian = [
    afghanistan,
    armenia,
    azerbaijan,
    bangladesh,
    bhutan,
    brunei,
    cambodia,
    china,
    hongKong,
    india,
    indonesia,
    japan,
    kazakhstan,
    kyrgyzstan,
    laos,
    macau,
    malaysia,
    maldives,
    mongolia,
    myanmar,
    nepal,
    northKorea,
    pakistan,
    philippines,
    singapore,
    southKorea,
    sriLanka,
    taiwan,
    tajikistan,
    thailand,
    timorLeste,
    turkmenistan,
    uzbekistan,
    vietnam,
  ];

  /// Middle Eastern countries sorted alphabetically
  static const List<Country> middleEastern = [
    bahrain,
    iran,
    iraq,
    israel,
    jordan,
    kuwait,
    lebanon,
    oman,
    palestine,
    qatar,
    saudiArabia,
    syria,
    turkey,
    unitedArabEmirates,
    yemen,
  ];

  /// African countries sorted alphabetically
  static const List<Country> african = [
    algeria,
    angola,
    benin,
    botswana,
    burkinaFaso,
    burundi,
    cameroon,
    capeVerde,
    centralAfricanRepublic,
    chad,
    comoros,
    congoBrazzaville,
    congoKinshasa,
    coteDIvoire,
    djibouti,
    egypt,
    equatorialGuinea,
    eritrea,
    eswatini,
    ethiopia,
    gabon,
    gambia,
    ghana,
    guinea,
    guineaBissau,
    kenya,
    lesotho,
    liberia,
    libya,
    madagascar,
    malawi,
    mali,
    mauritania,
    mauritius,
    morocco,
    mozambique,
    namibia,
    niger,
    nigeria,
    rwanda,
    saoTomeAndPrincipe,
    senegal,
    seychelles,
    sierraLeone,
    somalia,
    southAfrica,
    southSudan,
    sudan,
    tanzania,
    togo,
    tunisia,
    uganda,
    zambia,
    zimbabwe,
  ];

  /// Oceanian countries sorted alphabetically
  static const List<Country> oceanian = [
    australia,
    fiji,
    kiribati,
    marshallIslands,
    micronesia,
    nauru,
    newZealand,
    palau,
    papuaNewGuinea,
    samoa,
    solomonIslands,
    tonga,
    tuvalu,
    vanuatu,
  ];

  /// All countries worldwide
  static const List<Country> all = [
    ...european,
    ...northAmerican,
    ...southAmerican,
    ...asian,
    ...middleEastern,
    ...african,
    ...oceanian,
  ];

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
