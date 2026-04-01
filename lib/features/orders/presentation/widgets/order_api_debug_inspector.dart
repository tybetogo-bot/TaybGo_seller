import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/config/env_config.dart';
import '../../../../core/providers/providers.dart';
import '../../../../core/theme/theme.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/order_model.dart';

const bool _hideOrderApiDebugTools = true;

bool get showOrderApiDebugTools =>
    !_hideOrderApiDebugTools && (kDebugMode || EnvConfig.isDev);

Future<void> showOrderApiDebugInspector({
  required BuildContext context,
  required WidgetRef ref,
  required OrderModel order,
}) async {
  final ordersState = ref.read(ordersProvider);
  final ordersApi = ref.read(ordersApiProvider);
  final rawOrdersResponse = await ordersApi.getRawOrders(
    page: ordersState.currentPage,
  );
  final rawListOrder = _extractOrderFromRawList(rawOrdersResponse, order.id);
  final rawDetailOrder = await ordersApi.getRawOrderById(order.id);

  if (!context.mounted) return;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _OrderApiDebugSheet(
      orderId: order.id,
      parsedOrder: _buildParsedOrderSnapshot(order),
      rawListMeta: _buildRawListMeta(
        rawOrdersResponse: rawOrdersResponse,
        page: ordersState.currentPage,
        matchedOrderFound: rawListOrder != null,
      ),
      rawListOrder: rawListOrder,
      rawDetailOrder: rawDetailOrder,
    ),
  );
}

Map<String, dynamic>? _extractOrderFromRawList(
  Map<String, dynamic> rawOrdersResponse,
  String orderId,
) {
  final results = rawOrdersResponse['results'];
  if (results is! List) return null;

  for (final item in results) {
    if (item is Map && item['id']?.toString() == orderId) {
      return Map<String, dynamic>.from(item);
    }
  }

  return null;
}

Map<String, dynamic> _buildRawListMeta({
  required Map<String, dynamic> rawOrdersResponse,
  required int page,
  required bool matchedOrderFound,
}) {
  final results = rawOrdersResponse['results'];
  return {
    'endpoint': 'GET /api/orders/?page=$page',
    'requestedPage': page,
    'count': rawOrdersResponse['count'],
    'next': rawOrdersResponse['next'],
    'previous': rawOrdersResponse['previous'],
    'resultsCount': results is List ? results.length : null,
    'matchedOrderFound': matchedOrderFound,
  };
}

Map<String, dynamic> _buildParsedOrderSnapshot(OrderModel order) {
  return {
    'id': order.id,
    'customerName': order.customerName,
    'phoneNumber': order.phoneNumber,
    'countryCode': order.countryCode,
    'formattedPhone': order.formattedPhone,
    'status': order.status.name,
    'statusDisplayName': order.status.displayName,
    'orderType': order.orderType,
    'isPaid': order.isPaid,
    'isManual': order.isManual,
    'subtotal': order.subtotal,
    'deliveryFee': order.deliveryFee,
    'discountAmount': order.discountAmount,
    'tips': order.tips,
    'total': order.total,
    'createdAt': order.createdAt.toIso8601String(),
    'acceptedAt': order.acceptedAt?.toIso8601String(),
    'readyAt': order.readyAt?.toIso8601String(),
    'outForDeliveryAt': order.outForDeliveryAt?.toIso8601String(),
    'deliveredAt': order.deliveredAt?.toIso8601String(),
    'notes': order.notes,
    'rejectionReason': order.rejectionReason,
    'restaurantId': order.restaurantId,
    'assignedDriverId': order.assignedDriverId,
    'requestedVehicleType': order.requestedVehicleType,
    'requestedDeliveryType': order.requestedDeliveryType,
    'fullAddress': order.fullAddress,
    'address': _buildLegacyAddressSnapshot(order.address),
    'pickupAddress': _buildOrderAddressSnapshot(order.pickupAddress),
    'dropoffAddress': _buildOrderAddressSnapshot(order.dropoffAddress),
    'restaurant': _buildRestaurantSnapshot(order.restaurant),
    'coupon': _buildCouponSnapshot(order.coupon),
    'driver': _buildDriverSnapshot(order.driver),
    'items': order.items.map(_buildItemSnapshot).toList(),
  };
}

Map<String, dynamic> _buildLegacyAddressSnapshot(AddressModel address) {
  return {
    'street': address.street,
    'building': address.building,
    'apartment': address.apartment,
    'floor': address.floor,
    'city': address.city,
    'postalCode': address.postalCode,
    'country': address.country,
    'placeId': address.placeId,
    'latitude': address.latitude,
    'longitude': address.longitude,
    'additionalInfo': address.additionalInfo,
  };
}

Map<String, dynamic>? _buildOrderAddressSnapshot(OrderAddressModel? address) {
  if (address == null) return null;
  return {
    'id': address.id,
    'label': address.label,
    'lat': address.lat,
    'lng': address.lng,
    'fullAddress': address.fullAddress,
    'streetName': address.streetName,
    'houseNumber': address.houseNumber,
    'city': address.city,
    'postalCode': address.postalCode,
    'country': address.country,
    'createdAt': address.createdAt?.toIso8601String(),
    'displayAddress': address.displayAddress,
  };
}

