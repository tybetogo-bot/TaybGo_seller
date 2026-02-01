import 'package:flutter/material.dart';

/// Centralized GlobalKeys for tour highlighting
/// These keys should be assigned to widgets that the tour needs to highlight
class TourKeys {
  // Home Screen Keys
  static final GlobalKey homeStatsCardKey = GlobalKey(debugLabel: 'homeStatsCard');
  static final GlobalKey homePendingOrdersKey = GlobalKey(debugLabel: 'homePendingOrders');

  // Orders Screen Keys
  static final GlobalKey ordersTabKey = GlobalKey(debugLabel: 'ordersTab');
  static final GlobalKey pendingOrdersTabKey = GlobalKey(debugLabel: 'pendingOrdersTab');
  static final GlobalKey activeOrdersTabKey = GlobalKey(debugLabel: 'activeOrdersTab');
  static final GlobalKey pendingOrdersListKey = GlobalKey(debugLabel: 'pendingOrdersList');
  static final GlobalKey activeOrdersListKey = GlobalKey(debugLabel: 'activeOrdersList');
  static final GlobalKey firstOrderCardKey = GlobalKey(debugLabel: 'firstOrderCard');

  // Create Order Screen Keys
  static final GlobalKey createOrderButtonKey = GlobalKey(debugLabel: 'createOrderButton');
  static final GlobalKey scanOrderCardKey = GlobalKey(debugLabel: 'scanOrderCard');
  static final GlobalKey createOrderFormKey = GlobalKey(debugLabel: 'createOrderForm');

  // Knowledge Base Screen Keys
  static final GlobalKey knowledgeBaseRowKey = GlobalKey(debugLabel: 'knowledgeBaseRow');
  static final GlobalKey knowledgeBaseTourSectionKey = GlobalKey(debugLabel: 'knowledgeBaseTourSection');

  // Order Details Screen Keys
  static final GlobalKey orderStatusTimelineKey = GlobalKey(debugLabel: 'orderStatusTimeline');
  static final GlobalKey orderItemsSectionKey = GlobalKey(debugLabel: 'orderItemsSection');
  static final GlobalKey orderPaymentSummaryKey = GlobalKey(debugLabel: 'orderPaymentSummary');

  // Menu Item Detail Screen Keys
  static final GlobalKey menuItemFormKey = GlobalKey(debugLabel: 'menuItemForm');
  static final GlobalKey menuItemPricingKey = GlobalKey(debugLabel: 'menuItemPricing');

  // Menu Screen Keys
  static final GlobalKey menuTabKey = GlobalKey(debugLabel: 'menuTab');
  static final GlobalKey menuItemsListKey = GlobalKey(debugLabel: 'menuItemsList');
  static final GlobalKey firstMenuItemKey = GlobalKey(debugLabel: 'firstMenuItem');
  static final GlobalKey menuCategoriesKey = GlobalKey(debugLabel: 'menuCategories');

  // Profile Screen Keys
  static final GlobalKey profileTabKey = GlobalKey(debugLabel: 'profileTab');
  static final GlobalKey quickStatsKey = GlobalKey(debugLabel: 'quickStats');
  static final GlobalKey settingsOptionsKey = GlobalKey(debugLabel: 'settingsOptions');
  static final GlobalKey themeSettingKey = GlobalKey(debugLabel: 'themeSetting');
  static final GlobalKey accentColorSettingKey = GlobalKey(debugLabel: 'accentColorSetting');
  static final GlobalKey languageSettingKey = GlobalKey(debugLabel: 'languageSetting');

  // Bottom Navigation Keys
  static final GlobalKey homeBottomNavKey = GlobalKey(debugLabel: 'homeBottomNav');
  static final GlobalKey ordersBottomNavKey = GlobalKey(debugLabel: 'ordersBottomNav');
  static final GlobalKey menuBottomNavKey = GlobalKey(debugLabel: 'menuBottomNav');
  static final GlobalKey profileBottomNavKey = GlobalKey(debugLabel: 'profileBottomNav');

  /// Helper method to get the RenderBox and position of a widget by key
  static Rect? getWidgetBounds(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return null;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    return Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
  }
}
