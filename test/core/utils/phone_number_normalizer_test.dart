import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/data/countries.dart';
import 'package:teybatseller/core/utils/phone_number_normalizer.dart';

void main() {
  group('PhoneNumberNormalizer', () {
    test('normalizes an Austrian national number and its trunk zero', () {
      expect(
        PhoneNumberNormalizer.normalize('0664 1234567', Countries.austria),
        '+436641234567',
      );
    });

    test('keeps a pasted plus-prefixed international number', () {
      expect(
        PhoneNumberNormalizer.normalize(
          '+43 (664) 123-4567',
          Countries.austria,
        ),
        '+436641234567',
      );
    });

    test('normalizes an international number starting with 00', () {
      expect(
        PhoneNumberNormalizer.normalize('0043 664 1234567', Countries.austria),
        '+436641234567',
      );
    });

    test('recognizes a selected country code pasted without a prefix', () {
      expect(
        PhoneNumberNormalizer.normalize('436641234567', Countries.austria),
        '+436641234567',
      );
    });

    test('detects another country code pasted without a prefix', () {
      final result = PhoneNumberNormalizer.parse(
        '436641234567',
        Countries.andorra,
      );

      expect(result?.e164, '+436641234567');
      expect(result?.countryCode, 'AT');
      expect(result?.nationalNumber, '6641234567');
      expect(result?.wasInternationalInput, isTrue);
    });

    test('splits a formatted international number for the phone field', () {
      final result = PhoneNumberNormalizer.parse(
        '+43 (664) 123-4567',
        Countries.andorra,
      );

      expect(result?.countryCode, 'AT');
      expect(result?.nationalNumber, '6641234567');
    });

    test('supports Eastern Arabic numerals', () {
      expect(
        PhoneNumberNormalizer.normalize('٠٦٦٤١٢٣٤٥٦٧', Countries.austria),
        '+436641234567',
      );
    });

    test('does not remove a significant Italian leading zero', () {
      expect(
        PhoneNumberNormalizer.normalize('02 36618 300', Countries.italy),
        '+390236618300',
      );
    });

    test('accepts an explicit country different from the selected country', () {
      expect(
        PhoneNumberNormalizer.normalize('+966 55 123 4567', Countries.austria),
        '+966551234567',
      );
    });

    test('rejects invalid input', () {
      expect(
        PhoneNumberNormalizer.normalize('not a phone', Countries.austria),
        isNull,
      );
    });
  });
}
