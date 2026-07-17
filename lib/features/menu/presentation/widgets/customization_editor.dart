import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../core/i18n/i18n.dart';import '../../../../core/theme/theme.dart';
import '../../data/models/menu_item_model.dart';

/// Widget for editing menu item customizations (additions and removals)
class CustomizationEditor extends StatefulWidget {
  const CustomizationEditor({
    super.key,
    required this.customizations,
    required this.onChanged,
    this.enabled = true,
  });

  final List<CustomizationOption> customizations;
  final ValueChanged<List<CustomizationOption>> onChanged;
  final bool enabled;

  @override
  State<CustomizationEditor> createState() => _CustomizationEditorState();
}

class _CustomizationEditorState extends State<CustomizationEditor> {
  List<CustomizationOption> get _additions =>
      widget.customizations.where((c) => c.type == CustomizationType.addition).toList();

  List<CustomizationOption> get _removals =>
      widget.customizations.where((c) => c.type == CustomizationType.removal).toList();

  void _addCustomization(CustomizationOption option) {
    widget.onChanged([...widget.customizations, option]);
  }

  void _removeCustomization(String id) {
    widget.onChanged(widget.customizations.where((c) => c.id != id).toList());
  }

  void _showAddDialog(CustomizationType type) {
    final nameController = TextEditingController();
    final priceController = TextEditingController(text: '0.00');
    final isAddition = type == CustomizationType.addition;

    showDialog(
      context: context,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        
        return AlertDialog(
          backgroundColor: isDark ? DarkColors.surface : LightColors.surface,
          title: Text(isAddition ? 'menuItem.addExtra'.tr : 'menuItem.addRemovalOption'.tr),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'menuItem.extraName'.tr,
                  hintText: isAddition ? 'menuItem.extraNameHint'.tr : 'menuItem.removalNameHint'.tr,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                autofocus: true,
              ),
              if (isAddition) ...[
                SizedBox(height: 16.h),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'menu.additionalPrice'.tr,
                    prefixText: '€ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('common.cancel'.tr),
            ),
            FilledButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) return;

                final price = double.tryParse(priceController.text) ?? 0.0;
                
                final option = CustomizationOption(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: name,
                  type: type,
                  priceModifier: isAddition ? price : 0.0,
                );

                _addCustomization(option);
                Navigator.pop(context);
              },
              child: Text('common.add'.tr),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          children: [
            Icon(
              Icons.tune,
              size: 20.w,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
            SizedBox(width: 8.w),
            Text(
              'menu.customizations'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Additions section
        _CustomizationSection(
          title: 'menu.extras'.tr,
          subtitle: 'menu.extrasDescription'.tr,
          icon: Icons.add_circle_outline,
          iconColor: AppColors.success,
          items: _additions,
          onRemove: widget.enabled ? _removeCustomization : null,
          onAdd: widget.enabled ? () => _showAddDialog(CustomizationType.addition) : null,
          showPrice: true,
          isDark: isDark,
        ),
        SizedBox(height: 16.h),

        // Removals section
        _CustomizationSection(
          title: 'menu.removals'.tr,
          subtitle: 'menu.removalsDescription'.tr,
          icon: Icons.remove_circle_outline,
          iconColor: AppColors.error,
          items: _removals,
          onRemove: widget.enabled ? _removeCustomization : null,
          onAdd: widget.enabled ? () => _showAddDialog(CustomizationType.removal) : null,
          showPrice: false,
          isDark: isDark,
        ),
      ],
    );
  }
}

/// Section for a type of customization
class _CustomizationSection extends StatelessWidget {
  const _CustomizationSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.items,
    required this.isDark,
    this.onRemove,
    this.onAdd,
    this.showPrice = true,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final List<CustomizationOption> items;
  final bool isDark;
  final void Function(String id)? onRemove;
  final VoidCallback? onAdd;
  final bool showPrice;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(icon, size: 18.w, color: iconColor),
              SizedBox(width: 8.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              if (onAdd != null)
                IconButton(
                  onPressed: onAdd,
                  icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
                  style: IconButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  ),
                  iconSize: 20.w,
                ),
            ],
          ),

          // Items list
          if (items.isNotEmpty) ...[
            SizedBox(height: 12.h),
            ...items.map((item) => _CustomizationItem(
              option: item,
              onRemove: onRemove != null ? () => onRemove!(item.id) : null,
              showPrice: showPrice,
              isDark: isDark,
            )),
          ] else ...[
            SizedBox(height: 8.h),
            Text(
              'No ${title.toLowerCase()} added',
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Individual customization item
class _CustomizationItem extends StatelessWidget {
  const _CustomizationItem({
    required this.option,
    required this.isDark,
    this.onRemove,
    this.showPrice = true,
  });

  final CustomizationOption option;
  final bool isDark;
  final VoidCallback? onRemove;
  final bool showPrice;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              option.name,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
          ),
          if (showPrice && option.priceModifier > 0)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '+€${option.priceModifier.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (onRemove != null) ...[
            SizedBox(width: 8.w),
            GestureDetector(
              onTap: onRemove,
              child: Icon(
                Icons.close,
                size: 18.w,
                color: AppColors.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Read-only display of customizations
class CustomizationDisplay extends StatelessWidget {
  const CustomizationDisplay({
    super.key,
    required this.customizations,
  });

  final List<CustomizationOption> customizations;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final additions = customizations.where((c) => c.type == CustomizationType.addition).toList();
    final removals = customizations.where((c) => c.type == CustomizationType.removal).toList();

    if (customizations.isEmpty) {
      return Text(
        'customization.noCustomizations'.tr,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (additions.isNotEmpty) ...[
          Text(
            'customization.extras'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 4.h),
          ...additions.map((a) => Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Row(
              children: [
                Icon(Icons.add, size: 14.w, color: AppColors.success),
                SizedBox(width: 4.w),
                Text(
                  a.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (a.priceModifier > 0)
                  Text(
                    '+€${a.priceModifier.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.success,
                    ),
                  ),
              ],
            ),
          )),
          SizedBox(height: 8.h),
        ],
        if (removals.isNotEmpty) ...[
          Text(
            'customization.canBeRemoved'.tr,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 4.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 4.h,
            children: removals.map((r) => Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.remove, size: 12.w, color: AppColors.error),
                  SizedBox(width: 2.w),
                  Text(
                    r.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.error,
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ],
    );
  }
}
