import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../core/i18n/i18n.dart';
import '../../core/responsive/responsive.dart';
import '../../core/services/location_permission_service.dart';
import '../../core/services/push_notification_service.dart';
import '../../core/theme/theme.dart';
import '../../features/notifications/application/notifications_notifier.dart';
import '../../features/orders/application/orders_notifier.dart';
import '../../features/tour/utils/tour_keys.dart';
import '../../features/orders/presentation/widgets/incoming_order_alert.dart';
import '../../shared/widgets/location_warning_banner.dart';
import '../router/routes.dart';

/// Main shell.
///
/// Layout reorganizes by form factor:
/// - **Phone**: bottom navigation bar (the original layout)
/// - **Tablet**: compact icon-only [NavigationRail] on the leading edge
/// - **Desktop**: extended [NavigationRail] with labels
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell>
    with WidgetsBindingObserver {
  bool _locationRequestScheduled = false;
  late final void Function(RemoteMessage message) _foregroundMessageHandler;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _startNotificationsPolling();
    });

    // Refresh in-app notifications when a push arrives in the foreground.
    _foregroundMessageHandler = (message) {
      ref.read(notificationsProvider.notifier).refresh();

      final notificationType = message.data['type']
          ?.toString()
          .trim()
          .toLowerCase();
      if (notificationType == 'support_message_from_staff' ||
          notificationType == 'support_ticket_updated') {
        _showSupportNotificationBanner(message);
      }

      if (notificationType == 'new_order' ||
          notificationType == 'new-order' ||
          notificationType == 'order_created' ||
          notificationType == 'order-created') {
        // The alert host compares the refreshed snapshot with its baseline, so
        // only a genuinely new pending order opens the full-screen experience.
        unawaited(ref.read(ordersProvider.notifier).refreshOrders());
      }
    };
    PushNotificationService.instance.onForegroundMessage =
        _foregroundMessageHandler;
  }

  void _startNotificationsPolling() {
    ref.read(notificationsPollingProvider.notifier).start();
    unawaited(ref.read(notificationsProvider.notifier).refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _startNotificationsPolling();
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      ref.read(notificationsPollingProvider.notifier).stop();
    }
  }

  void _showSupportNotificationBanner(RemoteMessage message) {
    if (!mounted) return;

    final title = message.notification?.title?.trim();
    final body = message.notification?.body?.trim();
    final displayTitle = title == null || title.isEmpty
        ? 'notifications.title'.tr
        : title;
    final displayBody = body == null || body.isEmpty ? null : body;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                displayTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              if (displayBody != null)
                Text(displayBody, maxLines: 2, overflow: TextOverflow.ellipsis),
            ],
          ),
          action: SnackBarAction(
            label: 'common.open'.tr,
            onPressed: () => _openNotificationTarget(message.data),
          ),
          duration: const Duration(seconds: 8),
        ),
      );
  }

  void _openNotificationTarget(Map<String, dynamic> data) {
    final notificationType = data['type']?.toString().trim().toLowerCase();
    final ticketId = _asInt(data['ticket_id'] ?? data['ticketId']);
    final messageId = _asInt(data['message_id'] ?? data['messageId']);

    if ((notificationType == 'support_message_from_staff' ||
            notificationType == 'support_ticket_updated') &&
        ticketId != null) {
      context.go(
        Routes.supportTicketDetailNotificationPath(
          ticketId.toString(),
          messageId: messageId,
        ),
      );
      unawaited(
        ref.read(notificationsProvider.notifier).markPushTargetAsRead(data),
      );
      return;
    }

    context.go(Routes.notifications);
  }

  Future<void> _requestLocationPermissionAfterLogin() async {
    final autoRequestNotifier = ref.read(
      locationPermissionAutoRequestProvider.notifier,
    );

    if (ref.read(locationPermissionAutoRequestProvider) !=
        LocationPermissionAutoRequestState.pending) {
      _locationRequestScheduled = false;
      return;
    }

    autoRequestNotifier.markRequesting();

    try {
      await ref
          .read(locationPermissionProvider.notifier)
          .requestPermissionIfNeeded();
    } finally {
      autoRequestNotifier.clear();
      _locationRequestScheduled = false;
    }
  }

  @override
  void dispose() {
    if (PushNotificationService.instance.onForegroundMessage ==
        _foregroundMessageHandler) {
      PushNotificationService.instance.onForegroundMessage = null;
    }
    WidgetsBinding.instance.removeObserver(this);
    ref.read(notificationsPollingProvider.notifier).stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the FCM token provider to trigger token retrieval & backend
    // registration whenever the main shell is active.
    final fcmState = ref.watch(fcmTokenProvider);
    final autoRequestState = ref.watch(locationPermissionAutoRequestProvider);

    debugPrint(
      '[MainShell] fcmToken state: '
      '${fcmState.when(data: (t) => t == null ? "token=null" : "token=${t.substring(0, t.length < 10 ? t.length : 10)}...", loading: () => "loading", error: (e, _) => "ERROR: $e")}',
    );

    if (autoRequestState == LocationPermissionAutoRequestState.pending &&
        !_locationRequestScheduled) {
      _locationRequestScheduled = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _requestLocationPermissionAfterLogin();
        }
      });
    }

    final formFactor = context.formFactor;
    final useRail = formFactor != FormFactor.phone;
    final extended = formFactor == FormFactor.desktop;

    final shell = useRail
        ? Scaffold(
            body: SafeArea(
              bottom: false,
              child: Row(
                children: [
                  _AppNavigationRail(extended: extended),
                  const VerticalDivider(thickness: 1, width: 1),
                  Expanded(
                    child: Column(
                      children: [
                        const LocationWarningBanner(),
                        Expanded(child: widget.child),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
        : Scaffold(
            // Phone layout: keep the original bottom-navigation shell.
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  const LocationWarningBanner(),
                  Expanded(child: widget.child),
                ],
              ),
            ),
            bottomNavigationBar: const AppBottomNavBar(),
          );

    return IncomingOrderAlertHost(child: shell);
  }
}

int? _asInt(dynamic value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '');
}

/// Top-level destinations shown in both the bottom nav and side rail.
class _Destination {
  _Destination({
    required this.iconData,
    required this.activeIconData,
    required this.labelKey,
    required this.route,
    this.tourKey,
  });

  final IconData iconData;
  final IconData activeIconData;
  final String labelKey;
  final String route;
  final Key? tourKey;
}

final List<_Destination> _destinations = [
  _Destination(
    iconData: Icons.home_outlined,
    activeIconData: Icons.home_rounded,
    labelKey: 'navigation.home',
    route: Routes.home,
    tourKey: TourKeys.homeBottomNavKey,
  ),
  _Destination(
    iconData: Icons.receipt_long_outlined,
    activeIconData: Icons.receipt_long_rounded,
    labelKey: 'navigation.orders',
    route: Routes.orders,
    tourKey: TourKeys.ordersBottomNavKey,
  ),
  _Destination(
    iconData: Icons.restaurant_menu_outlined,
    activeIconData: Icons.restaurant_menu_rounded,
    labelKey: 'navigation.menu',
    route: Routes.menu,
    tourKey: TourKeys.menuBottomNavKey,
  ),
  _Destination(
    iconData: Icons.person_outline_rounded,
    activeIconData: Icons.person_rounded,
    labelKey: 'navigation.profile',
    route: Routes.profile,
    tourKey: TourKeys.profileBottomNavKey,
  ),
];

int _selectedDestinationIndex(String location) {
  for (var i = 0; i < _destinations.length; i++) {
    if (location.startsWith(_destinations[i].route)) return i;
  }
  return 0;
}

/// Bottom navigation bar (phone layout).
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
        color: isDark
            ? DarkColors.bottomNavBackground
            : LightColors.bottomNavBackground,
        boxShadow: AppShadows.bottomNav,
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              for (final d in _destinations)
                _NavItem(
                  key: d.tourKey,
                  icon: d.iconData,
                  activeIcon: d.activeIconData,
                  label: d.labelKey.tr,
                  isSelected: location.startsWith(d.route),
                  onTap: () => context.go(d.route),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Side navigation rail (tablet + desktop layouts).
///
/// Uses Material 3 [NavigationRail]. The rail is extended (icon + label
/// inline) on desktop and compact (icon only with tooltips) on tablet.
class _AppNavigationRail extends ConsumerWidget {
  const _AppNavigationRail({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final location = GoRouterState.of(context).uri.toString();
    final selectedIndex = _selectedDestinationIndex(location);

    // Watch translations to rebuild when locale changes
    ref.watch(translationsLoadedProvider);

    final background = isDark
        ? DarkColors.bottomNavBackground
        : LightColors.bottomNavBackground;
    final primary = theme.colorScheme.primary;
    final unselected = isDark
        ? DarkColors.bottomNavInactive
        : LightColors.bottomNavInactive;

    return Material(
      color: background,
      child: SafeArea(
        right: false,
        child: NavigationRail(
          extended: extended,
          minWidth: 72,
          minExtendedWidth: 220,
          backgroundColor: background,
          selectedIndex: selectedIndex,
          onDestinationSelected: (i) => context.go(_destinations[i].route),
          labelType: extended
              ? NavigationRailLabelType.none
              : NavigationRailLabelType.all,
          // Subtle green-tinted indicator pill instead of the dark Material
          // default (which renders as a near-black blob on light backgrounds).
          indicatorColor: primary.withValues(alpha: isDark ? 0.20 : 0.12),
          indicatorShape: const StadiumBorder(),
          selectedIconTheme: IconThemeData(color: primary, size: 26),
          unselectedIconTheme: IconThemeData(color: unselected, size: 24),
          selectedLabelTextStyle: TextStyle(
            color: primary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
          unselectedLabelTextStyle: TextStyle(
            color: unselected,
            fontWeight: FontWeight.w500,
            fontSize: 13,
          ),
          destinations: [
            for (final d in _destinations)
              NavigationRailDestination(
                icon: Icon(d.iconData, key: d.tourKey),
                selectedIcon: Icon(d.activeIconData),
                label: Text(d.labelKey.tr),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

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
        : (isDark
              ? DarkColors.bottomNavInactive
              : LightColors.bottomNavInactive);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        constraints: BoxConstraints(maxWidth: 80.w),
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(isSelected ? activeIcon : icon, color: color, size: 24.w),
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
