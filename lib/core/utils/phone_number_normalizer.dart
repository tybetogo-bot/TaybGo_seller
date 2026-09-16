import 'package:phone_numbers_parser/phone_numbers_parser.dart';

import '../data/countries.dart';

/// Parses user-entered phone numbers and returns their E.164 representation.
///
/// The selected country is used only when the input is a national number.
/// Explicit international numbers (for example, +43... or 0043...) keep their
/// own country code.
class PhoneNumberNormalizer {
  PhoneNumberNormalizer._();

  static NormalizedPhoneNumber? parse(String input, Country selectedCountry) {
    final rawInput = input.trim();
    if (rawInput.isEmpty) return null;

    final callerCountry = IsoCode.values.byName(
      selectedCountry.code.toUpperCase(),
    );
    final parsed = _tryParse(rawInput, callerCountry: callerCountry);
    if (parsed != null && parsed.isValid()) {
      return _result(
        parsed,
        wasInternationalInput: _hasInternationalPrefix(rawInput),
      );
    }

    // If the selected-country interpretation is invalid, try the pasted
    // digits as a full international number. This handles numbers whose
    // country code was pasted without '+' or '00', even when another country
    // is currently selected.
    final asciiDigits = _asciiDigitsOnly(rawInput);
    if (asciiDigits.isEmpty) return null;

    final internationalDigits = asciiDigits.startsWith('00')
        ? asciiDigits.replaceFirst(RegExp(r'^0+'), '')
        : asciiDigits;
    final international = _tryParse('+$internationalDigits');
    if (international != null && international.isValid()) {
      return _result(international, wasInternationalInput: true);
    }

    return null;
  }

  static String? normalize(String input, Country selectedCountry) =>
      parse(input, selectedCountry)?.e164;

  /// Returns a submission-ready number without enforcing real-world length or
  /// numbering-plan rules. Valid numbers are normalized as usual; short test
  /// numbers fall back to the selected country's dialing code.
  static String? normalizeLenient(String input, Country selectedCountry) {
    final normalized = normalize(input, selectedCountry);
    if (normalized != null) return normalized;

    final rawInput = input.trim();
    final digits = _asciiDigitsOnly(rawInput);
    if (digits.isEmpty) return null;

    if (rawInput.startsWith('+')) return '+$digits';

    if (digits.startsWith('00')) {
      final internationalDigits = digits.substring(2);
      return internationalDigits.isEmpty ? null : '+$internationalDigits';
    }

    return '${selectedCountry.dialCode}$digits';
  }

  static bool isValid(String input, Country selectedCountry) =>
      normalize(input, selectedCountry) != null;

  static PhoneNumber? _tryParse(String input, {IsoCode? callerCountry}) {
    try {
      return PhoneNumber.parse(input, callerCountry: callerCountry);
    } catch (_) {
      return null;
    }
  }

  static NormalizedPhoneNumber _result(
    PhoneNumber phoneNumber, {
    required bool wasInternationalInput,
  }) => NormalizedPhoneNumber(
    e164: phoneNumber.international,
    countryCode: phoneNumber.isoCode.name,
    nationalNumber: phoneNumber.nsn,
    wasInternationalInput: wasInternationalInput,
  );

  static bool _hasInternationalPrefix(String input) {
    final trimmed = input.trimLeft();
    return trimmed.startsWith('+') ||
        _asciiDigitsOnly(trimmed).startsWith('00');
  }

  static String _asciiDigitsOnly(String input) {
    const digitSets = <String>['0123456789', '٠١٢٣٤٥٦٧٨٩', '۰۱۲۳۴۵۶۷۸۹'];
    final buffer = StringBuffer();

    for (final rune in input.runes) {
      final character = String.fromCharCode(rune);
      for (final digits in digitSets) {
        final index = digits.indexOf(character);
        if (index >= 0) {
          buffer.write(index);
          break;
        }
      }
    }

    return buffer.toString();
  }
}

class NormalizedPhoneNumber {
  const NormalizedPhoneNumber({
    required this.e164,
    required this.countryCode,
    required this.nationalNumber,
    required this.wasInternationalInput,
  });

  final String e164;
  final String countryCode;
  final String nationalNumber;
  final bool wasInternationalInput;
}
