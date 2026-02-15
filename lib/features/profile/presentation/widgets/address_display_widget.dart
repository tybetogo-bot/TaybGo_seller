import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/theme.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Widget to display restaurant address in a nice card format
class AddressDisplayWidget extends StatelessWidget {
  const AddressDisplayWidget({
    super.key,
    required this.addressData,
    required this.lat,
    required this.lng,
    required this.fullAddress,
    required this.isDark,
    this.onEdit,
  });

  final RestaurantAddressModel? addressData;
  final double? lat;
  final double? lng;
  final String fullAddress;
  final bool isDark;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final hasAddress = addressData != null || fullAddress.isNotEmpty;

    if (!hasAddress) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: isDark ? DarkColors.surface : LightColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.location_off_outlined,
              size: 48.sp,
              color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
            ),
            SizedBox(height: 12.h),
            Text(
              'No address configured',
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
            if (onEdit != null) ...[
              SizedBox(height: 16.h),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.add_location),
                label: const Text('Add Address'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
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
          // Header with edit button
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.location_on,
                    color: primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurant Location',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                        ),
                      ),
                      if (addressData?.label != null)
                        Text(
                          addressData!.label!,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                          ),
                        ),
                    ],
                  ),
                ),
                if (onEdit != null)
                  IconButton(
                    onPressed: onEdit,
                    icon: Icon(
                      Icons.edit_outlined,
                      size: 20.sp,
                      color: primaryColor,
                    ),
                    tooltip: 'Edit Address',
                  ),
              ],
            ),
          ),

          Divider(
            height: 1,
            color: isDark ? DarkColors.border : LightColors.border,
          ),

          // Address details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Check if we have structured address fields
                if (_hasStructuredAddress) ...[
                  _buildAddressField(
                    icon: Icons.signpost_outlined,
                    label: 'Street',
                    value: _buildStreetAddress(),
                  ),
                  if (_buildCityPostal().isNotEmpty) ...[
                    SizedBox(height: 12.h),
                    _buildAddressField(
                      icon: Icons.location_city_outlined,
                      label: 'City',
                      value: _buildCityPostal(),
                    ),
                  ],
                  if (addressData?.country != null) ...[
                    SizedBox(height: 12.h),
                    _buildAddressField(
                      icon: Icons.public_outlined,
                      label: 'Country',
                      value: addressData!.country!,
                    ),
                  ],
                ] else if (fullAddress.isNotEmpty) ...[
                  _buildAddressField(
                    icon: Icons.place_outlined,
                    label: 'Address',
                    value: fullAddress,
                  ),
                ],

                // Coordinates
                if (lat != null && lng != null) ...[
                  SizedBox(height: 12.h),
                  _buildAddressField(
                    icon: Icons.my_location_outlined,
                    label: 'Coordinates',
                    value: '${lat!.toStringAsFixed(6)}, ${lng!.toStringAsFixed(6)}',
                    valueStyle: TextStyle(
                      fontSize: 12.sp,
                      fontFamily: 'monospace',
                      color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressField({
    required IconData icon,
    required String label,
    required String value,
    TextStyle? valueStyle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
        ),
        SizedBox(width: 8.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: valueStyle ??
                    TextStyle(
                      fontSize: 13.sp,
                      color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  bool get _hasStructuredAddress =>
      addressData?.streetName != null ||
      addressData?.houseNumber != null ||
      addressData?.city != null ||
      addressData?.postalCode != null ||
      addressData?.country != null;

  String _buildStreetAddress() {
    final parts = <String>[
      if (addressData?.streetName != null) addressData!.streetName!,
      if (addressData?.houseNumber != null) addressData!.houseNumber!,
    ];
    return parts.where((s) => s.isNotEmpty).join(' ');
  }

  String _buildCityPostal() {
    final parts = <String>[
      if (addressData?.postalCode != null) addressData!.postalCode!,
      if (addressData?.city != null) addressData!.city!,
    ];
    return parts.where((s) => s.isNotEmpty).join(' ');
  }
}
