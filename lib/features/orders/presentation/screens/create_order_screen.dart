import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/dialogs/unsaved_changes_dialog.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../menu/application/menu_notifier.dart';
import '../../../tour/utils/tour_keys.dart';
import '../../../menu/data/models/menu_item_model.dart' as menu;
import '../../../coupons/application/coupons_notifier.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/customer_orders_notifier.dart';
import '../../application/orders_notifier.dart';
import '../../data/models/food_checkout_model.dart';
import '../../data/models/order_model.dart';
import '../../data/models/scanned_order_data.dart';
import '../widgets/address_search_widget.dart';
import 'scan_order_screen.dart';

/// Create order screen with all required fields
class CreateOrderScreen extends ConsumerStatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  ConsumerState<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends ConsumerState<CreateOrderScreen>
    with UnsavedChangesMixin {
  final _formKey = GlobalKey<FormState>();
  final _customerNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deliveryFeeController = TextEditingController(text: '3.99');
  final _tipsController = TextEditingController(text: '0.00');

  AddressModel? _selectedAddress;
  final List<OrderItemModel> _orderItems = [];
  bool _isPaid = false;
  bool _isLoading = false;

  // New fields for coupon and vehicle/delivery types
  String? _selectedCouponId;
  VehicleType? _selectedVehicleType = VehicleType.bike;

  @override
  void initState() {
    super.initState();
    _setupChangeListeners();
  }

  void _setupChangeListeners() {
    _customerNameController.addListener(markAsChanged);
    _phoneController.addListener(markAsChanged);
    _deliveryFeeController.addListener(markAsChanged);
    _tipsController.addListener(markAsChanged);
  }

  @override
  void dispose() {
    _customerNameController.dispose();
    _phoneController.dispose();
    _deliveryFeeController.dispose();
    _tipsController.dispose();
    super.dispose();
  }

  double get _subtotal {
    return _orderItems.fold(0.0, (sum, item) {
      final customizationTotal = item.customizations.fold<double>(
        0.0,
        (cSum, c) => cSum + c.priceModifier,
      );
      return sum + ((item.unitPrice + customizationTotal) * item.quantity);
    });
  }

  double get _deliveryFee =>
      double.tryParse(_deliveryFeeController.text) ?? 0.0;
  double get _tips => double.tryParse(_tipsController.text) ?? 0.0;

  /// Get the discount amount based on selected coupon
  double get _discount {
    if (_selectedCouponId == null) return 0.0;
    final coupons = ref.read(activeCouponsProvider);
    try {
      final coupon = coupons.firstWhere((c) => c.id == _selectedCouponId);
      // Check if order meets minimum requirement
      if (_subtotal < coupon.minimumOrderPrice) return 0.0;
      return _subtotal * (coupon.percentDiscount / 100);
    } catch (_) {
      return 0.0;
    }
  }

  double get _total => _subtotal + _deliveryFee + _tips - _discount;

  void _showAddItemDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddItemBottomSheet(
        onItemAdded: (item) {
          setState(() {
            _orderItems.add(item);
          });
          markAsChanged();
        },
      ),
    );
  }

  void _removeItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
    markAsChanged();
  }

  void _updateItemQuantity(int index, int delta) {
    setState(() {
      final item = _orderItems[index];
      final newQty = item.quantity + delta;
      if (newQty > 0) {
        _orderItems[index] = item.copyWith(quantity: newQty);
      } else {
        _orderItems.removeAt(index);
      }
    });
    markAsChanged();
  }

  void _updateItemNotes(int index, String? notes) {
    setState(() {
      final item = _orderItems[index];
      _orderItems[index] = item.copyWith(notes: notes);
    });
    markAsChanged();
  }

  /// Fill form with scanned data from AI scan
  Future<void> _fillWithScannedData(ScannedOrderData scannedData) async {
    debugPrint('[ScanFill] ===== _fillWithScannedData START =====');
    debugPrint('[ScanFill] Customer: ${scannedData.customerName}');
    debugPrint('[ScanFill] Phone: ${scannedData.phone}');
    debugPrint('[ScanFill] Address: ${scannedData.address}');

    // Get menu items for matching
    final menuState = ref.read(menuProvider);
    final menuItems = menuState.items;

    // Track items not found in menu
    final List<String> itemsNotInMenu = [];

    // First, fill basic fields synchronously
    setState(() {
      // Fill customer name
      if (scannedData.customerName != null) {
        _customerNameController.text = scannedData.customerName!;
      }

      // Fill phone number (with country code if present)
      if (scannedData.phone != null) {
        String phone = scannedData.phone!;
        // If country code is provided, prepend it to the phone
        if (scannedData.countryCode != null) {
          phone = '${scannedData.countryCode}$phone';
        }
        _phoneController.text = phone;
      }

      // Fill order items - match with menu
      if (scannedData.items.isNotEmpty) {
        _orderItems.clear();
        for (final item in scannedData.items) {
          // Try to find matching menu item by name (case insensitive)
          final matchedMenuItem = menuItems.where((m) {
            final scannedName = item.name.toLowerCase().trim();
            final menuName = m.name.toLowerCase().trim();
            // Check for exact match or if one contains the other
            return menuName == scannedName ||
                menuName.contains(scannedName) ||
                scannedName.contains(menuName);
          }).firstOrNull;

          if (matchedMenuItem != null) {
            // Found in menu - use menu item details
            _orderItems.add(
              OrderItemModel(
                id: const Uuid().v4(),
                menuItemId: matchedMenuItem.id,
                name: matchedMenuItem.name,
                quantity: item.quantity,
                unitPrice: matchedMenuItem.price,
                notes: item.notes,
              ),
            );
          } else {
            // Not found in menu - skip it (don't add)
            itemsNotInMenu.add(item.name);
          }
        }
      }

      // Fill payment status - check for online payment
      if (scannedData.isPaid != null) {
        _isPaid = scannedData.isPaid!;
      }
      // Also check notes for online payment indicators
      if (scannedData.notes != null) {
        final notesLower = scannedData.notes!.toLowerCase();
        if (notesLower.contains('online') ||
            notesLower.contains('betaald') ||
            notesLower.contains('paid') ||
            notesLower.contains('ideal') ||
            notesLower.contains('card') ||
            notesLower.contains('kaart')) {
          _isPaid = true;
        }
      }
    });

    // Pass the scanned address to AddressSearchWidget
    // The widget will detect this change via didUpdateWidget and trigger Google Places search
    if (scannedData.address != null) {
      final address = scannedData.address!;

      debugPrint('[ScanFill] Setting address for widget search:');
      debugPrint('[ScanFill]   street: "${address.street}"');
      debugPrint('[ScanFill]   building: "${address.building}"');
      debugPrint('[ScanFill]   postalCode: "${address.postalCode}"');
      debugPrint('[ScanFill]   city: "${address.city}"');

      // Set the address - AddressSearchWidget will detect this change
      // and automatically trigger a Google Places search in the search field
      setState(() {
        _selectedAddress = address;
      });
    } else {
      debugPrint('[ScanFill] No address in scanned data!');
    }

    debugPrint('[ScanFill] ===== _fillWithScannedData END =====');

    // Show appropriate message
    if (!mounted) return;

    if (itemsNotInMenu.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'orders.scan.itemsNotInMenuWarning'.trParams({
              'count': itemsNotInMenu.length.toString(),
              'items': itemsNotInMenu.join(', '),
            }),
          ),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 5),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('orders.verify.aiScanComplete'.tr),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  bool _validateForm() {
    if (!_formKey.currentState!.validate()) return false;

    if (_selectedAddress == null ||
        _selectedAddress!.street.isEmpty ||
        _selectedAddress!.building.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('validation.enterStreetAndBuilding'.tr),
          backgroundColor: Colors.orange,
        ),
      );
      return false;
    }

    // Items are optional - no validation required for empty items list

    return true;
  }

  Future<void> _submitOrder() async {
    if (!_validateForm()) return;

    // Get the selected restaurant
    final restaurant = ref.read(selectedRestaurantProvider);
    if (restaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('validation.noRestaurantSelected'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Build cart items from order items
      final cartItems = _orderItems.map((item) {
        final itemId = int.tryParse(item.menuItemId) ?? 0;
        return CartItem(
          itemId: itemId,
          quantity: item.quantity,
          customizations: item.notes,
        );
      }).toList();

      // Build the checkout request with embedded address data
      final request = FoodCheckoutRequest(
        restaurantId: int.tryParse(restaurant.id) ?? 0,
        subtotalAmount: _subtotal.toStringAsFixed(2),
        discountAmount: _discount > 0 ? _discount.toStringAsFixed(2) : null,
        deliveryFee: _deliveryFee.toStringAsFixed(2),
        tip: _tips > 0 ? _tips.toStringAsFixed(2) : null,
        totalAmount: _total.toStringAsFixed(2),
        isManual: true,
        isPaid: _isPaid,
        requestedVehicleType: _selectedVehicleType,
        requestedDeliveryType: _selectedVehicleType,
        pickupAddressData: OrderAddressData.fromRestaurant(restaurant),
        dropoffAddressData: OrderAddressData.fromAddressModel(
          _selectedAddress!,
          label: 'Customer: ${_customerNameController.text.trim()}',
        ),
        items: cartItems,
        couponId: _selectedCouponId != null
            ? int.tryParse(_selectedCouponId!)
            : null,
        notes:
            'Customer: ${_customerNameController.text.trim()}, '
            'Phone: ${_phoneController.text.trim()}',
      );

      // Create the order
      final notifier = ref.read(customerOrdersProvider.notifier);
      final createdOrder = await notifier.createFoodOrder(request);

      if (!mounted) return;

      setState(() => _isLoading = false);

      if (createdOrder != null) {
        // Refresh the orders list so the new order appears immediately
        ref.read(ordersProvider.notifier).refreshOrders();

        markAsSaved();
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('orders.orderCreated'.tr),
            backgroundColor: AppColors.success,
          ),
        );
      } else {
        final error = ref.read(customerOrdersProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'orders.orderCreationFailed'.tr),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('orders.orderCreationFailed'.tr),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return buildWithUnsavedChangesGuard(
      child: AppScaffold(
        appBar: AppAppBar(
          title: 'orders.createOrder'.tr,
          actions: [
            IconButton(
              icon: const Icon(Icons.document_scanner),
              tooltip: 'orders.scan.title'.tr,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ScanOrderScreen(onDataScanned: _fillWithScannedData),
                  ),
                );
              },
            ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Prominent Scan Card
                KeyedSubtree(
                  key: TourKeys.scanOrderCardKey,
                  child: _ScanOrderCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ScanOrderScreen(
                            onDataScanned: _fillWithScannedData,
                          ),
                        ),
                      );
                    },
                    isDark: isDark,
                  ),
                ),
                SizedBox(height: 24.h),

                // Customer Information Section
                _SectionTitle(title: 'orders.customerInfo'.tr, isDark: isDark),
                SizedBox(height: 12.h),

                // Customer Name
                AppTextField(
                  controller: _customerNameController,
                  label: 'orders.customerName'.tr,
                  hint: 'validation.enterCustomerName'.tr,
                  prefixIcon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.enterCustomerName'.tr;
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12.h),

                // Phone Number with Country Code
                Text(
                  'orders.phone'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'validation.phoneRequired'.tr;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: 'auth.phoneNumber'.tr,
                    prefixIcon: Icon(Icons.phone, size: 20.w),
                    filled: true,
                    fillColor: isDark
                        ? DarkColors.inputBackground
                        : LightColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: isDark ? DarkColors.border : LightColors.border,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: isDark ? DarkColors.border : LightColors.border,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: const BorderSide(color: AppColors.error),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 14.h,
                    ),
                  ),
                ),

                SizedBox(height: 24.h),

                // Delivery Address Section
                _SectionTitle(
                  title: 'orders.deliveryAddress'.tr,
                  isDark: isDark,
                ),
                SizedBox(height: 4.h),
                Text(
                  'address.enterManually'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
                SizedBox(height: 12.h),

                AddressSearchWidget(
                  initialAddress: _selectedAddress,
                  onAddressSelected: (address) {
                    setState(() {
                      _selectedAddress = address;
                    });
                    markAsChanged();
                  },
                ),

                SizedBox(height: 24.h),

                // Order Items Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _SectionTitle(
                      title: 'orders.orderItems'.tr,
                      isDark: isDark,
                    ),
                    TextButton.icon(
                      onPressed: _showAddItemDialog,
                      icon: Icon(Icons.add, size: 18.w),
                      label: Text('orders.addItem'.tr),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                if (_orderItems.isEmpty)
                  _EmptyItemsCard(isDark: isDark, onAddItem: _showAddItemDialog)
                else
                  ...List.generate(_orderItems.length, (index) {
                    final item = _orderItems[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _OrderItemCard(
                        item: item,
                        onRemove: () => _removeItem(index),
                        onQuantityChanged: (delta) =>
                            _updateItemQuantity(index, delta),
                        onNotesChanged: (notes) =>
                            _updateItemNotes(index, notes),
                        isDark: isDark,
                      ),
                    );
                  }),

                SizedBox(height: 24.h),

                // Delivery Options Section
                _SectionTitle(
                  title: 'orders.deliveryOptions'.tr,
                  isDark: isDark,
                ),
                SizedBox(height: 12.h),

                // Vehicle Type dropdown
                _VehicleTypeDropdown(
                  label: 'orders.requestedVehicleType'.tr,
                  value: _selectedVehicleType,
                  onChanged: (value) {
                    setState(() {
                      _selectedVehicleType = value;
                    });
                    markAsChanged();
                  },
                  isDark: isDark,
                ),

                SizedBox(height: 24.h),

                // Coupon Section
                _SectionTitle(title: 'orders.coupon'.tr, isDark: isDark),
                SizedBox(height: 12.h),

                _CouponDropdown(
                  key: ValueKey('coupon_dropdown_$_subtotal'),
                  selectedCouponId: _selectedCouponId,
                  subtotal: _subtotal,
                  onChanged: (value) {
                    setState(() {
                      _selectedCouponId = value;
                    });
                    markAsChanged();
                  },
                  isDark: isDark,
                ),

                SizedBox(height: 24.h),

                // Payment Section
                _SectionTitle(title: 'orders.payment'.tr, isDark: isDark),
                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: AppTextField(
                        controller: _deliveryFeeController,
                        label: 'orders.deliveryFee'.tr,
                        hint: '0.00',
                        prefixIcon: Icons.delivery_dining,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: AppTextField(
                        controller: _tipsController,
                        label: 'orders.tips'.tr,
                        hint: '0.00',
                        prefixIcon: Icons.volunteer_activism,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16.h),

                // Paid checkbox
                AppCard(
                  child: CheckboxListTile(
                    value: _isPaid,
                    onChanged: (value) {
                      setState(() {
                        _isPaid = value ?? false;
                      });
                      markAsChanged();
                    },
                    title: Text(
                      'orders.isPaid'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    subtitle: Text(
                      _isPaid
                          ? 'orders.paymentReceived'.tr
                          : 'orders.paymentPending'.tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: _isPaid ? AppColors.success : AppColors.warning,
                      ),
                    ),
                    secondary: Icon(
                      _isPaid ? Icons.check_circle : Icons.pending,
                      color: _isPaid ? AppColors.success : AppColors.warning,
                    ),
                    controlAffinity: ListTileControlAffinity.trailing,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),

                SizedBox(height: 24.h),

                // Order Summary
                _SectionTitle(title: 'orders.orderSummary'.tr, isDark: isDark),
                SizedBox(height: 12.h),

                AppCard(
                  child: Column(
                    children: [
                      _SummaryRow(
                        label: 'orders.subtotal'.tr,
                        value: _subtotal,
                        isDark: isDark,
                      ),
                      SizedBox(height: 8.h),
                      _SummaryRow(
                        label: 'orders.deliveryFee'.tr,
                        value: _deliveryFee,
                        isDark: isDark,
                      ),
                      SizedBox(height: 8.h),
                      _SummaryRow(
                        label: 'orders.tips'.tr,
                        value: _tips,
                        isDark: isDark,
                      ),
                      // Show discount row if coupon is applied
                      if (_discount > 0) ...[
                        SizedBox(height: 8.h),
                        _DiscountRow(
                          label: 'orders.discount'.tr,
                          value: _discount,
                          isDark: isDark,
                        ),
                      ],
                      Divider(
                        height: 24.h,
                        color: isDark ? DarkColors.border : LightColors.border,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'orders.total'.tr,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                          Text(
                            '\u20AC${_total.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 24.h),

                // Submit Button
                AppButton(
                  label: 'orders.createOrder'.tr,
                  onPressed: _submitOrder,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.isDark});

  final String title;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w600,
        color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
      ),
    );
  }
}

/// Dropdown for selecting vehicle type
class _VehicleTypeDropdown extends StatelessWidget {
  const _VehicleTypeDropdown({
    required this.label,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final String label;
  final VehicleType? value;
  final ValueChanged<VehicleType?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          decoration: BoxDecoration(
            color: isDark ? DarkColors.surface : LightColors.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isDark ? DarkColors.border : LightColors.border,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<VehicleType>(
              value: value,
              isExpanded: true,
              hint: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                child: Text(
                  'orders.selectVehicleType'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              borderRadius: BorderRadius.circular(12.r),
              dropdownColor: isDark ? DarkColors.surface : LightColors.surface,
              items: [VehicleType.bike, VehicleType.car].map((type) {
                return DropdownMenuItem<VehicleType>(
                  value: type,
                  child: Row(
                    children: [
                      Icon(
                        _getVehicleIcon(type),
                        size: 20.w,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'orders.vehicleType.${type.name}'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getVehicleIcon(VehicleType type) {
    switch (type) {
      case VehicleType.bike:
        return Icons.pedal_bike;
      case VehicleType.motorcycle:
        return Icons.two_wheeler;
      case VehicleType.car:
        return Icons.directions_car;
      case VehicleType.van:
        return Icons.airport_shuttle;
    }
  }
}

/// Prominent card for scanning orders with AI
class _ScanOrderCard extends StatelessWidget {
  const _ScanOrderCard({required this.onTap, required this.isDark});

  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.document_scanner_rounded,
                color: Colors.white,
                size: 32.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'orders.scan.cardTitle'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'orders.scan.cardDescription'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withValues(alpha: 0.8),
              size: 20.w,
            ),
          ],
        ),
      ),
    );
  }
}

/// Dropdown for selecting coupon
class _CouponDropdown extends ConsumerWidget {
  const _CouponDropdown({
    super.key,
    required this.selectedCouponId,
    required this.subtotal,
    required this.onChanged,
    required this.isDark,
  });

  final String? selectedCouponId;
  final double subtotal;
  final ValueChanged<String?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allCoupons = ref.watch(activeCouponsProvider);
    // Filter coupons to only show those applicable to the current subtotal
    final coupons = allCoupons
        .where((coupon) => coupon.minimumOrderPrice <= subtotal)
        .toList();
    final isLoading = ref.watch(couponsProvider).isLoading;

    // If selected coupon is no longer applicable, treat as no selection
    final effectiveSelectedId =
        selectedCouponId != null && coupons.any((c) => c.id == selectedCouponId)
        ? selectedCouponId
        : null;

    if (isLoading) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20.w,
              height: 20.w,
              child: CircularProgressIndicator(strokeWidth: 2.w),
            ),
            SizedBox(width: 12.w),
            Text(
              'orders.loadingCoupons'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (coupons.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.discount_outlined,
              size: 20.w,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
            SizedBox(width: 12.w),
            Text(
              'orders.noActiveCoupons'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: effectiveSelectedId,
          isExpanded: true,
          hint: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Row(
              children: [
                Icon(
                  Icons.discount_outlined,
                  size: 20.w,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'orders.selectCoupon'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.w),
          borderRadius: BorderRadius.circular(12.r),
          dropdownColor: isDark ? DarkColors.surface : LightColors.surface,
          items: [
            // Add "No coupon" option
            DropdownMenuItem<String>(
              value: null,
              child: Row(
                children: [
                  Icon(
                    Icons.close,
                    size: 20.w,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'orders.noCoupon'.tr,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            ...coupons.map((coupon) {
              return DropdownMenuItem<String>(
                value: coupon.id,
                child: Row(
                  children: [
                    Icon(
                      Icons.local_offer,
                      size: 20.w,
                      color: AppColors.success,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            coupon.code,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                          Text(
                            '${coupon.percentDiscount.toStringAsFixed(0)}% off',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: AppColors.success,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
        Text(
          '\u20AC${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Discount row for order summary (shows negative value in green)
class _DiscountRow extends StatelessWidget {
  const _DiscountRow({
    required this.label,
    required this.value,
    required this.isDark,
  });

  final String label;
  final double value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.local_offer, size: 16.w, color: AppColors.success),
            SizedBox(width: 4.w),
            Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: AppColors.success),
            ),
          ],
        ),
        Text(
          '-\u20AC${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.success,
          ),
        ),
      ],
    );
  }
}

class _EmptyItemsCard extends StatelessWidget {
  const _EmptyItemsCard({required this.isDark, required this.onAddItem});

  final bool isDark;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            children: [
              Icon(
                Icons.shopping_basket_outlined,
                size: 48.w,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
              SizedBox(height: 12.h),
              Text(
                'createOrder.noItemsAddedYet'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              SizedBox(height: 12.h),
              AppButton(
                label: 'createOrder.addItem'.tr,
                size: AppButtonSize.small,
                isFullWidth: false,
                onPressed: onAddItem,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderItemCard extends StatefulWidget {
  const _OrderItemCard({
    required this.item,
    required this.onRemove,
    required this.onQuantityChanged,
    required this.onNotesChanged,
    required this.isDark,
  });

  final OrderItemModel item;
  final VoidCallback onRemove;
  final ValueChanged<int> onQuantityChanged;
  final ValueChanged<String?> onNotesChanged;
  final bool isDark;

  @override
  State<_OrderItemCard> createState() => _OrderItemCardState();
}

class _OrderItemCardState extends State<_OrderItemCard> {
  late final TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.item.notes ?? '');
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final isDark = widget.isDark;
    final itemTotal =
        (item.unitPrice +
            item.customizations.fold<double>(
              0.0,
              (sum, c) => sum + c.priceModifier,
            )) *
        item.quantity;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '\u20AC${itemTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20.w,
                ),
                onPressed: widget.onRemove,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 32.w),
              ),
            ],
          ),
          // Display notes/customizations if present
          if (item.notes != null && item.notes!.isNotEmpty) ...[
            SizedBox(height: 4.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.note_alt_outlined,
                    size: 14.w,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      item.notes!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),
          // Notes text field
          TextField(
            controller: _notesController,
            maxLines: 2,
            style: TextStyle(fontSize: 12.sp),
            decoration: InputDecoration(
              hintText: 'orders.itemCustomizationsHint'.tr,
              hintStyle: TextStyle(
                fontSize: 12.sp,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
              prefixIcon: Icon(Icons.edit_note, size: 18.w),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 8.w,
                vertical: 8.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: isDark ? DarkColors.border : LightColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
                borderSide: BorderSide(
                  color: isDark ? DarkColors.border : LightColors.border,
                ),
              ),
            ),
            onChanged: (value) =>
                widget.onNotesChanged(value.isNotEmpty ? value : null),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Text(
                '\u20AC${item.unitPrice.toStringAsFixed(2)} each',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? DarkColors.backgroundSecondary
                      : LightColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove, size: 18.w),
                      onPressed: () => widget.onQuantityChanged(-1),
                      padding: EdgeInsets.all(4.w),
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.h,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text(
                        '${item.quantity}',
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
                      icon: Icon(Icons.add, size: 18.w),
                      onPressed: () => widget.onQuantityChanged(1),
                      padding: EdgeInsets.all(4.w),
                      constraints: BoxConstraints(
                        minWidth: 32.w,
                        minHeight: 32.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet for selecting items from menu
class _AddItemBottomSheet extends ConsumerStatefulWidget {
  const _AddItemBottomSheet({required this.onItemAdded});

  final ValueChanged<OrderItemModel> onItemAdded;

  @override
  ConsumerState<_AddItemBottomSheet> createState() =>
      _AddItemBottomSheetState();
}

class _AddItemBottomSheetState extends ConsumerState<_AddItemBottomSheet> {
  final _searchController = TextEditingController();
  final _notesController = TextEditingController();
  String? _selectedCategoryId;
  menu.MenuItemModel? _selectedItem;
  int _quantity = 1;

  @override
  void dispose() {
    _searchController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addItem() {
    if (_selectedItem == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('orders.selectItemFromMenu'.tr)));
      return;
    }

    final item = OrderItemModel(
      id: const Uuid().v4(),
      menuItemId: _selectedItem!.id,
      name: _selectedItem!.name,
      quantity: _quantity,
      unitPrice: _selectedItem!.price,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
    );

    widget.onItemAdded(item);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;

    // Filter items based on search and category
    List<menu.MenuItemModel> filteredItems = menuState.items
        .where((item) => item.isAvailable)
        .toList();

    if (_selectedCategoryId != null) {
      filteredItems = filteredItems
          .where((item) => item.categoryId == _selectedCategoryId)
          .toList();
    }

    final searchQuery = _searchController.text.toLowerCase();
    if (searchQuery.isNotEmpty) {
      filteredItems = filteredItems
          .where(
            (item) =>
                item.name.toLowerCase().contains(searchQuery) ||
                (item.description?.toLowerCase().contains(searchQuery) ??
                    false),
          )
          .toList();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isDark ? DarkColors.border : LightColors.border,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Text(
                      'orders.addItem'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    const Spacer(),
                    if (_selectedItem != null)
                      TextButton(
                        onPressed: () => setState(() {
                          _selectedItem = null;
                          _quantity = 1;
                        }),
                        child: Text('common.clear'.tr),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Search bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'common.search'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          SizedBox(height: 12.h),

          // Category chips
          SizedBox(
            height: 40.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: categories.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: FilterChip(
                      label: Text('menu.allCategories'.tr),
                      selected: _selectedCategoryId == null,
                      onSelected: (_) =>
                          setState(() => _selectedCategoryId = null),
                    ),
                  );
                }
                final category = categories[index - 1];
                return Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: FilterChip(
                    label: Text(category.name),
                    selected: _selectedCategoryId == category.id,
                    onSelected: (_) =>
                        setState(() => _selectedCategoryId = category.id),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),

          // Menu items list or selected item details
          Expanded(
            child: _selectedItem == null
                ? _buildMenuItemsList(filteredItems, isDark)
                : _buildSelectedItemDetails(isDark),
          ),

          // Add button
          if (_selectedItem != null)
            SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: AppButton(
                  label: 'createOrder.addToOrderWithPrice'.tr.replaceAll(
                    '{price}',
                    '€${(_selectedItem!.price * _quantity).toStringAsFixed(2)}',
                  ),
                  onPressed: _addItem,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItemsList(List<menu.MenuItemModel> items, bool isDark) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64.w,
              color: isDark
                  ? DarkColors.textTertiary
                  : LightColors.textTertiary,
            ),
            SizedBox(height: 16.h),
            Text(
              'createOrder.noMenuItemsFound'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return _MenuItemTile(
          item: item,
          isDark: isDark,
          onTap: () => setState(() {
            _selectedItem = item;
            _quantity = 1;
          }),
        );
      },
    );
  }

  Widget _buildSelectedItemDetails(bool isDark) {
    final item = _selectedItem!;

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Item info card
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark
                  ? DarkColors.backgroundSecondary
                  : LightColors.backgroundSecondary,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.primary.withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                if (item.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      item.imageUrl!,
                      width: 60.w,
                      height: 60.w,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 60.w,
                        height: 60.w,
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          Icons.restaurant,
                          color: Theme.of(context).colorScheme.primary,
                          size: 30.w,
                        ),
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60.w,
                    height: 60.w,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: Theme.of(context).colorScheme.primary,
                      size: 30.w,
                    ),
                  ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                      if (item.description != null) ...[
                        SizedBox(height: 4.h),
                        Text(
                          item.description!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      SizedBox(height: 4.h),
                      Text(
                        '€${item.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Quantity selector
          Row(
            children: [
              Text(
                'Quantity',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? DarkColors.textPrimary
                      : LightColors.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? DarkColors.backgroundSecondary
                      : LightColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.remove),
                      onPressed: () {
                        if (_quantity > 1) {
                          setState(() => _quantity--);
                        }
                      },
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        '$_quantity',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        setState(() => _quantity++);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Customization notes field
          Text(
            'orders.itemCustomizations'.tr,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'orders.itemCustomizationsHint'.tr,
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.all(12.w),
            ),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

/// Menu item tile widget
class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.item,
    required this.isDark,
    required this.onTap,
  });

  final menu.MenuItemModel item;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 8.h),
      child: ListTile(
        onTap: onTap,
        leading: item.imageUrl != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  item.imageUrl!,
                  width: 50.w,
                  height: 50.w,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.restaurant,
                      color: Theme.of(context).colorScheme.primary,
                      size: 24.w,
                    ),
                  ),
                ),
              )
            : Container(
                width: 50.w,
                height: 50.w,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.restaurant,
                  color: Theme.of(context).colorScheme.primary,
                  size: 24.w,
                ),
              ),
        title: Text(
          item.name,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
        ),
        subtitle: Text(
          item.description ?? '',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12.sp,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
        trailing: Text(
          '€${item.price.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
