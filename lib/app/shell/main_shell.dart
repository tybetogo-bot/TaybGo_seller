import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/i18n.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/theme/theme.dart';
import '../../features/notifications/application/notifications_notifier.dart';
import '../../features/tour/utils/tour_keys.dart';
import '../router/routes.dart';

/// Main shell with bottom navigation
class MainShell extends ConsumerStatefulWidget {
  const MainShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  @override
  void initState() {
    super.initState();

    // Set up notification tap handler for navigation.
    PushNotificationService.instance.onNotificationTap = (data) {
      final orderId = data['order_id']?.toString();
      if (orderId != null && mounted) {
        context.go(Routes.orderDetailsPath(orderId));
      } else if (mounted) {
        context.go(Routes.notifications);
      }
    };

    // Refresh in-app notifications when a push arrives in the foreground.
    PushNotificationService.instance.onForegroundMessage = (_) {
      ref.read(notificationsProvider.notifier).refresh();
    };
  }

  @override
  Widget build(BuildContext context) {
    // Watch the FCM token provider to trigger token retrieval & backend
    // registration whenever the main shell is active.
    final fcmState = ref.watch(fcmTokenProvider);
    debugPrint('🎯 [MainShell] build() → fcmToken state: '
        '${fcmState.when(data: (t) => "token=${t?.substring(0, 10) ?? "null"}...", loading: () => "loading", error: (e, _) => "ERROR: $e")}');

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: const AppBottomNavBar(),
    );
  }
}

/// Bottom navigation bar
class AppBottomNavBar extends ConsumerWidget {
  const AppBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.toString();
    
    // Watch translations to rebuild when locale changes
    ref.watch(translationsLoadedProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.bottomNavBackground : LightColors.bottomNavBackground,
        boxShadow: AppShadows.bottomNav,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                key: TourKeys.homeBottomNavKey,
                icon: Icons.home_outlined,
                activeIcon: Icons.home_rounded,
                label: 'navigation.home'.tr,
                isSelected: location.startsWith(Routes.home),
                onTap: () => context.go(Routes.home),
              ),
              _NavItem(
                key: TourKeys.ordersBottomNavKey,
                icon: Icons.receipt_long_outlined,
                activeIcon: Icons.receipt_long_rounded,
                label: 'navigation.orders'.tr,
                isSelected: location.startsWith(Routes.orders),
                onTap: () => context.go(Routes.orders),
              ),
              _NavItem(
                key: TourKeys.menuBottomNavKey,
                icon: Icons.restaurant_menu_outlined,
                activeIcon: Icons.restaurant_menu_rounded,
                label: 'navigation.menu'.tr,
                isSelected: location.startsWith(Routes.menu),
                onTap: () => context.go(Routes.menu),
              ),
              _NavItem(
                key: TourKeys.profileBottomNavKey,
                icon: Icons.person_outline_rounded,
                activeIcon: Icons.person_rounded,
                label: 'navigation.profile'.tr,
                isSelected: location.startsWith(Routes.profile),
                onTap: () => context.go(Routes.profile),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    Key? key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isSelected
        ? theme.colorScheme.primary
        : (isDark ? DarkColors.bottomNavInactive : LightColors.bottomNavInactive);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(maxWidth: 80.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: color,
              size: 24.w,
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
