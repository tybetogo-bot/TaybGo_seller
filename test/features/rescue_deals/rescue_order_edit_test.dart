import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teybatseller/core/i18n/i18n.dart';
import 'package:teybatseller/features/menu/data/models/menu_item_model.dart';
import 'package:teybatseller/features/orders/data/models/order_model.dart';
import 'package:teybatseller/features/orders/data/models/food_checkout_model.dart';
import 'package:teybatseller/features/orders/presentation/widgets/incoming_order_item_editor.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await TranslationService.instance.load(const Locale('en'));
  });
  testWidgets(
    'incoming order edits preserve regular and rescue lines for the same item',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final order = OrderModel.fromJson({
        'id': 1,
        'created_at': DateTime.now().toIso8601String(),
        'items': [
          {
            'id': 1,
            'item': 21,
            'item_name': 'Meal',
            'quantity': 1,
            'unit_price_snapshot': '10.00',
          },
          {
            'id': 2,
            'item': 21,
            'item_name': 'Meal',
            'quantity': 2,
            'unit_price_snapshot': '6.00',
            'rescue_deal_id': 12,
            'pricing_source': 'RESCUE_DEAL',
          },
        ],
      });
      List<CartItem>? result;
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (_, _) => MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    result = await showIncomingOrderItemEditor(
                      context,
                      order: order,
                      menuItems: [
                        const MenuItemModel(
                          id: '21',
                          name: 'Meal',
                          price: 10,
                          categoryId: '2',
                        ),
                      ],
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('orders.incoming.saveItems'.tr));
      await tester.pumpAndSettle();
      expect(result, hasLength(2));
      expect(result![0].toJson(), {'item_id': 21, 'quantity': 1});
      expect(result![1].toJson(), {
        'item_id': 21,
        'quantity': 2,
        'rescue_deal_id': 12,
        'expected_deal_price': '6.00',
      });
      expect(tester.takeException(), isNull);
    },
  );
}
