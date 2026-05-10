import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../menu/presentation/widgets/image_picker_widget.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';

/// Restaurant settings screen
class RestaurantSettingsScreen extends ConsumerStatefulWidget {
  const RestaurantSettingsScreen({super.key});

  @override
  ConsumerState<RestaurantSettingsScreen> createState() =>
      _RestaurantSettingsScreenState();
}

class _RestaurantSettingsScreenState
    extends ConsumerState<RestaurantSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final Map<String, List<_WorkHourDraft>> _workHourDrafts = {};
  bool _isInitialized = false;
  bool _isSaving = false;
  String? _logoUrl;
  bool _isUploadingLogo = false;
  String? _workHoursError;

  static const List<String> _weekdayKeys = [
    'monday',
    'tuesday',
    'wednesday',
    'thursday',
    'friday',
    'saturday',
    'sunday',
  ];

  static final DateTime _referenceMonday = DateTime(2024, 1, 1);

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _disposeWorkHourDrafts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);

    // Initialize controllers with restaurant data
    if (!_isInitialized && selectedRestaurant != null) {
      _nameController.text = selectedRestaurant.name;
      _phoneController.text = selectedRestaurant.phone ?? '';
      _logoUrl = selectedRestaurant.logoUrl;
      _initializeWorkHours(selectedRestaurant);
      _isInitialized = true;
    }

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('settings.restaurantSettings'.tr),
        backgroundColor: isDark
            ? DarkColors.background
            : LightColors.background,
        elevation: 0,
        actions: [
          if (_isSaving || _isUploadingLogo)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveSettings,
              child: Text(
                'common.save'.tr,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
            ),
        ],
      ),
      body: selectedRestaurant == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                // Restaurant info
                Text(
                  'settings.restaurantInfo'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  'settings.restaurantName'.tr,
                  _nameController,
                  isDark,
                ),
                SizedBox(height: 12.h),
                _buildTextField(
                  'auth.phoneNumber'.tr,
                  _phoneController,
                  isDark,
                  keyboardType: TextInputType.phone,
                ),
                SizedBox(height: 24.h),

                // Restaurant logo
                Text(
                  'settings.restaurantLogo'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                ImagePickerWidget(
                  initialImageUrl: _logoUrl,
                  onImageUploaded: (url) {
                    setState(() => _logoUrl = url);
                  },
                  onImageRemoved: () {
                    setState(() => _logoUrl = null);
                  },
                  onUploadStateChanged: (isUploading) {
                    setState(() => _isUploadingLogo = isUploading);
                  },
                ),
                SizedBox(height: 24.h),

                _buildWorkHoursSection(isDark),
                SizedBox(height: 24.h),

                // Address section (read-only display)
                Text(
                  'orders.address'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
                SizedBox(height: 12.h),
                // Display address in a read-only container
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: isDark ? DarkColors.surface : LightColors.surface,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedRestaurant.addressData != null ||
                          selectedRestaurant.fullAddress.isNotEmpty) ...[
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Theme.of(context).colorScheme.primary,
                              size: 20.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (selectedRestaurant
                                              .addressData
                                              ?.streetName !=
                                          null ||
                                      selectedRestaurant
                                              .addressData
                                              ?.houseNumber !=
                                          null)
                                    Text(
                                      [
                                            selectedRestaurant
                                                .addressData
                                                ?.streetName,
                                            selectedRestaurant
                                                .addressData
                                                ?.houseNumber,
                                          ]
                                          .where(
                                            (s) => s != null && s.isNotEmpty,
                                          )
                                          .join(' '),
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w500,
                                        color: isDark
                                            ? DarkColors.textPrimary
                                            : LightColors.textPrimary,
                                      ),
                                    ),
                                  if (selectedRestaurant.addressData?.city !=
                                          null ||
                                      selectedRestaurant
                                              .addressData
                                              ?.postalCode !=
                                          null)
                                    Text(
                                      [
                                            selectedRestaurant
                                                .addressData
                                                ?.postalCode,
                                            selectedRestaurant
                                                .addressData
                                                ?.city,
                                          ]
                                          .where(
                                            (s) => s != null && s.isNotEmpty,
                                          )
                                          .join(' '),
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: isDark
                                            ? DarkColors.textSecondary
                                            : LightColors.textSecondary,
                                      ),
                                    ),
                                  if (selectedRestaurant.addressData?.country !=
                                      null)
                                    Text(
                                      selectedRestaurant.addressData!.country!,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: isDark
                                            ? DarkColors.textSecondary
                                            : LightColors.textSecondary,
                                      ),
                                    ),
                                  // Fallback to simple address if no addressData
                                  if (selectedRestaurant.addressData == null &&
                                      selectedRestaurant.fullAddress.isNotEmpty)
                                    Text(
                                      selectedRestaurant.fullAddress,
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: isDark
                                            ? DarkColors.textPrimary
                                            : LightColors.textPrimary,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        // Show coordinates if available
                        if (selectedRestaurant.lat != null &&
                            selectedRestaurant.lng != null) ...[
                          SizedBox(height: 8.h),
                          Text(
                            '${selectedRestaurant.lat!.toStringAsFixed(6)}, ${selectedRestaurant.lng!.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? DarkColors.textSecondary.withValues(
                                      alpha: 0.7,
                                    )
                                  : LightColors.textSecondary.withValues(
                                      alpha: 0.7,
                                    ),
                            ),
                          ),
                        ],
                      ] else
                        Text(
                          'orders.addressNotAvailable'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: isDark
                                ? DarkColors.textSecondary
                                : LightColors.textSecondary,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  void _initializeWorkHours(RestaurantModel restaurant) {
    _disposeWorkHourDrafts();

    final legacyOpen = restaurant.openingHours;
    final legacyClose = restaurant.closingHours;
    final hasLegacyHours =
        legacyOpen != null &&
        legacyOpen.isNotEmpty &&
        legacyClose != null &&
        legacyClose.isNotEmpty;

    for (final day in _weekdayKeys) {
      final periods =
          _convertUtcWorkHoursToLocal(restaurant.workHours)[day] ??
          const <WorkHourPeriod>[];
      if (periods.isNotEmpty) {
        _workHourDrafts[day] = periods
            .map(
              (period) =>
                  _WorkHourDraft(open: period.open, close: period.close),
            )
            .toList();
      } else if (hasLegacyHours && day != 'saturday' && day != 'sunday') {
        _workHourDrafts[day] = [
          _WorkHourDraft(open: legacyOpen, close: legacyClose),
        ];
      } else {
        _workHourDrafts[day] = [];
      }
    }
  }

  void _disposeWorkHourDrafts() {
    for (final shifts in _workHourDrafts.values) {
      for (final shift in shifts) {
        shift.dispose();
      }
    }
    _workHourDrafts.clear();
  }

  Widget _buildWorkHoursSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'settings.businessHours'.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: isDark
                ? DarkColors.textSecondary
                : LightColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),
        ..._weekdayKeys.map((day) {
          return Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _buildWorkHoursDay(day, isDark),
          );
        }),
        if (_workHoursError != null) ...[
          SizedBox(height: 2.h),
          Text(
            _workHoursError!,
            style: TextStyle(fontSize: 12.sp, color: AppColors.error),
          ),
        ],
      ],
    );
  }

  Widget _buildWorkHoursDay(String day, bool isDark) {
    final shifts = _workHourDrafts[day] ?? [];
    final isOpen = shifts.isNotEmpty;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _dayLabel(day),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              ),
              Text(
                isOpen ? 'common.open'.tr : 'common.closed'.tr,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
              SizedBox(width: 8.w),
              Switch.adaptive(
                value: isOpen,
                onChanged: (value) => _setDayOpen(day, value),
              ),
            ],
          ),
          if (isOpen) ...[
            SizedBox(height: 8.h),
            ...shifts.map((shift) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _buildTimeField(
                        label: 'settings.openTime'.tr,
                        controller: shift.openController,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _buildTimeField(
                        label: 'settings.closeTime'.tr,
                        controller: shift.closeController,
                        isDark: isDark,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    SizedBox(
                      width: 40.w,
                      height: 48.h,
                      child: IconButton(
                        tooltip: 'common.delete'.tr,
                        onPressed: () => _removeShift(day, shift),
                        icon: Icon(
                          Icons.delete_outline,
                          size: 20.w,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: () => _addShift(day),
                icon: Icon(Icons.add, size: 18.w, color: primaryColor),
                label: Text('settings.addShift'.tr),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required TextEditingController controller,
    required bool isDark,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.datetime,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
        LengthLimitingTextInputFormatter(5),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: '09:00',
        filled: true,
        fillColor: isDark ? DarkColors.background : LightColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(
            color: isDark ? DarkColors.border : LightColors.border,
          ),
        ),
      ),
    );
  }

  void _setDayOpen(String day, bool isOpen) {
    setState(() {
      _workHoursError = null;
      final shifts = _workHourDrafts[day] ?? [];
      if (isOpen && shifts.isEmpty) {
        _workHourDrafts[day] = [_WorkHourDraft(open: '09:00', close: '22:00')];
      } else if (!isOpen) {
        for (final shift in shifts) {
          shift.dispose();
        }
        _workHourDrafts[day] = [];
      }
    });
  }

  void _addShift(String day) {
    setState(() {
      _workHoursError = null;
      _workHourDrafts.putIfAbsent(day, () => []);
      _workHourDrafts[day]!.add(_WorkHourDraft(open: '09:00', close: '22:00'));
    });
  }

  void _removeShift(String day, _WorkHourDraft shift) {
    setState(() {
      _workHoursError = null;
      _workHourDrafts[day]?.remove(shift);
      shift.dispose();
    });
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    bool isDark, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: keyboardType == TextInputType.phone
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: isDark ? DarkColors.surface : LightColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.r),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    final selectedRestaurant = ref.read(selectedRestaurantProvider);
    if (selectedRestaurant == null) return;

    final validationError = _validateWorkHours();
    if (validationError != null) {
      setState(() => _workHoursError = validationError);
      return;
    }

    setState(() => _isSaving = true);

    // Prepare update data
    // Note: Address is a foreign key reference - include the existing ID if present
    final addressId = selectedRestaurant.addressData?.id;
    final data = {
      'name': _nameController.text.trim(),
      if (_phoneController.text.trim().isNotEmpty)
        'phone': _phoneController.text.trim(),
      if (_logoUrl != null && _logoUrl!.isNotEmpty) 'logo': _logoUrl,
      'work_hours': _buildWorkHoursPayload(),
      // Keep existing address ID if we have one
      if (addressId != null) 'address': addressId,
    };

    // Call the API to update restaurant
    await ref
        .read(restaurantProvider.notifier)
        .patchRestaurant(selectedRestaurant.id, data);

    setState(() => _isSaving = false);

    // Check if update was successful
    final restaurantState = ref.read(restaurantProvider);
    if (restaurantState is RestaurantError) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(restaurantState.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('settings.settingsSaved'.tr)));
      }
    }
  }

  String? _validateWorkHours() {
    final allowedDays = _weekdayKeys.toSet();
    final timePattern = RegExp(r'^([01]\d|2[0-3]):[0-5]\d$');

    for (final day in _workHourDrafts.keys) {
      if (!allowedDays.contains(day)) {
        return 'settings.invalidWorkHoursDay'.tr;
      }
    }

    for (final day in _weekdayKeys) {
      final shifts = _workHourDrafts[day] ?? [];
      for (final shift in shifts) {
        final open = shift.openController.text.trim();
        final close = shift.closeController.text.trim();

        if (!timePattern.hasMatch(open) || !timePattern.hasMatch(close)) {
          return 'settings.invalidWorkHoursFormat'.tr;
        }

        if (_minutesSinceMidnight(open) >= _minutesSinceMidnight(close)) {
          return 'settings.invalidWorkHoursRange'.trParams({
            'day': _dayLabel(day),
          });
        }
      }
    }

    return null;
  }

  Map<String, dynamic> _buildWorkHoursPayload() {
    final utcWorkHours = {
      for (final day in _weekdayKeys) day: <Map<String, String>>[],
    };

    for (final localDay in _weekdayKeys) {
      final shifts = _workHourDrafts[localDay] ?? [];
      for (final shift in shifts) {
        final utcPeriod = _convertLocalShiftToUtcPeriod(
          localDay: localDay,
          open: shift.openController.text.trim(),
          close: shift.closeController.text.trim(),
        );
        utcWorkHours[utcPeriod.day]!.add({
          'open': utcPeriod.open,
          'close': utcPeriod.close,
        });
      }
    }

    for (final shifts in utcWorkHours.values) {
      shifts.sort(
        (a, b) => _minutesSinceMidnight(
          a['open']!,
        ).compareTo(_minutesSinceMidnight(b['open']!)),
      );
    }

    return utcWorkHours;
  }

  int _minutesSinceMidnight(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  _UtcWorkHourPeriod _convertLocalShiftToUtcPeriod({
    required String localDay,
    required String open,
    required String close,
  }) {
    final dayIndex = _weekdayKeys.indexOf(localDay);
    final openParts = open.split(':').map(int.parse).toList();
    final closeParts = close.split(':').map(int.parse).toList();
    final openLocal = DateTime(
      _referenceMonday.year,
      _referenceMonday.month,
      _referenceMonday.day + dayIndex,
      openParts[0],
      openParts[1],
    );
    final closeLocal = DateTime(
      _referenceMonday.year,
      _referenceMonday.month,
      _referenceMonday.day + dayIndex,
      closeParts[0],
      closeParts[1],
    );
    final openUtc = openLocal.toUtc();
    final closeUtc = closeLocal.toUtc();

    return _UtcWorkHourPeriod(
      day: _weekdayKeys[openUtc.weekday - 1],
      open: _formatTime(openUtc),
      close: _formatTime(closeUtc),
    );
  }

  Map<String, List<WorkHourPeriod>> _convertUtcWorkHoursToLocal(
    Map<String, List<WorkHourPeriod>> utcWorkHours,
  ) {
    final localWorkHours = {
      for (final day in _weekdayKeys) day: <WorkHourPeriod>[],
    };

    for (final utcDay in _weekdayKeys) {
      final periods = utcWorkHours[utcDay] ?? const <WorkHourPeriod>[];
      final dayIndex = _weekdayKeys.indexOf(utcDay);
      for (final period in periods) {
        if (!_isValidTime(period.open) || !_isValidTime(period.close)) {
          continue;
        }

        final openParts = period.open.split(':').map(int.parse).toList();
        final closeParts = period.close.split(':').map(int.parse).toList();
        final openUtc = DateTime.utc(
          _referenceMonday.year,
          _referenceMonday.month,
          _referenceMonday.day + dayIndex,
          openParts[0],
          openParts[1],
        );
        var closeUtc = DateTime.utc(
          _referenceMonday.year,
          _referenceMonday.month,
          _referenceMonday.day + dayIndex,
          closeParts[0],
          closeParts[1],
        );
        if (!closeUtc.isAfter(openUtc)) {
          closeUtc = closeUtc.add(const Duration(days: 1));
        }

        final openLocal = openUtc.toLocal();
        final closeLocal = closeUtc.toLocal();
        localWorkHours[_weekdayKeys[openLocal.weekday - 1]]!.add(
          WorkHourPeriod(
            open: _formatTime(openLocal),
            close: _formatTime(closeLocal),
          ),
        );
      }
    }

    for (final periods in localWorkHours.values) {
      periods.sort(
        (a, b) => _minutesSinceMidnight(
          a.open,
        ).compareTo(_minutesSinceMidnight(b.open)),
      );
    }

    return localWorkHours;
  }

  bool _isValidTime(String time) {
    return RegExp(r'^([01]\d|2[0-3]):[0-5]\d$').hasMatch(time);
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String _dayLabel(String day) {
    switch (day) {
      case 'monday':
        return 'settings.weekdays.monday'.tr;
      case 'tuesday':
        return 'settings.weekdays.tuesday'.tr;
      case 'wednesday':
        return 'settings.weekdays.wednesday'.tr;
      case 'thursday':
        return 'settings.weekdays.thursday'.tr;
      case 'friday':
        return 'settings.weekdays.friday'.tr;
      case 'saturday':
        return 'settings.weekdays.saturday'.tr;
      case 'sunday':
        return 'settings.weekdays.sunday'.tr;
      default:
        return day;
    }
  }
}

class _WorkHourDraft {
  _WorkHourDraft({required String open, required String close})
    : openController = TextEditingController(text: open),
      closeController = TextEditingController(text: close);

  final TextEditingController openController;
  final TextEditingController closeController;

  void dispose() {
    openController.dispose();
    closeController.dispose();
  }
}

class _UtcWorkHourPeriod {
  const _UtcWorkHourPeriod({
    required this.day,
    required this.open,
    required this.close,
  });

  final String day;
  final String open;
  final String close;
}
