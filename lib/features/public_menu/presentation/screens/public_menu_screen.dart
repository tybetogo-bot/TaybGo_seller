import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/public_menu_notifier.dart';
import '../../application/public_menu_state.dart';
import '../widgets/category_section.dart';
import '../widgets/item_details_bottom_sheet.dart';
import '../widgets/restaurant_header.dart';

/// Public menu screen - customer-facing menu view
class PublicMenuScreen extends ConsumerWidget {
  final String restaurantId;

  const PublicMenuScreen({
    super.key,
    required this.restaurantId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final menuAsync = ref.watch(publicMenuProvider(restaurantId));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('publicMenu.title'.tr),
        centerTitle: true,
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
      ),
      body: menuAsync.when(
        data: (state) {
          if (state is PublicMenuLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(publicMenuProvider(restaurantId));
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Restaurant header
                    RestaurantHeader(restaurant: state.restaurant),

                    // Categories and items (only show categories with available items)
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Column(
                        children: state.categories
                            .where((category) {
                              final items =
                                  state.itemsByCategory[category.id] ?? [];
                              return items.isNotEmpty;
                            })
                            .map((category) {
                              final items =
                                  state.itemsByCategory[category.id] ?? [];
                              return CategorySection(
                                category: category,
                                items: items,
                                onItemTap: (item) {
                                  ItemDetailsBottomSheet.show(context, item);
                                },
                              );
                            })
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is PublicMenuError) {
            return _ErrorView(
              message: state.message,
              onRetry: () {
                ref.invalidate(publicMenuProvider(restaurantId));
              },
            );
          } else {
            // Initial or loading state
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _ErrorView(
          message: error.toString(),
          onRetry: () {
            ref.invalidate(publicMenuProvider(restaurantId));
          },
        ),
      ),
    );
  }
}

/// Error view widget
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
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
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.sp,
                color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text('publicMenu.retry'.tr),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: 24.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
