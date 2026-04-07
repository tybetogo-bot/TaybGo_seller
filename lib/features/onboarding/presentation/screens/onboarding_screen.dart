import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/routes.dart';
import '../../../../core/data/countries.dart';
import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/application/auth_state.dart';
import '../../../auth/presentation/widgets/country_picker_widget.dart';
import '../../../auth/presentation/widgets/language_selector.dart';
import '../../../orders/data/models/order_model.dart';
import '../../../orders/presentation/widgets/address_search_widget.dart';
import '../../../restaurant/application/restaurant_state.dart';
import '../../application/onboarding_notifier.dart';
import '../widgets/document_upload_widget.dart';

/// Onboarding screen for new sellers
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _profileFormKey = GlobalKey<FormState>();
  final _restaurantFormKey = GlobalKey<FormState>();
  final _pageController = PageController();

  // Profile fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _birthdateController = TextEditingController();
  DateTime? _selectedBirthdate;
  String? _registrationDocumentUrl;
  bool _isDocumentUploading = false;

  // Restaurant fields
  final _restaurantNameController = TextEditingController();
  final _restaurantPhoneController = TextEditingController();
  Country _restaurantPhoneCountry = Countries.austria;

  // Address data from AddressSearchWidget
  AddressModel? _selectedAddress;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    // Pre-fill phone from auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = ref.read(authProvider);
      if (authState is AuthAuthenticated) {
        _phoneController.text = authState.phone;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    _restaurantNameController.dispose();
    _restaurantPhoneController.dispose();
    super.dispose();
  }

  void _goToStep(int step) {
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _nextStep() {
    if (_isDocumentUploading) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait for document upload to finish.'),
        ),
      );
      return;
    }

    if (_currentStep == 0) {
      if (!_profileFormKey.currentState!.validate()) return;
      if (_registrationDocumentUrl == null ||
          _registrationDocumentUrl!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('validation.imageRequired'.tr),
            backgroundColor: AppColors.error,
          ),
        );
        return;
      }
      _goToStep(1);
    }
  }

  void _previousStep() {
    if (_currentStep == 1) {
      _goToStep(0);
    }
  }

  Future<void> _submitOnboarding() async {
    if (!_restaurantFormKey.currentState!.validate()) return;

    if (_registrationDocumentUrl == null || _registrationDocumentUrl!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('validation.imageRequired'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedAddress == null ||
        _selectedAddress!.street.isEmpty ||
        _selectedAddress!.city == null ||
        _selectedAddress!.city!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('onboarding.addressRequired'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_selectedAddress!.latitude == null ||
        _selectedAddress!.longitude == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('onboarding.coordinatesRequired'.tr),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final address = _selectedAddress!;

    final restaurantPhone =
        '${_restaurantPhoneCountry.dialCode}${_restaurantPhoneController.text.trim()}';

    await ref
        .read(onboardingProvider.notifier)
        .submitOnboarding(
          name: _nameController.text.trim(),
          phone: _phoneController.text.trim(),
          birthdate: _selectedBirthdate,
          registrationDocumentUrl: _registrationDocumentUrl!,
          restaurantName: _restaurantNameController.text.trim(),
          restaurantPhone: restaurantPhone,
          streetName: address.street,
          houseNumber: address.building,
          city: address.city!,
          postalCode: address.postalCode ?? '',
          country: address.country,
          fullAddress: [
            address.street,
            address.building,
            address.city,
            address.postalCode,
            address.country,
          ].where((s) => s != null && s.isNotEmpty).join(', '),
          lat: address.latitude,
          lng: address.longitude,
        );
  }

  Future<void> _logout() async {
    await ref.read(authProvider.notifier).logout();
    if (mounted) {
      context.go(Routes.login);
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        final isDark = Theme.of(dialogContext).brightness == Brightness.dark;

        return AlertDialog(
          title: Text('auth.logout'.tr),
          content: Text('auth.logoutConfirm'.tr),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(
                'common.cancel'.tr,
                style: TextStyle(
                  color: isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await _logout();
              },
              child: Text(
                'auth.logout'.tr,
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthdate ?? DateTime(now.year - 18, 1, 1);

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (!mounted || pickedDate == null) return;

    setState(() {
      _selectedBirthdate = pickedDate;
      _birthdateController.text = _formatDate(pickedDate);
    });
  }

  String _formatDate(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Listen to onboarding state changes
    ref.listen(onboardingProvider, (previous, next) {
      if (next is OnboardingSuccess) {
        // Refresh restaurants and navigate to pending review
        ref.read(restaurantProvider.notifier).fetchRestaurants();
        context.go(Routes.pendingReview);
      } else if (next is OnboardingError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    final onboardingState = ref.watch(onboardingProvider);
    final isLoading = onboardingState is OnboardingLoading;

    return AppScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with language selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    'onboarding.title'.tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? DarkColors.textPrimary
                          : LightColors.textPrimary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (_currentStep > 0)
                        IconButton(
                          onPressed: isLoading ? null : _previousStep,
                          icon: Icon(Icons.arrow_back, size: 24.w),
                        )
                      else
                        SizedBox(width: 48.w),
                      const LanguageSelector(),
                    ],
                  ),
                ],
              ),
            ),

            // Step indicator
            _buildStepIndicator(isDark),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildProfileStep(isDark, isLoading),
                  _buildRestaurantStep(isDark, isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(bool isDark) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 16.h),
      child: Row(
        children: [
          _buildStepDot(0, isDark),
          Expanded(
            child: Container(
              height: 2.h,
              color: _currentStep >= 1
                  ? Theme.of(context).colorScheme.primary
                  : (isDark ? DarkColors.border : LightColors.border),
            ),
          ),
          _buildStepDot(1, isDark),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step, bool isDark) {
    final isActive = _currentStep >= step;
    final primary = Theme.of(context).colorScheme.primary;

    return Column(
      children: [
        Container(
          width: 32.w,
          height: 32.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? primary : Colors.transparent,
            border: Border.all(
              color: isActive
                  ? primary
                  : (isDark ? DarkColors.border : LightColors.border),
              width: 2,
            ),
          ),
          child: Center(
            child: isActive
                ? Icon(
                    _currentStep > step ? Icons.check : Icons.circle,
                    size: _currentStep > step ? 18.w : 8.w,
                    color: Colors.white,
                  )
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          step == 0
              ? 'onboarding.profileStep'.tr
              : 'onboarding.restaurantStep'.tr,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isActive
                ? primary
                : (isDark
                      ? DarkColors.textSecondary
                      : LightColors.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileStep(bool isDark, bool isLoading) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _profileFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),

            // Title
            Text(
              'onboarding.profileTitle'.tr,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'onboarding.profileSubtitle'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // Name
            AppTextField(
              controller: _nameController,
              label: 'onboarding.yourName'.tr,
              hint: 'onboarding.enterYourName'.tr,
              prefixIcon: Icons.person_outline,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'validation.required'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Phone (pre-filled, read-only)
            AppTextField(
              controller: _phoneController,
              label: 'onboarding.phoneNumber'.tr,
              hint: 'onboarding.phoneNumber'.tr,
              prefixIcon: Icons.phone_outlined,
              readOnly: true,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16.h),

            // Birthdate (optional)
            AppTextField(
              controller: _birthdateController,
              label: 'Birthdate (${'common.optional'.tr})',
              hint: 'YYYY-MM-DD',
              prefixIcon: Icons.cake_outlined,
              readOnly: true,
              onTap: _pickBirthdate,
            ),
            SizedBox(height: 16.h),

            Text(
              'onboarding.documentTitle'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'onboarding.documentDescription'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            SizedBox(height: 12.h),
            DocumentUploadWidget(
              titleText: 'onboarding.documentTitle'.tr,
              helperText: 'onboarding.documentUploadHelper'.tr,
              icon: Icons.description_outlined,
              isRequired: true,
              initialDocumentUrl: _registrationDocumentUrl,
              onDocumentUploaded: (url) {
                setState(() => _registrationDocumentUrl = url);
              },
              onDocumentRemoved: () {
                setState(() => _registrationDocumentUrl = null);
              },
              onUploadStateChanged: (isUploading) {
                if (!mounted) return;
                setState(() => _isDocumentUploading = isUploading);
              },
            ),
            SizedBox(height: 32.h),

            // Next button
            AppButton(
              label: 'common.next'.tr,
              onPressed: (isLoading || _isDocumentUploading) ? null : _nextStep,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: isLoading ? null : _showLogoutConfirmation,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  backgroundColor: isDark
                      ? DarkColors.surface
                      : LightColors.surface,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.r),
                    side: BorderSide(
                      color: AppColors.error.withValues(alpha: 0.35),
                    ),
                  ),
                ),
                icon: Icon(Icons.logout_rounded, size: 18.w),
                label: Text(
                  'auth.logout'.tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRestaurantStep(bool isDark, bool isLoading) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Form(
        key: _restaurantFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 8.h),

            // Title
            Text(
              'onboarding.restaurantTitle'.tr,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'onboarding.restaurantSubtitle'.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            SizedBox(height: 24.h),

            // Restaurant name
            AppTextField(
              controller: _restaurantNameController,
              label: 'onboarding.restaurantName'.tr,
              hint: 'onboarding.enterRestaurantName'.tr,
              prefixIcon: Icons.storefront_outlined,
              textCapitalization: TextCapitalization.words,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'validation.required'.tr;
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),

            // Restaurant phone
            Text(
              'onboarding.restaurantPhone'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? DarkColors.textSecondary
                    : LightColors.textSecondary,
              ),
            ),
            SizedBox(height: 6.h),
            PhoneInputField(
              controller: _restaurantPhoneController,
              selectedCountry: _restaurantPhoneCountry,
              onCountrySelected: (country) {
                setState(() => _restaurantPhoneCountry = country);
              },
            ),
            SizedBox(height: 24.h),

            // Address section label
            Text(
              'onboarding.restaurantAddress'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? DarkColors.textPrimary
                    : LightColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),

            // Address search widget
            AddressSearchWidget(
              onAddressSelected: (address) {
                setState(() => _selectedAddress = address);
              },
              initialAddress: _selectedAddress,
            ),

            SizedBox(height: 32.h),

            // Submit button
            AppButton(
              label: 'onboarding.createRestaurant'.tr,
              onPressed: isLoading ? null : _submitOnboarding,
              isLoading: isLoading,
            ),

            // Loading step info
            if (isLoading) ...[
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  _getLoadingStepText(ref.watch(onboardingProvider)),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: isDark
                        ? DarkColors.textSecondary
                        : LightColors.textSecondary,
                  ),
                ),
              ),
            ],

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  String _getLoadingStepText(OnboardingState state) {
    if (state is OnboardingLoading) {
      switch (state.step) {
        case 'profile':
          return 'onboarding.creatingProfile'.tr;
        case 'address':
          return 'onboarding.creatingAddress'.tr;
        case 'restaurant':
          return 'onboarding.creatingRestaurant'.tr;
      }
    }
    return 'common.loading'.tr;
  }
}
