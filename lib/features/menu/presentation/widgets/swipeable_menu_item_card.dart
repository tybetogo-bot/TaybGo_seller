import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/i18n/i18n.dart';
import '../../../../core/theme/theme.dart';
import '../../application/menu_notifier.dart';
import '../../data/models/menu_item_model.dart';

/// Swipeable menu item card with clean design
/// - Swipe left: Toggle availability (activate/deactivate)
/// - Swipe right: Open item details
class SwipeableMenuItemCard extends ConsumerStatefulWidget {
  const SwipeableMenuItemCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final MenuItemModel item;
  final VoidCallback onTap;

  @override
  ConsumerState<SwipeableMenuItemCard> createState() =>
      _SwipeableMenuItemCardState();
}

class _SwipeableMenuItemCardState extends ConsumerState<SwipeableMenuItemCard>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  bool _isProcessing = false;
  double _dragExtent = 0.0;
  bool _isDragging = false;
  bool _hasPassedThreshold = false;

  // Swipe thresholds
  static const double _swipeThreshold = 0.25; // 25% of card width
  static const double _maxSwipeRatio = 0.4; // Max 40% swipe
  static const double _processingSwipeRatio = 0.35; // Locked position during processing

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOut),
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _isDragging = true;
    _dragExtent = 0.0;
    _hasPassedThreshold = false;
    HapticFeedback.selectionClick();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details, double maxWidth) {
    if (!_isDragging || _isProcessing) return;

    final previousExtent = _dragExtent;
    final newExtent = _dragExtent + (details.primaryDelta ?? 0);
    final maxDrag = maxWidth * _maxSwipeRatio;
    final clampedExtent = newExtent.clamp(-maxDrag, maxDrag);

    // Check if we're crossing the threshold
    final previousRatio = (previousExtent / maxWidth).abs();
    final newRatio = (clampedExtent / maxWidth).abs();
    final wasAboveThreshold = previousRatio >= _swipeThreshold;
    final isAboveThreshold = newRatio >= _swipeThreshold;

    // Haptic feedback when crossing threshold
    if (!wasAboveThreshold && isAboveThreshold && !_hasPassedThreshold) {
      HapticFeedback.mediumImpact();
      _hasPassedThreshold = true;
    } else if (wasAboveThreshold && !isAboveThreshold && _hasPassedThreshold) {
      HapticFeedback.lightImpact();
      _hasPassedThreshold = false;
    }

    setState(() {
      _dragExtent = clampedExtent;
    });
  }

  void _onHorizontalDragEnd(DragEndDetails details, double maxWidth) async {
    if (!_isDragging || _isProcessing) return;
    _isDragging = false;

    final swipeRatio = _dragExtent / maxWidth;

    // Swipe left threshold reached - toggle availability
    if (swipeRatio < -_swipeThreshold) {
      await _handleSwipeToToggleAvailability();
    }
    // Swipe right threshold reached - open details
    else if (swipeRatio > _swipeThreshold) {
      _resetSwipe();
      HapticFeedback.lightImpact();
      widget.onTap();
    }
    // Reset if threshold not reached
    else {
      _resetSwipe();
    }
  }

  void _resetSwipe() {
    setState(() {
      _dragExtent = 0.0;
    });
  }

  Future<void> _animateToPosition(double targetExtent) async {
    final startExtent = _dragExtent;
    _slideAnimation = Tween<double>(begin: startExtent, end: targetExtent).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    void listener() {
      setState(() {
        _dragExtent = _slideAnimation.value;
      });
    }

    _slideController.addListener(listener);
    _slideController.reset();
    await _slideController.forward();
    _slideController.removeListener(listener);
  }

  Future<void> _handleSwipeToToggleAvailability() async {
    if (_isProcessing) return;

    final previousAvailability = widget.item.isAvailable;

    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Get card width and animate to locked position
    final cardWidth = context.size?.width ?? 300;
    final targetExtent = -cardWidth * _processingSwipeRatio;

    // Smoothly animate to processing position
    await _animateToPosition(targetExtent);

    await ref.read(menuProvider.notifier).toggleItemAvailability(widget.item.id);

    if (mounted) {
      // Smoothly animate back to center
      await _animateToPosition(0.0);
      _showUndoSnackBar(previousAvailability);
      setState(() => _isProcessing = false);
    }
  }

  void _showUndoSnackBar(bool previousAvailability) {
    final itemId = widget.item.id;
    final newStatus = !previousAvailability;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              newStatus ? Icons.check_circle_rounded : Icons.remove_circle_rounded,
              color: Colors.white,
              size: 20.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                newStatus
                    ? 'menu.itemMarkedAvailable'.tr
                    : 'menu.itemMarkedUnavailable'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: newStatus ? AppColors.success : AppColors.warning,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 5),
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        action: SnackBarAction(
          label: 'common.undo'.tr,
          textColor: Colors.white,
          onPressed: () async {
            // Undo: revert availability
            HapticFeedback.lightImpact();
            await ref.read(menuProvider.notifier).toggleItemAvailability(itemId);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      Icon(
                        Icons.undo_rounded,
                        color: Colors.white,
                        size: 20.w,
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'menu.availabilityReverted'.tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.info,
                  behavior: SnackBarBehavior.floating,
                  duration: const Duration(seconds: 2),
                  margin: EdgeInsets.all(16.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;
    final item = widget.item;

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth;
        final swipeProgress = (_dragExtent / maxWidth).clamp(-1.0, 1.0);

        return AnimatedBuilder(
          animation: _scaleController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: GestureDetector(
            onTap: widget.onTap,
            onHorizontalDragStart: _onHorizontalDragStart,
            onHorizontalDragUpdate: (details) =>
                _onHorizontalDragUpdate(details, maxWidth),
            onHorizontalDragEnd: (details) =>
                _onHorizontalDragEnd(details, maxWidth),
            child: Container(
              margin: EdgeInsets.only(bottom: 8.h),
              child: Stack(
                children: [
                  // Background layers (revealed when swiping)
                  Positioned.fill(
                    child: _SwipeBackground(
                      swipeProgress: swipeProgress,
                      isDark: isDark,
                      isAvailable: item.isAvailable,
                      isProcessing: _isProcessing,
                    ),
                  ),

                  // Main card (slides on swipe)
                  Transform.translate(
                    offset: Offset(_dragExtent, 0),
                    child: Container(
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: isDark ? DarkColors.surface : LightColors.surface,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: item.isAvailable
                              ? (isDark ? DarkColors.border : LightColors.border)
                              : AppColors.warning.withValues(alpha: 0.3),
                          width: item.isAvailable ? 0.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Image
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? DarkColors.background
                                  : LightColors.background,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.r),
                              child: item.imageUrl != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(
                                          item.imageUrl!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, e, s) => Icon(
                                            Icons.restaurant,
                                            color: isDark
                                                ? DarkColors.textSecondary
                                                : LightColors.textSecondary,
                                            size: 24.w,
                                          ),
                                        ),
                                        if (!item.isAvailable)
                                          Container(
                                            color: Colors.black.withValues(alpha: 0.5),
                                            child: Center(
                                              child: Icon(
                                                Icons.block_rounded,
                                                color: Colors.white,
                                                size: 24.w,
                                              ),
                                            ),
                                          ),
                                      ],
                                    )
                                  : Icon(
                                      Icons.restaurant,
                                      color: isDark
                                          ? DarkColors.textSecondary
                                          : LightColors.textSecondary,
                                      size: 24.w,
                                    ),
                            ),
                          ),
                          SizedBox(width: 12.w),

                          // Name and price
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.name,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.w600,
                                          color: item.isAvailable
                                              ? (isDark
                                                  ? DarkColors.textPrimary
                                                  : LightColors.textPrimary)
                                              : (isDark
                                                  ? DarkColors.textTertiary
                                                  : LightColors.textTertiary),
                                        ),
                                      ),
                                    ),
                                    if (!item.isAvailable)
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 6.w,
                                          vertical: 2.h,
                                        ),
                                        decoration: BoxDecoration(
                                          color: AppColors.warning.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(4.r),
                                        ),
                                        child: Text(
                                          'menu.unavailable'.tr,
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.warning,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                SizedBox(height: 4.h),
                                Row(
                                  children: [
                                    Text(
                                      '€${item.price.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: item.isAvailable
                                            ? primaryColor
                                            : primaryColor.withValues(alpha: 0.5),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (item.preparationTime > 0) ...[
                                      SizedBox(width: 8.w),
                                      Icon(
                                        Icons.access_time_rounded,
                                        size: 12.w,
                                        color: isDark
                                            ? DarkColors.textTertiary
                                            : LightColors.textTertiary,
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        '${item.preparationTime}m',
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
                              ],
                            ),
                          ),

                          // Arrow indicator
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isDark
                                ? DarkColors.textTertiary
                                : LightColors.textTertiary,
                            size: 20.w,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Background revealed when swiping the card
class _SwipeBackground extends StatelessWidget {
  const _SwipeBackground({
    required this.swipeProgress,
    required this.isDark,
    required this.isAvailable,
    required this.isProcessing,
  });

  final double swipeProgress;
  final bool isDark;
  final bool isAvailable;
  final bool isProcessing;

  @override
  Widget build(BuildContext context) {
    final absProgress = swipeProgress.abs();
    final isSwipingRight = swipeProgress > 0;
    final hasReachedThreshold = absProgress >= 0.25;

    // Swipe left: Toggle availability
    // Swipe right: View details (blue)
    final Color backgroundColor;
    final IconData icon;
    final String label;

    if (!isSwipingRight) {
      // Swiping left - toggle availability
      if (isAvailable) {
        // Will mark as unavailable
        backgroundColor = hasReachedThreshold
            ? AppColors.warning
            : AppColors.warning.withValues(alpha: 0.7);
        icon = Icons.visibility_off_rounded;
        label = 'menu.markUnavailable'.tr;
      } else {
        // Will mark as available
        backgroundColor = hasReachedThreshold
            ? AppColors.success
            : AppColors.success.withValues(alpha: 0.7);
        icon = Icons.visibility_rounded;
        label = 'menu.markAvailable'.tr;
      }
    } else {
      // Swiping right - view details
      backgroundColor = hasReachedThreshold
          ? AppColors.info
          : AppColors.info.withValues(alpha: 0.7);
      icon = Icons.edit_rounded;
      label = 'menu.viewItem'.tr;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor.withValues(alpha: 0.9),
            backgroundColor,
          ],
          begin: isSwipingRight ? Alignment.centerLeft : Alignment.centerRight,
          end: isSwipingRight ? Alignment.centerRight : Alignment.centerLeft,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          children: [
            // Decorative pattern
            Positioned(
              right: isSwipingRight ? null : -15.w,
              left: isSwipingRight ? -15.w : null,
              top: -15.h,
              child: Opacity(
                opacity: 0.1,
                child: Icon(
                  icon,
                  size: 100.w,
                  color: Colors.white,
                ),
              ),
            ),

            // Content
            Positioned(
              left: isSwipingRight ? 20.w : null,
              right: isSwipingRight ? null : 20.w,
              top: 0,
              bottom: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: absProgress > 0.1 ? 1.0 : 0.0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!isSwipingRight) ...[
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                          isProcessing ? 'common.loading'.tr : label,
                          key: ValueKey(isProcessing),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                    ],
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.all(isProcessing ? 8.w : (hasReachedThreshold ? 10.w : 8.w)),
                      decoration: BoxDecoration(
                        color: Colors.white
                            .withValues(alpha: isProcessing ? 0.3 : (hasReachedThreshold ? 0.25 : 0.15)),
                        borderRadius:
                            BorderRadius.circular(isProcessing ? 16.r : (hasReachedThreshold ? 12.r : 8.r)),
                      ),
                      child: isProcessing
                          ? SizedBox(
                              width: 22.w,
                              height: 22.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Icon(
                              hasReachedThreshold
                                  ? (isSwipingRight
                                      ? Icons.arrow_forward_rounded
                                      : Icons.check_rounded)
                                  : icon,
                              color: Colors.white,
                              size: hasReachedThreshold ? 22.w : 18.w,
                            ),
                    ),
                    if (isSwipingRight) ...[
                      SizedBox(width: 8.w),
                      Text(
                        label,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Arrow indicators on edges
            if (absProgress > 0.05)
              Positioned(
                right: isSwipingRight ? 12.w : null,
                left: isSwipingRight ? null : 12.w,
                top: 0,
                bottom: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: hasReachedThreshold ? 1.0 : 0.5,
                  child: Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(
                        3,
                        (index) => AnimatedContainer(
                          duration: Duration(milliseconds: 100 + (index * 50)),
                          margin: EdgeInsets.symmetric(horizontal: 1.w),
                          child: Icon(
                            isSwipingRight
                                ? Icons.chevron_right_rounded
                                : Icons.chevron_left_rounded,
                            color: Colors.white.withValues(
                              alpha: hasReachedThreshold
                                  ? 0.9 - (index * 0.2)
                                  : 0.5 - (index * 0.15),
                            ),
                            size: 16.w - (index * 2),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
