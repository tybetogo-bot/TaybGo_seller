import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/currency/currency_provider.dart';
import '../../../../core/theme/theme.dart';
import '../../../menu/data/models/menu_item_model.dart';

/// Enhanced public menu item card - beautiful view for customers
class PublicMenuItemCard extends ConsumerWidget {
  final MenuItemModel item;
  final VoidCallback onTap;

  const PublicMenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final locale = Localizations.localeOf(context);
    final itemName = item.getLocalizedName(locale.languageCode);
    final itemDescription = item.getLocalizedDescription(locale.languageCode);
    final formattedPrice = ref.watch(formattedPriceProvider(item.price));

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Item image
            if (item.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
                child: CachedNetworkImage(
                  imageUrl: item.imageUrl!,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: double.infinity,
                    height: 180.h,
                    color: isDark
                        ? DarkColors.background
                        : LightColors.background,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: double.infinity,
                    height: 180.h,
                    color: isDark
                        ? DarkColors.background
                        : LightColors.background,
                    child: Icon(
                      Icons.fastfood,
                      size: 48.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ),
              ),

            // Item details
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Name and price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          itemName,
                          style: TextStyle(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          formattedPrice,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Description
                  if (itemDescription != null &&
                      itemDescription.isNotEmpty) ...[
                    SizedBox(height: 8.h),
                    Text(
                      itemDescription,
                      style: TextStyle(
                        fontSize: 14.sp,
                        height: 1.4,
                        color: isDark
                            ? DarkColors.textSecondary
                            : LightColors.textSecondary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],

                  // Ingredients
                  if (item.ingredients.isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 6.w,
                      runSpacing: 6.h,
                      children: item.ingredients.take(4).map((ingredient) {
                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? DarkColors.background
                                : LightColors.background,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(
                              color: isDark
                                  ? DarkColors.border
                                  : LightColors.border,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.eco_outlined,
                                size: 12.sp,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                ingredient,
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: isDark
                                      ? DarkColors.textSecondary
                                      : LightColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                    if (item.ingredients.length > 4) ...[
                      SizedBox(height: 6.h),
                      Text(
                        '+${item.ingredients.length - 4} more',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontStyle: FontStyle.italic,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
