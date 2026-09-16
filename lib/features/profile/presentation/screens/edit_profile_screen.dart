import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/network/user_api.dart';
import '../../../../core/responsive/responsive.dart';
import '../../../../core/theme/theme.dart';
import '../../../menu/presentation/widgets/image_picker_widget.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../../restaurant/data/models/restaurant_model.dart';
import '../../application/user_profile_notifier.dart';

/// Unified seller and restaurant edit page.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _sellerNameController = TextEditingController();
  final _sellerPhoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _birthdateController = TextEditingController();
  final _restaurantNameController = TextEditingController();
  final _restaurantPhoneController = TextEditingController();
  final Map<String, List<_WorkHourDraft>> _workHourDrafts = {};

  bool _isInitialized = false;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  bool _workHoursExpanded = false;
  String? _initializedRestaurantId;
  String? _logoUrl;
  String? _workHoursError;
  DateTime? _selectedBirthdate;
  bool _deliveryEnabled = false;

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
    _sellerNameController.dispose();
    _sellerPhoneController.dispose();
    _emailController.dispose();
    _birthdateController.dispose();
    _restaurantNameController.dispose();
    _restaurantPhoneController.dispose();
    _disposeWorkHourDrafts();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final userProfileState = ref.watch(userProfileProvider);
    final selectedRestaurant = ref.watch(selectedRestaurantProvider);
    final sellerProfileAsync = ref.watch(sellerProfileProvider);
    final sellerProfile = sellerProfileAsync.maybeWhen(
      data: (profile) => profile,
      orElse: () => null,
    );
    final userProfile = userProfileState.profile;

    if (!_isInitialized &&
        userProfile != null &&
        selectedRestaurant != null &&
        !_isSaving) {
      _initializeForm(
        userProfile: userProfile,
        sellerProfile: sellerProfile,
        restaurant: selectedRestaurant,
      );
    }

    if (_initializedRestaurantId != null &&
        selectedRestaurant != null &&
        userProfile != null &&
        selectedRestaurant.id != _initializedRestaurantId &&
        !_isSaving) {
      _initializeForm(
        userProfile: userProfile,
        sellerProfile: sellerProfile,
        restaurant: selectedRestaurant,
      );
    }

    final effectiveBirthdate =
        _selectedBirthdate ??
        sellerProfile?.birthdate ??
        userProfile?.birthdate;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('profile.editProfile'.tr),
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
              onPressed: selectedRestaurant == null || userProfile == null
                  ? null
                  : _saveProfile,
              child: Text(
                'common.save'.tr,
                style: TextStyle(color: primaryColor),
              ),
            ),
        ],
      ),
      body: userProfileState.isLoading && userProfile == null
          ? const Center(child: CircularProgressIndicator())
          : selectedRestaurant == null
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: Breakpoints.maxContentWidth,
                ),
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 24.h),
                  children: [
                    _ProfileHeroCard(
                      isDark: isDark,
                      primaryColor: primaryColor,
                      sellerName: _sellerNameController.text.trim().isNotEmpty
                          ? _sellerNameController.text.trim()
                          : (userProfile?.name ?? ''),
                      restaurantName: _restaurantNameController.text.trim(),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'profile.sellerDetails'.tr,
                      child: Column(
                        children: [
                          _EditableField(
                            label: 'common.name'.tr,
                            controller: _sellerNameController,
                            isDark: isDark,
                          ),
                          SizedBox(height: 12.h),
                          _EditableField(
                            label: 'auth.phoneNumber'.tr,
                            controller: _sellerPhoneController,
                            isDark: isDark,
                            keyboardType: TextInputType.phone,
                            textDirection: ui.TextDirection.ltr,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s]'),
                              ),
                            ],
                          ),
                          SizedBox(height: 12.h),
                          _EditableField(
                            label: 'auth.email'.tr,
                            controller: _emailController,
                            isDark: isDark,
                            keyboardType: TextInputType.emailAddress,
                            readOnly: true,
                            suffixIcon: Icons.lock_outline,
                          ),
                          SizedBox(height: 12.h),
                          _EditableField(
                            label: 'profile.birthdate'.tr,
                            controller: _birthdateController,
                            isDark: isDark,
                            readOnly: true,
                            onTap: _pickBirthdate,
                            suffixIcon: Icons.calendar_today_outlined,
                          ),
                          if (effectiveBirthdate != null) ...[
                            SizedBox(height: 10.h),
                            Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: _InlinePill(
                                text:
                                    '${'onboarding.age'.tr}: ${_calculateAge(effectiveBirthdate)}',
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'settings.restaurantInfo'.tr,
                      child: Column(
                        children: [
                          _EditableField(
                            label: 'settings.restaurantName'.tr,
                            controller: _restaurantNameController,
                            isDark: isDark,
                          ),
                          SizedBox(height: 12.h),
                          _EditableField(
                            label: 'auth.phoneNumber'.tr,
                            controller: _restaurantPhoneController,
                            isDark: isDark,
                            keyboardType: TextInputType.phone,
                            textDirection: ui.TextDirection.ltr,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9+\-\s]'),
                              ),
                            ],
                          ),
                          SizedBox(height: 14.h),
                          _ToggleRow(
                            label: 'profile.deliveryEnabled'.tr,
                            value: _deliveryEnabled,
                            isDark: isDark,
                            onChanged: (value) {
                              setState(() => _deliveryEnabled = value);
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'settings.restaurantLogo'.tr,
                      child: ImagePickerWidget(
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
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      padding: EdgeInsets.zero,
                      child: Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: _workHoursExpanded,
                          onExpansionChanged: (value) {
                            setState(() => _workHoursExpanded = value);
                          },
                          tilePadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 4.h,
                          ),
                          childrenPadding: EdgeInsets.fromLTRB(
                            16.w,
                            0,
                            16.w,
                            16.h,
                          ),
                          title: Text(
                            'settings.businessHours'.tr,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? DarkColors.textPrimary
                                  : LightColors.textPrimary,
                            ),
                          ),
                          subtitle: Text(
                            _workHoursSummary(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: isDark
                                  ? DarkColors.textSecondary
                                  : LightColors.textSecondary,
                            ),
                          ),
                          children: [
                            ..._weekdayKeys.map((day) {
                              return Padding(
                                padding: EdgeInsets.only(bottom: 10.h),
                                child: _buildWorkHoursDay(day, isDark),
                              );
                            }),
                            if (_workHoursError != null)
                              Align(
                                alignment: AlignmentDirectional.centerStart,
                                child: Text(
                                  _workHoursError!,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'orders.address'.tr,
                      child: _AddressCard(
                        restaurant: selectedRestaurant,
                        isDark: isDark,
                        primaryColor: primaryColor,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    _SectionCard(
                      title: 'onboarding.documentTitle'.tr,
                      child: _RegistrationDocumentStatusCard(
                        isDark: isDark,
                        sellerProfileAsync: sellerProfileAsync,
                        onRetry: () => ref.invalidate(sellerProfileProvider),
                        onOpenDocument: _openDocument,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  void _initializeForm({
    required UserProfile userProfile,
    required BasicProfile? sellerProfile,
    required RestaurantModel restaurant,
  }) {
    _sellerNameController.text = sellerProfile?.name ?? userProfile.name ?? '';
    _sellerPhoneController.text = sellerProfile?.phone ?? userProfile.phone;
    _emailController.text = userProfile.email ?? '';
    _selectedBirthdate = sellerProfile?.birthdate ?? userProfile.birthdate;
    _birthdateController.text = _selectedBirthdate != null
        ? DateFormat('MMM d, yyyy').format(_selectedBirthdate!)
        : '';
    _restaurantNameController.text = restaurant.name;
    _restaurantPhoneController.text = restaurant.phone ?? '';
    _logoUrl = restaurant.logoUrl;
    _deliveryEnabled = restaurant.deliveryEnabled ?? false;
    _initializeWorkHours(restaurant);
    _initializedRestaurantId = restaurant.id;
    _isInitialized = true;
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthdate ?? DateTime(now.year - 21, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900, 1, 1),
      lastDate: now,
    );

    if (picked == null) return;

    setState(() {
      _selectedBirthdate = picked;
      _birthdateController.text = DateFormat('MMM d, yyyy').format(picked);
    });
  }

  Future<void> _saveProfile() async {
    final selectedRestaurant = ref.read(selectedRestaurantProvider);
    final userProfile = ref.read(userProfileProvider).profile;
    if (selectedRestaurant == null || userProfile == null) return;

    final validationError = _validateWorkHours();
    if (validationError != null) {
      setState(() => _workHoursError = validationError);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(validationError),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    String? errorMessage;

    final updatedUser = await ref
        .read(userProfileProvider.notifier)
        .updateProfile(
          name: _sellerNameController.text.trim(),
        );
    if (!updatedUser) {
      errorMessage =
          ref.read(userProfileProvider).error ?? 'errors.serverError'.tr;
    }

    if (errorMessage == null) {
      final updatedSeller = await ref
          .read(userProfileProvider.notifier)
          .updateSellerProfile({
            'name': _sellerNameController.text.trim(),
            'phone': _sellerPhoneController.text.trim(),
            if (_selectedBirthdate != null)
              'birthdate': _formatApiDate(_selectedBirthdate!),
          });

      if (!updatedSeller) {
        errorMessage =
            ref.read(userProfileProvider).error ?? 'errors.serverError'.tr;
      }
    }

    if (errorMessage == null) {
      final restaurantResult = await ref
          .read(restaurantRepositoryProvider)
          .updateRestaurant(
            selectedRestaurant.id,
            _buildRestaurantUpdatePayload(selectedRestaurant),
          );

      if (restaurantResult.failure != null || restaurantResult.data == null) {
        errorMessage =
            restaurantResult.failure?.message ?? 'errors.serverError'.tr;
      } else {
        ref
            .read(restaurantProvider.notifier)
            .syncUpdatedRestaurant(restaurantResult.data!);
      }
    }

    ref.invalidate(sellerProfileProvider);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: AppColors.error),
      );
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('settings.settingsSaved'.tr)));
  }

  Map<String, dynamic> _buildRestaurantUpdatePayload(
    RestaurantModel restaurant,
  ) {
    return {
      'name': _restaurantNameController.text.trim(),
      if (_restaurantPhoneController.text.trim().isNotEmpty)
        'phone': _restaurantPhoneController.text.trim(),
      if (_logoUrl != null && _logoUrl!.trim().isNotEmpty) 'logo': _logoUrl,
      'delivery_enabled': _deliveryEnabled,
      'work_hours': _buildWorkHoursPayload(),
      if (restaurant.addressData?.id != null)
        'address_id': restaurant.addressData!.id,
    };
  }

  void _initializeWorkHours(RestaurantModel restaurant) {
    _disposeWorkHourDrafts();

    final localWorkHours = _convertUtcWorkHoursToLocal(restaurant.workHours);
    final legacyOpen = restaurant.openingHours;
    final legacyClose = restaurant.closingHours;
    final hasLegacyHours =
        legacyOpen != null &&
        legacyOpen.isNotEmpty &&
        legacyClose != null &&
        legacyClose.isNotEmpty;

    for (final day in _weekdayKeys) {
      final periods = localWorkHours[day] ?? const <WorkHourPeriod>[];
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

  Widget _buildWorkHoursDay(String day, bool isDark) {
    final shifts = _workHourDrafts[day] ?? [];
    final isOpen = shifts.isNotEmpty;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background : LightColors.background,
        borderRadius: BorderRadius.circular(12.r),
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
                    fontSize: 13.sp,
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
            SizedBox(height: 10.h),
            ...shifts.map((shift) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _EditableField(
                        label: 'settings.openTime'.tr,
                        controller: shift.openController,
                        isDark: isDark,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        hintText: '09:00',
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: _EditableField(
                        label: 'settings.closeTime'.tr,
                        controller: shift.closeController,
                        isDark: isDark,
                        keyboardType: TextInputType.datetime,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9:]')),
                          LengthLimitingTextInputFormatter(5),
                        ],
                        hintText: '22:00',
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
                          size: 18.w,
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
              child: TextButton(
                onPressed: () => _addShift(day),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'settings.addShift'.tr,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ],
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

        if (_minutesSinceMidnight(open) == _minutesSinceMidnight(close)) {
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
    var closeLocal = DateTime(
      _referenceMonday.year,
      _referenceMonday.month,
      _referenceMonday.day + dayIndex,
      closeParts[0],
      closeParts[1],
    );
    if (!closeLocal.isAfter(openLocal)) {
      closeLocal = closeLocal.add(const Duration(days: 1));
    }

    final openUtc = openLocal.toUtc();
    final closeUtc = closeLocal.toUtc();

    return _UtcWorkHourPeriod(
      day: _weekdayKeys[openUtc.weekday - 1],
      open: _formatTime(openUtc),
      close: _formatTime(closeUtc),
    );
  }

  Future<void> _openDocument(BuildContext context, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.invalidDocumentUrl'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!launched && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.documentOpenFailed'.tr),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  String _formatApiDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  int _calculateAge(DateTime birthdate) {
    final now = DateTime.now();
    var age = now.year - birthdate.year;
    final birthdayPassed =
        now.month > birthdate.month ||
        (now.month == birthdate.month && now.day >= birthdate.day);
    if (!birthdayPassed) {
      age -= 1;
    }
    return age;
  }

  String _workHoursSummary() {
    final openDays = _workHourDrafts.values
        .where((shifts) => shifts.isNotEmpty)
        .length;
    if (openDays == 0) return 'common.closed'.tr;
    return '$openDays/${_weekdayKeys.length}';
  }

  int _minutesSinceMidnight(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
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

class _ProfileHeroCard extends StatelessWidget {
  const _ProfileHeroCard({
    required this.isDark,
    required this.primaryColor,
    required this.sellerName,
    required this.restaurantName,
  });

  final bool isDark;
  final Color primaryColor;
  final String sellerName;
  final String restaurantName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.6,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.person_outline, size: 22.w, color: primaryColor),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sellerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  restaurantName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({this.title, required this.child, this.padding});

  final String? title;
  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
          width: 0.6,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 14.h),
          ],
          child,
        ],
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  const _EditableField({
    required this.label,
    required this.controller,
    required this.isDark,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
    this.textDirection,
    this.hintText,
  });

  final String label;
  final TextEditingController controller;
  final bool isDark;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final IconData? suffixIcon;
  final ui.TextDirection? textDirection;
  final String? hintText;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      readOnly: readOnly,
      onTap: onTap,
      textDirection: textDirection,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        filled: true,
        fillColor: isDark ? DarkColors.background : LightColors.background,
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
        suffixIcon: suffixIcon == null
            ? null
            : Icon(
                suffixIcon,
                size: 18.w,
                color: isDark
                    ? DarkColors.textTertiary
                    : LightColors.textTertiary,
              ),
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
            width: 1.2,
          ),
        ),
      ),
    );
  }
}

class _ToggleRow extends StatelessWidget {
  const _ToggleRow({
    required this.label,
    required this.value,
    required this.isDark,
    required this.onChanged,
  });

  final String label;
  final bool value;
  final bool isDark;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.background : LightColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? DarkColors.border : LightColors.border,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
          ),
          Text(
            value ? 'common.yes'.tr : 'common.no'.tr,
            style: TextStyle(
              fontSize: 12.sp,
              color: isDark
                  ? DarkColors.textSecondary
                  : LightColors.textSecondary,
            ),
          ),
          SizedBox(width: 8.w),
          Switch.adaptive(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _InlinePill extends StatelessWidget {
  const _InlinePill({required this.text, required this.isDark});

  final String text;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: isDark ? DarkColors.backgroundTertiary : LightColors.background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11.sp,
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.restaurant,
    required this.isDark,
    required this.primaryColor,
  });

  final RestaurantModel restaurant;
  final bool isDark;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    if (restaurant.addressData == null && restaurant.fullAddress.isEmpty) {
      return Text(
        'orders.addressNotAvailable'.tr,
        style: TextStyle(
          fontSize: 13.sp,
          color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
        ),
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 38.w,
          height: 38.w,
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.location_on_outlined,
            color: primaryColor,
            size: 20.w,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (restaurant.addressData?.streetName != null ||
                  restaurant.addressData?.houseNumber != null)
                Text(
                  [
                    restaurant.addressData?.streetName,
                    restaurant.addressData?.houseNumber,
                  ].where((s) => s != null && s.isNotEmpty).join(' '),
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              if (restaurant.addressData?.city != null ||
                  restaurant.addressData?.postalCode != null)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    [
                      restaurant.addressData?.postalCode,
                      restaurant.addressData?.city,
                    ].where((s) => s != null && s.isNotEmpty).join(' '),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ),
              if (restaurant.addressData?.country != null)
                Padding(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Text(
                    restaurant.addressData!.country!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ),
              if (restaurant.addressData == null &&
                  restaurant.fullAddress.isNotEmpty)
                Text(
                  restaurant.fullAddress,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
              if (restaurant.lat != null && restaurant.lng != null) ...[
                SizedBox(height: 6.h),
                Text(
                  '${restaurant.lat!.toStringAsFixed(6)}, ${restaurant.lng!.toStringAsFixed(6)}',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RegistrationDocumentStatusCard extends StatelessWidget {
  const _RegistrationDocumentStatusCard({
    required this.isDark,
    required this.sellerProfileAsync,
    required this.onRetry,
    required this.onOpenDocument,
  });

  final bool isDark;
  final AsyncValue<BasicProfile?> sellerProfileAsync;
  final VoidCallback onRetry;
  final Future<void> Function(BuildContext context, String url) onOpenDocument;

  @override
  Widget build(BuildContext context) {
    return sellerProfileAsync.when(
      loading: () => Row(
        children: [
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'common.loading'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
      error: (error, stackTrace) => Row(
        children: [
          Icon(Icons.error_outline, size: 18.w, color: AppColors.error),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              'profile.registrationDocumentUnavailable'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
          ),
          TextButton(onPressed: onRetry, child: Text('common.retry'.tr)),
        ],
      ),
      data: (profile) {
        final documentUrl = profile?.restaurantRegistrationLicenseDocument;
        final hasDocument = documentUrl != null && documentUrl.isNotEmpty;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.w,
              height: 38.w,
              decoration: BoxDecoration(
                color: hasDocument
                    ? AppColors.success.withValues(alpha: 0.12)
                    : Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                hasDocument
                    ? Icons.verified_outlined
                    : Icons.description_outlined,
                size: 20.w,
                color: hasDocument
                    ? AppColors.success
                    : Theme.of(context).colorScheme.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasDocument
                        ? 'profile.registrationDocumentAddedLocked'.tr
                        : 'profile.registrationDocumentMissing'.tr,
                    style: TextStyle(
                      fontSize: 12.5.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                  if (hasDocument) ...[
                    SizedBox(height: 10.h),
                    TextButton(
                      onPressed: () => onOpenDocument(context, documentUrl),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text('common.open'.tr),
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
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
