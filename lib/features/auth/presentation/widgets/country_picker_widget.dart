import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import '../../../../core/data/countries.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';

/// Country picker widget for selecting country code
class CountryPickerWidget extends StatelessWidget {
  const CountryPickerWidget({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showCountryPicker(context),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: isDark
              ? DarkColors.inputBackground
              : LightColors.inputBackground,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedCountry.flag, style: TextStyle(fontSize: 20.sp)),
            SizedBox(width: 6.w),
            Text(
              selectedCountry.dialCode,
              textDirection: ui.TextDirection.ltr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.keyboard_arrow_down,
              size: 18.w,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showCountryPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CountryPickerBottomSheet(
        selectedCountry: selectedCountry,
        onCountrySelected: (country) {
          onCountrySelected(country);
          Navigator.of(context).pop();
        },
      ),
    );
  }
}

class _CountryPickerBottomSheet extends ConsumerStatefulWidget {
  const _CountryPickerBottomSheet({
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;

  @override
  ConsumerState<_CountryPickerBottomSheet> createState() =>
      _CountryPickerBottomSheetState();
}

class _CountryPickerBottomSheetState
    extends ConsumerState<_CountryPickerBottomSheet> {
  final _searchController = TextEditingController();
  List<Country> _filteredCountries = Countries.all;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      _filteredCountries = Countries.search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: isDark ? DarkColors.border : LightColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Title
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              '${'common.select'.tr} ${'address.country'.tr}',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
          ),

          // Search field
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCountries,
              decoration: InputDecoration(
                hintText: 'auth.searchCountry'.tr,
                prefixIcon: Icon(Icons.search, size: 20.w),
                filled: true,
                fillColor: isDark
                    ? DarkColors.inputBackground
                    : LightColors.inputBackground,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16.w,
                  vertical: 12.h,
                ),
              ),
            ),
          ),

          SizedBox(height: 12.h),

          // Country list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredCountries.length,
              itemBuilder: (context, index) {
                final country = _filteredCountries[index];
                final isSelected = country == widget.selectedCountry;

                return ListTile(
                  onTap: () => widget.onCountrySelected(country),
                  leading: Text(
                    country.flag,
                    style: TextStyle(fontSize: 24.sp),
                  ),
                  title: Text(
                    country.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        country.dialCode,
                        textDirection: ui.TextDirection.ltr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                      if (isSelected) ...[
                        SizedBox(width: 8.w),
                        Icon(
                          Icons.check_circle,
                          size: 20.w,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Phone input field with country picker
class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.selectedCountry,
    required this.onCountrySelected,
    this.validator,
    this.onChanged,
    this.enabled = true,
  });

  final TextEditingController controller;
  final Country selectedCountry;
  final ValueChanged<Country> onCountrySelected;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Country picker
        CountryPickerWidget(
          selectedCountry: selectedCountry,
          onCountrySelected: onCountrySelected,
        ),

        SizedBox(width: 10.w),

        // Phone number input
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.phone,
            textDirection: ui.TextDirection.ltr,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            enabled: enabled,
            onChanged: onChanged,
            validator:
                validator ??
                (value) {
                  if (value == null || value.isEmpty) {
                    return 'validation.required'.tr;
                  }
                  if (value.length < selectedCountry.minLength) {
                    return 'validation.phoneTooShort'.tr;
                  }
                  if (value.length > selectedCountry.maxLength) {
                    return 'validation.phoneTooLong'.tr;
                  }
                  return null;
                },
            decoration: InputDecoration(
              hintText: 'auth.phoneNumber'.tr,
              filled: true,
              fillColor: isDark
                  ? DarkColors.inputBackground
                  : LightColors.inputBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: isDark ? DarkColors.border : LightColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: isDark ? DarkColors.border : LightColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: const BorderSide(color: AppColors.error),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
