import 'package:teybatseller/app/router/routes.dart';
import 'package:teybatseller/features/tour/application/tour_state.dart';
import 'package:teybatseller/features/tour/data/models/tour_step_model.dart';
import 'package:teybatseller/features/tour/utils/tour_keys.dart';

class TourSteps {
  /// Get tour steps based on tour type
  static List<TourStepModel> getStepsForTourType(TourType tourType) {
    switch (tourType) {
      case TourType.fullApp:
        return fullAppTour;
      case TourType.ordersQuick:
        return ordersQuickTour;
      case TourType.menuQuick:
        return menuQuickTour;
    }
  }

  /// Full app tour - comprehensive walkthrough (16 steps)
  static final List<TourStepModel> fullAppTour = [
    // Step 1: Welcome
    const TourStepModel(
      id: 'welcome',
      titleKey: 'tour.welcome.title',
      descriptionKey: 'tour.welcome.description',
      targetScreen: Routes.home,
      highlightArea: HighlightArea.fullScreen,
      tooltipPosition: TooltipPosition.auto,
      actions: [TourAction.observe],
      canSkip: false,
      estimatedDuration: Duration(seconds: 10),
    ),

    // Step 2: Home Screen Stats
    TourStepModel(
      id: 'home_stats',
      titleKey: 'tour.homeStats.title',
      descriptionKey: 'tour.homeStats.description',
      targetScreen: Routes.home,
      targetWidgetKey: TourKeys.homeStatsCardKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 3: Navigate to Orders
    TourStepModel(
      id: 'navigate_to_orders',
      titleKey: 'tour.navigateToOrders.title',
      descriptionKey: 'tour.navigateToOrders.description',
      targetScreen: Routes.home,
      targetWidgetKey: TourKeys.ordersBottomNavKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.top,
      actions: const [TourAction.tap],
      estimatedDuration: const Duration(seconds: 5),
    ),

    // Step 4: Pending Orders List
    TourStepModel(
      id: 'pending_orders',
      titleKey: 'tour.pendingOrders.title',
      descriptionKey: 'tour.pendingOrders.description',
      targetScreen: Routes.orders,
      targetWidgetKey: TourKeys.pendingOrdersListKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
      estimatedDuration: const Duration(seconds: 10),
    ),

    // Step 5: Order Card Details
    TourStepModel(
      id: 'order_details',
      titleKey: 'tour.orderDetails.title',
      descriptionKey: 'tour.orderDetails.description',
      targetScreen: Routes.orders,
      targetWidgetKey: TourKeys.firstOrderCardKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.tap],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 6: Swipe Actions
    const TourStepModel(
      id: 'swipe_actions',
      titleKey: 'tour.swipeActions.title',
      descriptionKey: 'tour.swipeActions.description',
      targetScreen: Routes.orders,
      highlightArea: HighlightArea.fullScreen,
      tooltipPosition: TooltipPosition.auto,
      actions: [TourAction.swipe],
      estimatedDuration: Duration(seconds: 10),
    ),

    // Step 7: Active Orders
    TourStepModel(
      id: 'active_orders',
      titleKey: 'tour.activeOrders.title',
      descriptionKey: 'tour.activeOrders.description',
      targetScreen: Routes.orders,
      targetWidgetKey: TourKeys.activeOrdersListKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 8: Navigate to Menu
    TourStepModel(
      id: 'navigate_to_menu',
      titleKey: 'tour.navigateToMenu.title',
      descriptionKey: 'tour.navigateToMenu.description',
      targetScreen: Routes.orders,
      targetWidgetKey: TourKeys.menuBottomNavKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.top,
      actions: const [TourAction.tap],
      estimatedDuration: const Duration(seconds: 5),
    ),

    // Step 9: Menu Items List
    TourStepModel(
      id: 'menu_items',
      titleKey: 'tour.menuItems.title',
      descriptionKey: 'tour.menuItems.description',
      targetScreen: Routes.menu,
      targetWidgetKey: TourKeys.menuItemsListKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
      estimatedDuration: const Duration(seconds: 10),
    ),

    // Step 10: Item Availability Toggle
    TourStepModel(
      id: 'item_availability',
      titleKey: 'tour.itemAvailability.title',
      descriptionKey: 'tour.itemAvailability.description',
      targetScreen: Routes.menu,
      targetWidgetKey: TourKeys.firstMenuItemKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.interact],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 11: Menu Categories
    TourStepModel(
      id: 'menu_categories',
      titleKey: 'tour.menuCategories.title',
      descriptionKey: 'tour.menuCategories.description',
      targetScreen: Routes.menu,
      targetWidgetKey: TourKeys.menuCategoriesKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 12: Navigate to Profile
    TourStepModel(
      id: 'navigate_to_profile',
      titleKey: 'tour.navigateToProfile.title',
      descriptionKey: 'tour.navigateToProfile.description',
      targetScreen: Routes.menu,
      targetWidgetKey: TourKeys.profileBottomNavKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.top,
      actions: const [TourAction.tap],
      estimatedDuration: const Duration(seconds: 5),
    ),

    // Step 13: Quick Stats
    TourStepModel(
      id: 'quick_stats',
      titleKey: 'tour.quickStats.title',
      descriptionKey: 'tour.quickStats.description',
      targetScreen: Routes.profile,
      targetWidgetKey: TourKeys.quickStatsKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 14: Settings Options
    TourStepModel(
      id: 'settings_options',
      titleKey: 'tour.settingsOptions.title',
      descriptionKey: 'tour.settingsOptions.description',
      targetScreen: Routes.profile,
      targetWidgetKey: TourKeys.settingsOptionsKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 15: Theme Customization
    TourStepModel(
      id: 'theme_customization',
      titleKey: 'tour.themeCustomization.title',
      descriptionKey: 'tour.themeCustomization.description',
      targetScreen: Routes.profile,
      targetWidgetKey: TourKeys.themeSettingKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.tap],
      estimatedDuration: const Duration(seconds: 8),
    ),

    // Step 16: Tour Complete
    const TourStepModel(
      id: 'tour_complete',
      titleKey: 'tour.complete.title',
      descriptionKey: 'tour.complete.description',
      targetScreen: Routes.profile,
      highlightArea: HighlightArea.fullScreen,
      tooltipPosition: TooltipPosition.auto,
      actions: [TourAction.observe],
      canSkip: false,
      estimatedDuration: Duration(seconds: 10),
    ),
  ];

  /// Orders quick tour - focused on order management (5 steps)
  static final List<TourStepModel> ordersQuickTour = [
    const TourStepModel(
      id: 'orders_welcome',
      titleKey: 'tour.ordersWelcome.title',
      descriptionKey: 'tour.ordersWelcome.description',
      targetScreen: Routes.orders,
      highlightArea: HighlightArea.fullScreen,
      tooltipPosition: TooltipPosition.auto,
      actions: [TourAction.observe],
      canSkip: false,
    ),

    TourStepModel(
      id: 'orders_pending',
      titleKey: 'tour.ordersPending.title',
      descriptionKey: 'tour.ordersPending.description',
      targetScreen: Routes.orders,
      targetWidgetKey: TourKeys.pendingOrdersListKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
    ),

    TourStepModel(
      id: 'orders_card',
      titleKey: 'tour.ordersCard.title',
      descriptionKey: 'tour.ordersCard.description',
      targetScreen: Routes.orders,
      targetWidgetKey: TourKeys.firstOrderCardKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.tap, TourAction.swipe],
    ),

    TourStepModel(
      id: 'orders_active',
      titleKey: 'tour.ordersActive.title',
      descriptionKey: 'tour.ordersActive.description',
      targetScreen: Routes.orders,
      targetWidgetKey: TourKeys.activeOrdersListKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
    ),

    const TourStepModel(
      id: 'orders_complete',
      titleKey: 'tour.ordersComplete.title',
      descriptionKey: 'tour.ordersComplete.description',
      targetScreen: Routes.orders,
      highlightArea: HighlightArea.fullScreen,
      tooltipPosition: TooltipPosition.auto,
      actions: [TourAction.observe],
      canSkip: false,
    ),
  ];

  /// Menu quick tour - focused on menu management (4 steps)
  static final List<TourStepModel> menuQuickTour = [
    const TourStepModel(
      id: 'menu_welcome',
      titleKey: 'tour.menuWelcome.title',
      descriptionKey: 'tour.menuWelcome.description',
      targetScreen: Routes.menu,
      highlightArea: HighlightArea.fullScreen,
      tooltipPosition: TooltipPosition.auto,
      actions: [TourAction.observe],
      canSkip: false,
    ),

    TourStepModel(
      id: 'menu_list',
      titleKey: 'tour.menuList.title',
      descriptionKey: 'tour.menuList.description',
      targetScreen: Routes.menu,
      targetWidgetKey: TourKeys.menuItemsListKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.observe],
    ),

    TourStepModel(
      id: 'menu_toggle',
      titleKey: 'tour.menuToggle.title',
      descriptionKey: 'tour.menuToggle.description',
      targetScreen: Routes.menu,
      targetWidgetKey: TourKeys.firstMenuItemKey,
      highlightArea: HighlightArea.rectangle,
      tooltipPosition: TooltipPosition.bottom,
      actions: const [TourAction.interact],
    ),

    const TourStepModel(
      id: 'menu_complete',
      titleKey: 'tour.menuComplete.title',
      descriptionKey: 'tour.menuComplete.description',
      targetScreen: Routes.menu,
      highlightArea: HighlightArea.fullScreen,
      tooltipPosition: TooltipPosition.auto,
      actions: [TourAction.observe],
      canSkip: false,
    ),
  ];
}
