import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../../notifications/application/notifications_notifier.dart';
import '../../../notifications/data/models/notification_model.dart';

/// Notifications screen with real notifications from API
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsState = ref.watch(notificationsProvider);
    final unreadCount = notificationsState.unreadCount;

    return Scaffold(
      backgroundColor: isDark ? DarkColors.background : LightColors.background,
      appBar: AppBar(
        title: Text('notifications.title'.tr),
        backgroundColor: isDark ? DarkColors.background : LightColors.background,
        elevation: 0,
        actions: [
          if (unreadCount > 0)
            TextButton(
              onPressed: () {
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: Text(
                'notifications.markAllRead'.tr,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.primary,
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.settings_outlined,
              color: isDark ? DarkColors.textPrimary : LightColors.textPrimary,
            ),
            onPressed: () => _openSettings(context),
          ),
        ],
      ),
      body: _buildBody(context, ref, notificationsState, isDark),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    NotificationsState state,
    bool isDark,
  ) {
    if (state.isLoading && state.notifications.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.notifications.isEmpty) {
      return _buildErrorState(context, ref, state.error!, isDark);
    }

    if (state.notifications.isEmpty) {
      return _buildEmptyState(isDark);
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(notificationsProvider.notifier).refresh(),
      child: Column(
        children: [
          // Error banner if there's an error but we have cached data
          if (state.error != null)
            _buildErrorBanner(context, ref, state.error!, isDark),
          // Content
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification = state.notifications[index];
                return _NotificationTile(
                  notification: notification,
                  isDark: isDark,
                  onTap: () {
                    if (!notification.isRead) {
                      ref
                          .read(notificationsProvider.notifier)
                          .markAsRead(notification.id);
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(
    BuildContext context,
    WidgetRef ref,
    String error,
    bool isDark,
  ) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: AppColors.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'errors.failedToLoadNotifications'.tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: TextStyle(
                fontSize: 13.sp,
                color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(notificationsProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: Text('common.retry'.tr),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorBanner(
    BuildContext context,
    WidgetRef ref,
    String error,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.15),
        border: Border(
          bottom: BorderSide(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            size: 18.w,
            color: AppColors.error,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'errors.failedToLoadNotifications'.tr,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.error,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              ref.read(notificationsProvider.notifier).refresh();
            },
            child: Text(
              'common.retry'.tr,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none_outlined,
            size: 64.w,
            color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
          ),
          SizedBox(height: 16.h),
          Text(
            'notifications.noNotifications'.tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: isDark ? DarkColors.textSecondary : LightColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'notifications.noNotificationsDesc'.tr,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: isDark ? DarkColors.textTertiary : LightColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }

  void _openSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _NotificationSettingsSheet(),
    );
  }
}

/// Individual notification tile widget
class _NotificationTile extends StatelessWidget {
  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  final NotificationModel notification;
  final bool isDark;
  final VoidCallback onTap;

  IconData _getIcon() {
    // Determine icon based on notification data or title
    final title = notification.title.toLowerCase();
    if (title.contains('order')) {
      if (title.contains('new') || title.contains('received')) {
        return Icons.shopping_bag;
      }
      if (title.contains('deliver') || title.contains('shipped')) {
        return Icons.local_shipping;
      }
      if (title.contains('cancel')) {
        return Icons.cancel_outlined;
      }
      return Icons.receipt_long;
    }
    if (title.contains('promo') || title.contains('discount') || title.contains('offer')) {
      return Icons.local_offer;
    }
    if (title.contains('menu') || title.contains('item')) {
      return Icons.restaurant_menu;
    }
    if (title.contains('driver')) {
      return Icons.delivery_dining;
    }
    return Icons.notifications_outlined;
  }

  Color _getIconColor() {
    final title = notification.title.toLowerCase();
    if (title.contains('order')) {
      if (title.contains('new') || title.contains('received')) {
        return AppColors.primary;
      }
      if (title.contains('deliver') || title.contains('shipped')) {
        return AppColors.success;
      }
      if (title.contains('cancel')) {
        return AppColors.error;
      }
      return AppColors.info;
    }
    if (title.contains('promo') || title.contains('discount') || title.contains('offer')) {
      return AppColors.warning;
    }
    if (title.contains('menu') || title.contains('item')) {
      return AppColors.success;
    }
    return AppColors.info;
  }

  String _getTimeAgo() {
    final diff = DateTime.now().difference(notification.createdAt);
    if (diff.inMinutes < 1) {
      return 'notifications.justNow'.tr;
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h';
    } else {
      return '${diff.inDays}d';
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: notification.isRead
              ? Colors.transparent
              : (isDark
                  ? AppColors.primary.withValues(alpha: 0.05)
                  : AppColors.primary.withValues(alpha: 0.03)),
          border: Border(
            bottom: BorderSide(
              color: isDark ? DarkColors.border : LightColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44.w,
              height: 44.w,
              decoration: BoxDecoration(
                color: _getIconColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getIcon(),
                color: _getIconColor(),
                size: 22.w,
              ),
            ),
            SizedBox(width: 12.w),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: isDark
                                ? DarkColors.textPrimary
                                : LightColors.textPrimary,
                          ),
                        ),
                      ),
                      Text(
                        _getTimeAgo(),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: isDark
                              ? DarkColors.textTertiary
                              : LightColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notification.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isDark
                          ? DarkColors.textSecondary
                          : LightColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            // Unread indicator
            if (!notification.isRead) ...[
              SizedBox(width: 8.w),
              Container(
                width: 8.w,
                height: 8.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Notification settings bottom sheet
class _NotificationSettingsSheet extends ConsumerStatefulWidget {
  const _NotificationSettingsSheet();

  @override
  ConsumerState<_NotificationSettingsSheet> createState() =>
      _NotificationSettingsSheetState();
}

class _NotificationSettingsSheetState
    extends ConsumerState<_NotificationSettingsSheet> {
  bool _newOrders = true;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _sound = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    ref.watch(translationsLoadedProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? DarkColors.surface : LightColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Column(
            children: [
              // Handle bar
              Container(
                margin: EdgeInsets.symmetric(vertical: 12.h),
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: isDark ? DarkColors.border : LightColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'notifications.settings'.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? DarkColors.textPrimary
                            : LightColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(color: isDark ? DarkColors.border : LightColors.border),
              // Settings list
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'notifications.notificationTypes'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.shopping_bag,
                      iconColor: AppColors.primary,
                      title: 'notifications.newOrders'.tr,
                      subtitle: 'notifications.newOrdersDesc'.tr,
                      value: _newOrders,
                      onChanged: (v) => setState(() => _newOrders = v),
                      isDark: isDark,
                    ),
                    _SettingsTile(
                      icon: Icons.local_shipping,
                      iconColor: AppColors.info,
                      title: 'notifications.orderUpdates'.tr,
                      subtitle: 'notifications.orderUpdatesDesc'.tr,
                      value: _orderUpdates,
                      onChanged: (v) => setState(() => _orderUpdates = v),
                      isDark: isDark,
                    ),
                    _SettingsTile(
                      icon: Icons.local_offer,
                      iconColor: AppColors.warning,
                      title: 'notifications.promotions'.tr,
                      subtitle: 'notifications.promotionsDesc'.tr,
                      value: _promotions,
                      onChanged: (v) => setState(() => _promotions = v),
                      isDark: isDark,
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.all(16.w),
                      child: Text(
                        'notifications.notificationSettings'.tr,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? DarkColors.textSecondary
                              : LightColors.textSecondary,
                        ),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.volume_up,
                      iconColor: AppColors.success,
                      title: 'notifications.sound'.tr,
                      subtitle: 'notifications.soundDesc'.tr,
                      value: _sound,
                      onChanged: (v) => setState(() => _sound = v),
                      isDark: isDark,
                    ),
                    _SettingsTile(
                      icon: Icons.vibration,
                      iconColor: Colors.purple,
                      title: 'notifications.vibration'.tr,
                      subtitle: 'notifications.vibrationDesc'.tr,
                      value: _vibration,
                      onChanged: (v) => setState(() => _vibration = v),
                      isDark: isDark,
                    ),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Settings tile with icon and switch
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? DarkColors.textPrimary
                        : LightColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: isDark
                        ? DarkColors.textTertiary
                        : LightColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
