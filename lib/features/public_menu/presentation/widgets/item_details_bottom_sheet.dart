import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/currency/currency_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../menu/data/models/menu_item_model.dart';

/// Enhanced bottom sheet displaying menu item details for customers
class ItemDetailsBottomSheet extends ConsumerWidget {
  final MenuItemModel item;

  const ItemDetailsBottomSheet({
    super.key,
    required this.item,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final itemName = item.getLocalizedName(locale.languageCode);
    final itemDescription = item.getLocalizedDescription(locale.languageCode);
    final formattedPrice = ref.watch(formattedPriceProvider(item.price));

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background : LightColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  margin: EdgeInsets.only(top: 12.h, bottom: 8.h),
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),

              // Item image with gradient overlay
              if (item.imageUrl != null)
                Stack(
                  children: [
                    CachedNetworkImage(
                      imageUrl: item.imageUrl!,
                      width: double.infinity,
                      height: 280.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: double.infinity,
                        height: 280.h,
                        color: isDark
                            ? DarkColors.surface
                            : LightColors.surface,
                        child: const Center(
                          child: CircularProgressIndicator(),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: double.infinity,
                        height: 280.h,
                        color: isDark
                            ? DarkColors.surface
                            : LightColors.surface,
                        child: Icon(
                          Icons.fastfood,
                          size: 64.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ),
                    // Gradient overlay for better text readability
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 100.h,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              (isDark ? Colors.black : Colors.white)
                                  .withOpacity(0.8),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and price
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            itemName,
                            style: TextStyle(
                              fontSize: 26.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 12.h),

                    // Price with icon
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.local_offer,
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            formattedPrice,
                            style: TextStyle(
                              fontSize: 22.sp,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Description
                    if (itemDescription != null &&
                        itemDescription.isNotEmpty) ...[
                      SizedBox(height: 20.h),
                      Text(
                        itemDescription,
                        style: TextStyle(
                          fontSize: 16.sp,
                          height: 1.6,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],

                    // Ingredients section
                    if (item.ingredients.isNotEmpty) ...[
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Ingredients',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Wrap(
                        spacing: 8.w,
                        runSpacing: 8.h,
                        children: item.ingredients.map((ingredient) {
                          return Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14.w,
                              vertical: 8.h,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? DarkColors.surface
                                  : LightColors.surface,
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Text(
                              ingredient,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? DarkColors.textPrimary
                                    : LightColors.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Customizations section
                    if (item.hasCustomizations) ...[
                      SizedBox(height: 24.h),
                      Row(
                        children: [
                          Icon(
                            Icons.tune,
                            size: 20.sp,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Customizations',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),

                      // Additions
                      if (item.additions.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DarkColors.surface
                                : LightColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    size: 18.sp,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Add-ons',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? DarkColors.textPrimary
                                          : LightColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              ...item.additions.map((customization) {
                                final price = customization.priceModifier != null
                                    ? ref.watch(formattedPriceProvider(
                                        customization.priceModifier!))
                                    : null;
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6.w,
                                        height: 6.w,
                                        decoration: BoxDecoration(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Expanded(
                                        child: Text(
                                          customization.name,
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: isDark
                                                ? DarkColors.textPrimary
                                                : LightColors.textPrimary,
                                          ),
                                        ),
                                      ),
                                      if (price != null)
                                        Text(
                                          '+$price',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary,
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                      ],

                      // Removals
                      if (item.removals.isNotEmpty) ...[
                        Container(
                          padding: EdgeInsets.all(12.w),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DarkColors.surface
                                : LightColors.surface,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.remove_circle,
                                    size: 18.sp,
                                    color: AppColors.error,
                                  ),
                                  SizedBox(width: 6.w),
                                  Text(
                                    'Removable',
                                    style: TextStyle(
                                      fontSize: 15.sp,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? DarkColors.textPrimary
                                          : LightColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              ...item.removals.map((customization) {
                                return Padding(
                                  padding: EdgeInsets.only(bottom: 8.h),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 6.w,
                                        height: 6.w,
                                        decoration: BoxDecoration(
                                          color: AppColors.error,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      SizedBox(width: 10.w),
                                      Text(
                                        customization.name,
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
                              }),
                            ],
                          ),
                        ),
                      ],
                    ],

                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the item details bottom sheet
  static void show(BuildContext context, MenuItemModel item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ItemDetailsBottomSheet(item: item),
    );
  }
}
