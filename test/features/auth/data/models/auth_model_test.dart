import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/config/constants.dart';
import 'package:teybatseller/features/auth/data/models/auth_model.dart';

void main() {
  group('OTP auth payloads', () {
    test('OtpRequest includes seller target_role', () {
      const request = OtpRequest(phone: '+963999999999');

      expect(request.toJson(), {
        'phone': '+963999999999',
        'target_role': UserRoles.seller,
      });
    });

    test('OtpVerifyRequest includes seller target_role', () {
      const request = OtpVerifyRequest(phone: '+963999999999', code: '123456');

      expect(request.toJson(), {
        'phone': '+963999999999',
        'code': '123456',
        'target_role': UserRoles.seller,
      });
    });
  });
}
