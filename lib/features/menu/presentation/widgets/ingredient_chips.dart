import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// Widget for displaying and editing ingredients as chips
class IngredientChips extends StatefulWidget {
  const IngredientChips({
    super.key,
    required this.ingredients,
    required this.onChanged,
    this.enabled = true,
  });

  final List<String> ingredients;
  final ValueChanged<List<String>> onChanged;
  final bool enabled;

  @override
  State<IngredientChips> createState() => _IngredientChipsState();
}

class _IngredientChipsState extends State<IngredientChips> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _addIngredient(String ingredient) {
    final trimmed = ingredient.trim();
    if (trimmed.isEmpty) return;
    if (widget.ingredients.contains(trimmed)) return;

    widget.onChanged([...widget.ingredients, trimmed]);
    _controller.clear();
  }

  void _removeIngredient(int index) {
    final updated = List<String>.from(widget.ingredients);
    updated.removeAt(index);
    widget.onChanged(updated);
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
              Icons.restaurant_menu,
              size: 20.w,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
            SizedBox(width: 8.w),
            Text(
              'menu.ingredients'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),

        // Chips wrap
        Container(
          width: double.infinity,
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
              // Existing ingredients
              if (widget.ingredients.isNotEmpty) ...[
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: List.generate(
                    widget.ingredients.length,
                    (index) => _IngredientChip(
                      label: widget.ingredients[index],
                      onDelete: widget.enabled ? () => _removeIngredient(index) : null,
                      isDark: isDark,
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
              ],

              // Add ingredient input
              if (widget.enabled)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        decoration: InputDecoration(
                          hintText: 'menu.addIngredient'.tr,
                          hintStyle: TextStyle(
                            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                            fontSize: 14.sp,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 10.h,
                          ),
                          filled: true,
                          fillColor: isDark ? DarkColors.background : LightColors.background,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                        ),
                        textInputAction: TextInputAction.done,
                        onSubmitted: _addIngredient,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    IconButton(
                      onPressed: () => _addIngredient(_controller.text),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.all(10.w),
                      ),
                      icon: Icon(Icons.add, size: 20.w),
                    ),
                  ],
                ),

              // Empty state
              if (widget.ingredients.isEmpty && !widget.enabled)
                Text(
                  'ingredients.noIngredientsAdded'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Individual ingredient chip
class _IngredientChip extends StatelessWidget {
  const _IngredientChip({
    required this.label,
    required this.isDark,
    this.onDelete,
  });

  final String label;
  final bool isDark;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (onDelete != null) ...[
            SizedBox(width: 6.w),
            GestureDetector(
              onTap: onDelete,
              child: Icon(
                Icons.close,
                size: 16.w,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Read-only ingredient chips display
class IngredientChipsDisplay extends StatelessWidget {
  const IngredientChipsDisplay({
    super.key,
    required this.ingredients,
  });

  final List<String> ingredients;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (ingredients.isEmpty) {
      return Text(
        'ingredients.noIngredients'.tr,
        style: TextStyle(
          fontSize: 14.sp,
          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: ingredients.map((ingredient) => 
        _IngredientChip(
          label: ingredient,
          isDark: isDark,
        ),
      ).toList(),
    );
  }
}
