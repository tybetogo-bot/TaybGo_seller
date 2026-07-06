import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/responsive/responsive.dart';
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
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: Breakpoints.maxContentWidth,
          ),
          child: _buildBody(context, ref, notificationsState, isDark),
        ),
      ),
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
                backgroundColor: Theme.of(context).colorScheme.primary,
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

  Color _getIconColor(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final title = notification.title.toLowerCase();
    if (title.contains('order')) {
      if (title.contains('new') || title.contains('received')) {
        return primaryColor;
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
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.05)
                  : Theme.of(context).colorScheme.primary.withValues(alpha: 0.03)),
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
                color: _getIconColor(context).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                _getIcon(),
                color: _getIconColor(context),
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
                  color: Theme.of(context).colorScheme.primary,
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

