import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/menu_notifier.dart';
import '../../data/models/menu_item_model.dart';
import '../widgets/ingredient_chips.dart';

/// Add/Edit menu item screen with full functionality
class AddMenuItemScreen extends ConsumerStatefulWidget {
  const AddMenuItemScreen({super.key, this.itemId});

  final String? itemId;

  @override
  ConsumerState<AddMenuItemScreen> createState() => _AddMenuItemScreenState();
}

class _AddMenuItemScreenState extends ConsumerState<AddMenuItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _prepTimeController = TextEditingController();

  String? _selectedCategoryId;
  bool _isAvailable = true;
  bool _isLoading = false;
  List<String> _ingredients = [];
  List<CustomizationOption> _customizations = [];
  String? _imageUrl;

  bool get _isEditing => widget.itemId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingItem();
    }
  }

  void _loadExistingItem() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final item = ref.read(menuProvider.notifier).getItemById(widget.itemId!);
      if (item != null) {
        setState(() {
          _nameController.text = item.name;
          _descriptionController.text = item.description ?? '';
          _priceController.text = item.price.toStringAsFixed(2);
          _prepTimeController.text = item.preparationTime.toString();
          _selectedCategoryId = item.categoryId;
          _isAvailable = item.isAvailable;
          _ingredients = List.from(item.ingredients);
          _customizations = List.from(item.customizations);
          _imageUrl = item.imageUrl;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _prepTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;

    // Set default category if not selected
    if (_selectedCategoryId == null && categories.isNotEmpty) {
      _selectedCategoryId = categories.first.id;
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text(_isEditing ? 'menu.editItem'.tr : 'menu.addItem'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
        actions: [
          if (_isEditing)
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: _showDeleteDialog,
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Basic info section
            _buildSectionTitle('menu.basicInfo'.tr, Icons.info_outline, isDark),
            SizedBox(height: 12.h),

            // Name field
            TextFormField(
              controller: _nameController,
              decoration: _inputDecoration('menu.itemName'.tr, isDark),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'validation.required'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Description field
            TextFormField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: _inputDecoration('menu.description'.tr, isDark),
            ),
            SizedBox(height: 16.h),

            // Price and Prep Time row
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _inputDecoration(
                      'menu.price'.tr,
                      isDark,
                      prefix: '€ ',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'validation.required'.tr;
                      }
                      if (double.tryParse(value) == null) {
                        return 'validation.invalidPrice'.tr;
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: TextFormField(
                    controller: _prepTimeController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'menu.preparationTime'.tr,
                      isDark,
                      suffix: ' min',
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategoryId,
              decoration: _inputDecoration('menu.category'.tr, isDark),
              items: categories
                  .map(
                    (c) => DropdownMenuItem(value: c.id, child: Text(c.name)),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) setState(() => _selectedCategoryId = value);
              },
            ),
            SizedBox(height: 24.h),

            // Availability toggle
            _buildAvailabilityToggle(isDark),
            SizedBox(height: 24.h),

            // Ingredients section
            IngredientChips(
              ingredients: _ingredients,
              onChanged: (ingredients) =>
                  setState(() => _ingredients = ingredients),
            ),
            SizedBox(height: 32.h),

            // TODO: Customizations section - hidden for now
            // CustomizationEditor(
            //   customizations: _customizations,
            //   onChanged: (customizations) =>
            //       setState(() => _customizations = customizations),
            // ),

            // Save button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _isEditing ? 'common.save'.tr : 'menu.addItem'.tr,
                        style: TextStyle(fontSize: 16.sp, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.w,
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailabilityToggle(bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                _isAvailable ? Icons.check_circle : Icons.cancel,
                color: _isAvailable ? AppColors.success : AppColors.error,
                size: 20.w,
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'menu.availability'.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  Text(
                    _isAvailable
                        ? 'menu.availableForOrdering'.tr
                        : 'menu.hiddenFromCustomers'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? DarkColors.textTertiary
                          : LightColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: _isAvailable,
            activeColor: AppColors.success,
            onChanged: (value) => setState(() => _isAvailable = value),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(
    String label,
    bool isDark, {
    String? prefix,
    String? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      prefixText: prefix,
      suffixText: suffix,
      filled: true,
      fillColor: isDark ? DarkColors.surface : LightColors.surface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) return;

    setState(() => _isLoading = true);

    final item = MenuItemModel(
      id: widget.itemId ?? '',
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      price: double.parse(_priceController.text),
      categoryId: _selectedCategoryId!,
      ingredients: _ingredients,
      customizations: _customizations,
      isAvailable: _isAvailable,
      preparationTime: int.tryParse(_prepTimeController.text) ?? 0,
      imageUrl: _imageUrl,
    );

    try {
      if (_isEditing) {
        await ref.read(menuProvider.notifier).updateItem(item);
      } else {
        await ref.read(menuProvider.notifier).addItem(item);
      }

      // Check if the operation resulted in an error
      final menuState = ref.read(menuProvider);
      if (menuState.error != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${"common.error".tr}: ${menuState.error}'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_isEditing ? 'menu.itemUpdated'.tr : 'menu.itemAdded'.tr)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('${"common.error".tr}: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('menu.deleteItem'.tr),
        content: Text('common.actionCannotBeUndone'.tr),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(menuProvider.notifier).deleteItem(widget.itemId!);
              if (mounted) {
                context.pop();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('menu.itemDeleted'.tr)));
              }
            },
            child: Text('common.delete'.tr, style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}
