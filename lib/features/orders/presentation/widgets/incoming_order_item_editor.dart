import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../menu/data/models/menu_item_model.dart' hide CustomizationType;
import '../../data/models/food_checkout_model.dart';
import '../../data/models/order_model.dart';

/// Opens the item-only editor used from the incoming order experience.
///
/// Returning null means that the seller cancelled the editor. The returned
/// cart is intentionally limited to item IDs, quantities, and existing item
/// customizations so the caller cannot accidentally edit customer, address,
/// payment, or delivery fields.
Future<List<CartItem>?> showIncomingOrderItemEditor(
  BuildContext context, {
  required OrderModel order,
  required List<MenuItemModel> menuItems,
}) {
  return showModalBottomSheet<List<CartItem>>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.28),
    builder: (_) =>
        _IncomingOrderItemEditor(order: order, menuItems: menuItems),
  );
}

class _IncomingOrderItemEditor extends StatefulWidget {
  const _IncomingOrderItemEditor({
    required this.order,
    required this.menuItems,
  });

  final OrderModel order;
  final List<MenuItemModel> menuItems;

  @override
  State<_IncomingOrderItemEditor> createState() =>
      _IncomingOrderItemEditorState();
}

class _IncomingOrderItemEditorState extends State<_IncomingOrderItemEditor> {
  final TextEditingController _searchController = TextEditingController();
  final List<_EditableIncomingItem> _lines = <_EditableIncomingItem>[];
  String _searchQuery = '';
  String _currentLanguageCode = 'en';
  String? _validationError;

