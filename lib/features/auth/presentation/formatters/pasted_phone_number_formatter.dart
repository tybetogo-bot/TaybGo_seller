import 'package:flutter/services.dart';

import '../../../../core/data/countries.dart';
import '../../../../core/utils/phone_number_normalizer.dart';

/// Normalizes completed international numbers and multi-character pastes.
/// Single-character national-number edits are left untouched.
class PastedPhoneNumberFormatter extends TextInputFormatter {
  PastedPhoneNumberFormatter({
    required this.selectedCountry,
    required this.onCountryDetected,
  });

  final Country selectedCountry;
  final ValueChanged<Country> onCountryDetected;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final parsed = PhoneNumberNormalizer.parse(newValue.text, selectedCountry);
    if (parsed == null) return newValue;

    final isBulkEdit = (newValue.text.length - oldValue.text.length).abs() > 1;
    if (!isBulkEdit && !parsed.wasInternationalInput) return newValue;

    final detectedCountry = Countries.getByCode(parsed.countryCode);
    if (detectedCountry == null) return newValue;

    if (detectedCountry != selectedCountry) {
      onCountryDetected(detectedCountry);
    }

    return TextEditingValue(
      text: parsed.nationalNumber,
      selection: TextSelection.collapsed(offset: parsed.nationalNumber.length),
    );
  }
}
