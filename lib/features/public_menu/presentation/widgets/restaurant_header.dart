import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Restaurant header widget displaying logo, name, and contact information
class RestaurantHeader extends StatelessWidget {
  final RestaurantModel restaurant;

  const RestaurantHeader({
    super.key,
    required this.restaurant,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? DarkColors.border : LightColors.border,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Logo
          if (restaurant.logoUrl != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: CachedNetworkImage(
                imageUrl: restaurant.logoUrl!,
                width: 100.w,
                height: 100.w,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 100.w,
                  height: 100.w,
                  color: isDark ? DarkColors.background : LightColors.background,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 100.w,
                  height: 100.w,
                  color: isDark ? DarkColors.background : LightColors.background,
                  child: Icon(
                    Icons.restaurant,
                    size: 48.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Restaurant name
          Text(
            restaurant.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),

          // Description
          if (restaurant.description != null) ...[
            SizedBox(height: 8.h),
            Text(
              restaurant.description!,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          // Phone number with call button
          if (restaurant.phone != null) ...[
            SizedBox(height: 16.h),
            InkWell(
              onTap: () => _makePhoneCall(restaurant.phone!),
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.phone,
                      size: 20.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'publicMenu.callRestaurant'.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      restaurant.phone!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }
}
