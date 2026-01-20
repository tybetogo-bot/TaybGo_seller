import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/menu_notifier.dart';
import '../widgets/customization_editor.dart';
import '../widgets/ingredient_chips.dart';

/// Screen to display detailed information about a menu item
class MenuItemDetailsScreen extends ConsumerWidget {
  const MenuItemDetailsScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuState = ref.watch(menuProvider);
    final item = menuState.items.where((i) => i.id == itemId).firstOrNull;

    if (item == null) {
      return Scaffold(
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        appBar: AppBar(
          title: Text('menuItem.itemDetails'.tr),
          backgroundColor: isDark ? DarkColors.background : LightColors.background,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.w,
                color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
              ),
              SizedBox(height: 16.h),
              Text(
                'menuItem.itemNotFound'.tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final category = menuState.categories.where((c) => c.id == item.categoryId).firstOrNull;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar with image
          SliverAppBar(
            expandedHeight: 200.h,
            pinned: true,
            backgroundColor: isDark ? DarkColors.background : LightColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: item.imageUrl != null && item.imageUrl!.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: isDark ? DarkColors.surface : LightColors.surface,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: isDark
                                ? DarkColors.textTertiary
                                : LightColors.textTertiary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => _buildPlaceholder(isDark),
                    )
                  : _buildPlaceholder(isDark),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.push('/menu/edit/${item.id}'),
              ),
            ],
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with name and availability
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                          ),
                        ),
                      ),
                      _AvailabilityBadge(isAvailable: item.isAvailable),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // Category
                  if (category != null)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        category.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(height: 16.h),

                  // Price and prep time
                  Row(
                    children: [
                      _InfoChip(
                        icon: Icons.euro,
                        label: item.price.toStringAsFixed(2),
                        color: AppColors.success,
                        isDark: isDark,
                      ),
                      SizedBox(width: 12.w),
                      if (item.preparationTime > 0)
                        _InfoChip(
                          icon: Icons.schedule,
                          label: '${item.preparationTime} min',
                          color: AppColors.warning,
                          isDark: isDark,
                        ),
                    ],
                  ),
                  SizedBox(height: 20.h),

                  // Description
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    _SectionHeader(title: 'menuItem.description'.tr, icon: Icons.description, isDark: isDark),
                    SizedBox(height: 8.h),
                    Text(
                      item.description!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],

                  // Ingredients
                  _SectionHeader(title: 'menuItem.ingredients'.tr, icon: Icons.restaurant_menu, isDark: isDark),
                  SizedBox(height: 12.h),
                  IngredientChipsDisplay(ingredients: item.ingredients),
                  SizedBox(height: 20.h),

                  // Customizations
                  _SectionHeader(title: 'menuItem.customizations'.tr, icon: Icons.tune, isDark: isDark),
                  SizedBox(height: 12.h),
                  CustomizationDisplay(customizations: item.customizations),
                  SizedBox(height: 32.h),

                  // Actions
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            await ref.read(menuProvider.notifier).toggleItemAvailability(item.id);
                          },
                          icon: Icon(
                            item.isAvailable ? Icons.visibility_off : Icons.visibility,
                          ),
                          label: Text(item.isAvailable ? 'menuItem.markUnavailable'.tr : 'menuItem.markAvailable'.tr),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => context.push('/menu/edit/${item.id}'),
                          icon: const Icon(Icons.edit),
                          label: Text('menuItem.editItem'.tr),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 12.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(bool isDark) {
    return Container(
      color: isDark ? DarkColors.surface : LightColors.surface,
      child: Center(
        child: Icon(
          Icons.restaurant,
          size: 64.w,
          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.icon,
    required this.isDark,
  });

  final String title;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18.w,
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
}

class _AvailabilityBadge extends StatelessWidget {
  const _AvailabilityBadge({required this.isAvailable});

  final bool isAvailable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: (isAvailable ? AppColors.success : AppColors.error).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            size: 14.w,
            color: isAvailable ? AppColors.success : AppColors.error,
          ),
          SizedBox(width: 4.w),
          Text(
            isAvailable ? 'Available' : 'Unavailable',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: isAvailable ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18.w, color: color),
          SizedBox(width: 6.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
