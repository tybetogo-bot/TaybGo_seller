import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/data/countries.dart';
import 'package:teybatseller/features/auth/presentation/formatters/pasted_phone_number_formatter.dart';

void main() {
  group('PastedPhoneNumberFormatter', () {
    test('switches country and keeps only the national number', () {
      Country? detectedCountry;
      final formatter = PastedPhoneNumberFormatter(
        selectedCountry: Countries.andorra,
        onCountryDetected: (country) => detectedCountry = country,
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '+43 (664) 123-4567'),
      );

      expect(detectedCountry, Countries.austria);
      expect(result.text, '6641234567');
      expect(result.selection.baseOffset, result.text.length);
    });

    test('removes a national trunk zero from a pasted number', () {
      final formatter = PastedPhoneNumberFormatter(
        selectedCountry: Countries.austria,
        onCountryDetected: (_) {},
      );

      final result = formatter.formatEditUpdate(
        TextEditingValue.empty,
        const TextEditingValue(text: '0664 1234567'),
      );

      expect(result.text, '6641234567');
    });

    test('does not rewrite an in-progress single-character edit', () {
      final formatter = PastedPhoneNumberFormatter(
        selectedCountry: Countries.austria,
        onCountryDetected: (_) {},
      );

      final result = formatter.formatEditUpdate(
        const TextEditingValue(text: '664123456'),
        const TextEditingValue(text: '6641234567'),
      );

      expect(result.text, '6641234567');
    });
  });
}