Map<String, dynamic>? _buildRestaurantSnapshot(
  OrderRestaurantModel? restaurant,
) {
  if (restaurant == null) return null;
  return {
    'id': restaurant.id,
    'name': restaurant.name,
    'logo': restaurant.logo,
    'phone': restaurant.phone,
    'status': restaurant.status,
    'lat': restaurant.lat,
    'lng': restaurant.lng,
    'createdAt': restaurant.createdAt?.toIso8601String(),
    'address': restaurant.address,
    'addressObject': _buildOrderAddressSnapshot(restaurant.addressObject),
  };
}

Map<String, dynamic>? _buildCouponSnapshot(OrderCouponModel? coupon) {
  if (coupon == null) return null;
  return {
    'id': coupon.id,
    'restaurantId': coupon.restaurantId,
    'title': coupon.title,
    'description': coupon.description,
    'code': coupon.code,
    'percentage': coupon.percentage,
    'minPrice': coupon.minPrice,
    'maxTotalUsers': coupon.maxTotalUsers,
    'maxPerCustomer': coupon.maxPerCustomer,
    'startDate': coupon.startDate?.toIso8601String(),
    'endDate': coupon.endDate?.toIso8601String(),
    'isActive': coupon.isActive,
    'createdAt': coupon.createdAt?.toIso8601String(),
  };
}

Map<String, dynamic>? _buildDriverSnapshot(OrderDriverModel? driver) {
  if (driver == null) return null;
  return {
    'id': driver.id,
    'email': driver.email,
    'name': driver.name,
    'phone': driver.phone,
    'age': driver.age,
    'isVerified': driver.isVerified,
    'createdAt': driver.createdAt?.toIso8601String(),
    'roles': driver.roles,
  };
}

Map<String, dynamic> _buildItemSnapshot(OrderItemModel item) {
  return {
    'id': item.id,
    'menuItemId': item.menuItemId,
    'name': item.name,
    'quantity': item.quantity,
    'unitPrice': item.unitPrice,
    'totalPrice': item.totalPrice,
    'notes': item.notes,
    'customizationsText': item.customizationsText,
    'customizations': item.customizations
        .map(
          (customization) => {
            'id': customization.id,
            'name': customization.name,
            'type': customization.type.name,
            'priceModifier': customization.priceModifier,
          },
        )
        .toList(),
  };
}

class _OrderApiDebugSheet extends StatelessWidget {
  const _OrderApiDebugSheet({
    required this.orderId,
    required this.parsedOrder,
    required this.rawListMeta,
    required this.rawListOrder,
    required this.rawDetailOrder,
  });

  final String orderId;
  final Map<String, dynamic> parsedOrder;
  final Map<String, dynamic> rawListMeta;
  final Map<String, dynamic>? rawListOrder;
  final Map<String, dynamic> rawDetailOrder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FractionallySizedBox(
      heightFactor: 0.92,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? DarkColors.background : LightColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 44.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isDark ? DarkColors.border : LightColors.border,
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 8.w, 12.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'API Debug Data',
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Order #$orderId',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 24.h),
                children: [
                  Text(
                    'Compare the parsed order with the raw list and detail payloads from the seller orders API.',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _DebugJsonSection(
                    title: 'Parsed OrderModel Snapshot',
                    payload: parsedOrder,
                    isDark: isDark,
                  ),
                  SizedBox(height: 12.h),
                  _DebugJsonSection(
                    title: 'GET /api/orders/ Metadata',
                    payload: rawListMeta,
                    isDark: isDark,
                  ),
                  SizedBox(height: 12.h),
                  _DebugJsonSection(
                    title: 'GET /api/orders/ Matched Item',
                    payload:
                        rawListOrder ??
                        {
                          'message':
                              'Order not found in the currently loaded orders page.',
                        },
                    isDark: isDark,
                  ),
                  SizedBox(height: 12.h),
                  _DebugJsonSection(
                    title: 'GET /api/orders/{id}/ Raw Detail',
                    payload: rawDetailOrder,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebugJsonSection extends StatelessWidget {
  const _DebugJsonSection({
    required this.title,
    required this.payload,
    required this.isDark,
  });

  final String title;
  final Object? payload;
  final bool isDark;

  String _formatPayload() {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(payload);
  }

  void _copyPayload(BuildContext context, String jsonText) {
    Clipboard.setData(ClipboardData(text: jsonText));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$title copied'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jsonText = _formatPayload();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 8.w, 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy JSON',
                  onPressed: () => _copyPayload(context, jsonText),
                  icon: const Icon(Icons.copy_rounded),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark
                  ? DarkColors.background
                  : LightColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: SelectableText(
              jsonText,
              style: TextStyle(
                fontSize: 11.sp,
                height: 1.45,
                fontFamily: 'monospace',
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
