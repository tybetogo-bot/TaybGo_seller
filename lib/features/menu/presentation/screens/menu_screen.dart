import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/menu_notifier.dart';

/// Menu management screen - connected to API
class MenuScreen extends ConsumerWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final menuState = ref.watch(menuProvider);
    final categories = menuState.categories;
    final items = menuState.filteredItems;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('menu.title'.tr),
        centerTitle: true,
        backgroundColor:
            isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.folder_outlined),
            onPressed: () => context.push(Routes.categories),
            tooltip: 'menu.categories'.tr,
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push(Routes.addMenuItem),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(menuProvider.notifier).refresh();
        },
        child: Column(
          children: [
            // Category filter
            if (categories.isNotEmpty) ...[
              SizedBox(
                height: 44.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: categories.length + 1, // +1 for "All" option
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      // "All" category
                      final isSelected = menuState.selectedCategoryId == null;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: GestureDetector(
                          onTap: () {
                            ref.read(menuProvider.notifier).selectCategory(null);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(20.r),
                              border: isSelected
                                  ? null
                                  : Border.all(
                                      color: isDark
                                          ? DarkColors.border
                                          : LightColors.border,
                                    ),
                            ),
                            child: Text(
                              'menuCategories.all'.tr,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark
                                        ? DarkColors.textSecondary
                                        : LightColors.textSecondary),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    final category = categories[index - 1];
                    final isSelected = menuState.selectedCategoryId == category.id;
                    final itemCount = menuState.getItemCountForCategory(category.id);

                    return Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: GestureDetector(
                        onTap: () {
                          ref.read(menuProvider.notifier).selectCategory(category.id);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 8.h,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20.r),
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: isDark
                                        ? DarkColors.border
                                        : LightColors.border,
                                  ),
                          ),
                          child: Text(
                            '${category.name} ($itemCount)',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? Colors.white
                                  : (isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
            ],

            // Loading state
            if (menuState.isLoading && items.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      SizedBox(height: 16.h),
                      Text(
                        'common.loading'.tr,
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
              )
            // Error state
            else if (menuState.error != null && items.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64.w,
                        color: AppColors.error,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        menuState.error!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.error,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(menuProvider.notifier).refresh();
                        },
                        child: Text('common.retry'.tr),
                      ),
                    ],
                  ),
                ),
              )
            // Empty state
            else if (items.isEmpty)
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.restaurant_menu_outlined,
                        size: 64.w,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'menu.noItems'.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textPrimary
                              : LightColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Tap + to add your first menu item',
                        textAlign: TextAlign.center,
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
              )
            // Menu items list
            else
              Expanded(
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _MenuItemRow(
                      item: item,
                      isDark: isDark,
                      onTap: () => context.push(Routes.menuItemPath(item.id)),
                      onToggle: (val) {
                        ref
                            .read(menuProvider.notifier)
                            .toggleItemAvailability(item.id);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemRow extends StatelessWidget {
  const _MenuItemRow({
    required this.item,
    required this.isDark,
    required this.onTap,
    required this.onToggle,
  });

  final dynamic item; // MenuItemModel
  final bool isDark;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggle;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Small image placeholder
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isDark
                    ? DarkColors.background
                    : LightColors.background,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: item.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        item.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.restaurant,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.restaurant,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
            ),
            SizedBox(width: 12.w),

            // Name and price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '€${item.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Availability toggle
            Switch(
              value: item.isAvailable,
              onChanged: onToggle,
              activeTrackColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }
}
