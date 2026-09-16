import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/features/orders/data/models/food_checkout_model.dart';

void main() {
  group('Food order pricing payloads', () {
    const address = OrderAddressData(
      label: 'Test address',
      lat: '48.208174',
      lng: '16.373819',
      fullAddress: 'Stephansplatz 1, Vienna',
    );

    test('pricing preview contains pricing inputs only', () {
      const request = FoodPricePreviewRequest(
        restaurantId: 15,
        pickupAddressData: address,
        dropoffAddressData: address,
        tip: '1.50',
        items: [CartItem(itemId: 42, quantity: 2)],
        requestedVehicleType: VehicleType.bike,
        requestedDeliveryType: VehicleType.bike,
      );

      final json = request.toJson();

      expect(json, isNot(contains('customer_name')));
      expect(json, isNot(contains('customer_phone_number')));
      expect(json['restaurant_id'], 15);
      expect(json['tip'], '1.50');
      expect(json['items'], [
        {'item_id': 42, 'quantity': 2},
      ]);
    });

    test('checkout still includes customer identity', () {
      const request = FoodCheckoutRequest(
        restaurantId: 15,
        subtotalAmount: '18.00',
        deliveryFee: '3.00',
        totalAmount: '21.00',
        customerName: 'Test Customer',
        customerPhoneNumber: '+4390002',
        dropoffAddressData: address,
        items: [CartItem(itemId: 42, quantity: 2)],
      );

      final json = request.toJson();

      expect(json['customer_name'], 'Test Customer');
      expect(json['customer_phone_number'], '+4390002');
    });
  });
}