  @override
  void initState() {
    super.initState();
    final menuById = <String, MenuItemModel>{
      for (final item in widget.menuItems) _normalizedId(item.id): item,
    };

    for (var index = 0; index < widget.order.items.length; index++) {
      final orderItem = widget.order.items[index];
      final orderItemId = _normalizedId(orderItem.menuItemId);
      final menuItem = menuById[orderItemId];
      final itemId = int.tryParse(orderItemId);
      final key = orderItemId.isNotEmpty ? orderItemId : 'legacy-$index';
      final existing = _lines.where((line) => line.key == key).firstOrNull;

      if (existing != null) {
        existing.quantity += orderItem.quantity;
        continue;
      }

      _lines.add(
        _EditableIncomingItem(
          key: key,
          itemId: itemId,
          name: menuItem?.getLocalizedName(_languageCode) ?? orderItem.name,
          price: menuItem?.price ?? orderItem.unitPrice,
          quantity: orderItem.quantity,
          customizations: _customizationsFor(orderItem),
          isAvailable: menuItem?.isAvailable ?? false,
        ),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _currentLanguageCode = Localizations.localeOf(context).languageCode;
    final menuById = <String, MenuItemModel>{
      for (final item in widget.menuItems) _normalizedId(item.id): item,
    };
    for (final line in _lines) {
      final menuItem = menuById[line.key];
      if (menuItem != null) {
        line.name = menuItem.getLocalizedName(_languageCode);
      }
    }
  }

  String get _languageCode {
    return _currentLanguageCode;
  }

  String _normalizedId(String value) =>
      value.trim().replaceFirst(RegExp(r'^0+(?=\d)'), '');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MenuItemModel> get _filteredMenuItems {
    final query = _searchQuery.trim().toLowerCase();
    return widget.menuItems
        .where(
          (item) =>
              item.isAvailable && int.tryParse(_normalizedId(item.id)) != null,
        )
        .where((item) {
          if (query.isEmpty) return true;
          return item.name.toLowerCase().contains(query) ||
              (item.description?.toLowerCase().contains(query) ?? false);
        })
        .take(12)
        .toList();
  }

  int get _totalQuantity =>
      _lines.fold<int>(0, (total, line) => total + line.quantity);

  void _addMenuItem(MenuItemModel menuItem) {
    final menuItemKey = _normalizedId(menuItem.id);
    final itemId = int.tryParse(menuItemKey);
    if (itemId == null) return;

    final existing = _lines
        .where((line) => line.key == menuItemKey)
        .firstOrNull;
    setState(() {
      _validationError = null;
      if (existing != null) {
        existing.quantity += 1;
      } else {
        _lines.add(
          _EditableIncomingItem(
            key: menuItemKey,
            itemId: itemId,
            name: menuItem.getLocalizedName(_languageCode),
            price: menuItem.price,
            quantity: 1,
            isAvailable: menuItem.isAvailable,
          ),
        );
      }
    });
  }

  void _decreaseLine(_EditableIncomingItem line) {
    setState(() {
      _validationError = null;
      if (line.quantity <= 1) {
        _lines.remove(line);
      } else {
        line.quantity -= 1;
      }
    });
  }

  void _increaseLine(_EditableIncomingItem line) {
    setState(() {
      _validationError = null;
      line.quantity += 1;
    });
  }

  void _removeLine(_EditableIncomingItem line) {
    setState(() {
      _validationError = null;
      _lines.remove(line);
    });
  }

  void _submit() {
    final lines = _lines.where((line) => line.quantity > 0).toList();
    if (lines.isEmpty) {
      setState(() => _validationError = 'orders.emptyItemsWarning'.tr);
      return;
    }

    if (lines.any(
      (line) => line.itemId == null || line.itemId! <= 0 || !line.isAvailable,
    )) {
      setState(() => _validationError = 'orders.incoming.invalidItems'.tr);
      return;
    }

    final items = lines
        .map(
          (line) => CartItem(
            itemId: line.itemId!,
            quantity: line.quantity,
            customizations: line.customizations,
          ),
        )
        .toList(growable: false);
    Navigator.of(context).pop(items);
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final availableHeight =
        mediaQuery.size.height - mediaQuery.viewInsets.bottom;
    final sheetHeight = availableHeight.clamp(430.0, 740.0).toDouble();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textPrimary = isDark ? Colors.white : const Color(0xFF152019);
    final textSecondary = isDark
        ? Colors.white.withValues(alpha: 0.68)
        : const Color(0xFF68746D);
    final surface = isDark ? const Color(0xFF15251B) : Colors.white;
    final softSurface = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : const Color(0xFFF3F8F5);

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: double.infinity,
        height: sheetHeight,
        constraints: BoxConstraints(maxWidth: 620.w),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.34 : 0.12),
              blurRadius: 26,
              offset: const Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          children: [
            SizedBox(height: 10.h),
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: textSecondary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 10.h, 12.w, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'orders.incoming.editItemsTitle'.tr,
                          style: TextStyle(
                            color: textPrimary,
                            fontSize: 19.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 3.h),
                        Text(
                          'orders.incoming.editItemsSubtitle'.trParams({
                            'id': widget.order.id,
                          }),
                          style: TextStyle(
                            color: textSecondary,
                            fontSize: 11.5.sp,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'common.close'.tr,
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close_rounded, color: textSecondary),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
                children: [
                  _buildSectionHeader(
                    title: 'orders.incoming.currentItems'.tr,
                    trailing: '$_totalQuantity ${'orders.itemsLabel'.tr}',
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  if (_lines.isEmpty)
                    _buildEmptyState(
                      'orders.noItems'.tr,
                      softSurface,
                      textSecondary,
                    )
                  else
                    ..._lines.map(
                      (line) => Padding(
                        padding: EdgeInsets.only(bottom: 8.h),
                        child: _buildCurrentItemRow(
                          line,
                          softSurface,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                    ),
                  SizedBox(height: 12.h),
                  _buildSectionHeader(
                    title: 'orders.incoming.addItems'.tr,
                    textPrimary: textPrimary,
                    textSecondary: textSecondary,
                  ),
                  SizedBox(height: 8.h),
                  _buildSearchField(textSecondary, softSurface),
                  SizedBox(height: 8.h),
                  if (_filteredMenuItems.isEmpty)
                    _buildEmptyState(
                      'orders.incoming.noAvailableItems'.tr,
                      softSurface,
                      textSecondary,
                    )
                  else
                    ..._filteredMenuItems.map(
                      (item) => Padding(
                        padding: EdgeInsets.only(bottom: 7.h),
                        child: _buildMenuItemRow(
                          item,
                          softSurface,
                          textPrimary,
                          textSecondary,
                        ),
                      ),
                    ),
                  if (_validationError != null) ...[
                    SizedBox(height: 5.h),
                    _buildValidationMessage(_validationError!, textPrimary),
                  ],
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 14.h),
              decoration: BoxDecoration(
                color: surface,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.08)
                        : const Color(0xFFE2ECE6),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: Size.fromHeight(48.h),
                        side: BorderSide(
                          color: AppColors.primary.withValues(alpha: 0.7),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                      ),
                      child: Text(
                        'common.cancel'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submit,
                      icon: Icon(Icons.check_rounded, size: 18.w),
                      label: Text(
                        'orders.incoming.saveItems'.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        minimumSize: Size.fromHeight(48.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(13.r),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required Color textPrimary,
    required Color textSecondary,
    String? trailing,
  }) {
    return Row(
      children: [
        Text(
          title,
          style: TextStyle(
            color: textPrimary,
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        if (trailing != null)
          Text(
            trailing,
            style: TextStyle(
              color: textSecondary,
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }

  Widget _buildSearchField(Color textSecondary, Color softSurface) {
    return TextField(
      controller: _searchController,
      onChanged: (value) => setState(() => _searchQuery = value),
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'common.search'.tr,
        hintStyle: TextStyle(color: textSecondary, fontSize: 12.sp),
        prefixIcon: Icon(
          Icons.search_rounded,
          color: textSecondary,
          size: 19.w,
        ),
        suffixIcon: _searchQuery.isEmpty
            ? null
            : IconButton(
                tooltip: 'common.clear'.tr,
                onPressed: () {
                  _searchController.clear();
                  setState(() => _searchQuery = '');
                },
                icon: Icon(
                  Icons.close_rounded,
                  color: textSecondary,
                  size: 17.w,
                ),
              ),
        filled: true,
        fillColor: softSurface,
        contentPadding: EdgeInsets.symmetric(vertical: 11.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.7),
          ),
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).colorScheme.onSurface,
        fontSize: 12.sp,
      ),
    );
  }

  Widget _buildCurrentItemRow(
    _EditableIncomingItem line,
    Color softSurface,
    Color textPrimary,
    Color textSecondary,
  ) {
    final warningColor = Theme.of(context).brightness == Brightness.dark
        ? const Color(0xFFFFC45C)
        : const Color(0xFFB97900);
    final isInvalid = !line.isAvailable || line.itemId == null;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: softSurface,
        borderRadius: BorderRadius.circular(14.r),
        border: isInvalid
            ? Border.all(color: warningColor.withValues(alpha: 0.34))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.restaurant_menu_rounded,
              color: AppColors.primary,
              size: 18.w,
            ),
          ),
          SizedBox(width: 9.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name.isEmpty ? 'orders.unknownItem'.tr : line.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '€${line.price.toStringAsFixed(2)}',
                  style: TextStyle(color: textSecondary, fontSize: 10.5.sp),
                ),
                if (isInvalid) ...[
                  SizedBox(height: 2.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'orders.incoming.itemUnavailable'.tr,
                          style: TextStyle(
                            color: warningColor,
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _removeLine(line),
                        style: TextButton.styleFrom(
                          foregroundColor: warningColor,
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        icon: Icon(Icons.delete_outline_rounded, size: 13.w),
                        label: Text(
                          'orders.incoming.removeItem'.tr,
                          style: TextStyle(
                            fontSize: 9.5.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          _buildQuantityControl(
            line,
            textPrimary: textPrimary,
            textSecondary: textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(
    _EditableIncomingItem line, {
    required Color textPrimary,
    required Color textSecondary,
  }) {
    return Container(
      height: 34.h,
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white.withValues(alpha: 0.07)
            : Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: line.quantity == 1
                ? 'orders.incoming.removeItem'.tr
                : 'orders.incoming.decreaseItem'.tr,
            onPressed: () => _decreaseLine(line),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 30.w, height: 34.h),
            icon: Icon(
              line.quantity == 1
                  ? Icons.delete_outline_rounded
                  : Icons.remove_rounded,
              color: textSecondary,
              size: 16.w,
            ),
          ),
          Text(
            '${line.quantity}',
            style: TextStyle(
              color: textPrimary,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          IconButton(
            tooltip: 'common.add'.tr,
            onPressed: () => _increaseLine(line),
            padding: EdgeInsets.zero,
            constraints: BoxConstraints.tightFor(width: 30.w, height: 34.h),
            icon: Icon(Icons.add_rounded, color: AppColors.primary, size: 16.w),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemRow(
    MenuItemModel item,
    Color softSurface,
    Color textPrimary,
    Color textSecondary,
  ) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _addMenuItem(item),
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: softSurface.withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(9.r),
                ),
                child: Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 18.w,
                ),
              ),
              SizedBox(width: 9.w),
              Expanded(
                child: Text(
                  item.getLocalizedName(_languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '€${item.price.toStringAsFixed(2)}',
                style: TextStyle(
                  color: textSecondary,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(
    String message,
    Color softSurface,
    Color textSecondary,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: softSurface,
        borderRadius: BorderRadius.circular(13.r),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(color: textSecondary, fontSize: 11.5.sp),
      ),
    );
  }

  Widget _buildValidationMessage(String message, Color textPrimary) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 11.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: AppColors.error, size: 17.w),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textPrimary,
                fontSize: 10.5.sp,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _customizationsFor(OrderItemModel item) {
    final parts = <String>[];
    final text = item.customizationsText?.trim();
    if (text != null && text.isNotEmpty) parts.add(text);

    final notes = item.notes?.trim();
    if (notes != null && notes.isNotEmpty && !parts.contains(notes)) {
      parts.add(notes);
    }

    if (item.customizations.isNotEmpty) {
      parts.add(
        item.customizations
            .map(
              (customization) => switch (customization.type) {
                CustomizationType.addition => '+ ${customization.name}',
                CustomizationType.removal => '- ${customization.name}',
              },
            )
            .join(', '),
      );
    }

    return parts.isEmpty ? null : parts.join(', ');
  }
}

class _EditableIncomingItem {
  _EditableIncomingItem({
    required this.key,
    required this.itemId,
    required this.name,
    required this.price,
    required this.quantity,
    this.customizations,
    required this.isAvailable,
  });

  final String key;
  final int? itemId;
  String name;
  final double price;
  int quantity;
  final String? customizations;
  final bool isAvailable;
}
