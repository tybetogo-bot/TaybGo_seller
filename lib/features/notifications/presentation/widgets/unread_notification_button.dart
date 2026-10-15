import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A quiet unread indicator that calls attention only to an increased count.
class UnreadNotificationButton extends StatefulWidget {
  const UnreadNotificationButton({
    super.key,
    required this.unreadCount,
    required this.label,
    required this.onPressed,
  });

  final int unreadCount;
  final String label;
  final VoidCallback onPressed;

  @override
  State<UnreadNotificationButton> createState() =>
      _UnreadNotificationButtonState();
}

class _UnreadNotificationButtonState extends State<UnreadNotificationButton>
    with SingleTickerProviderStateMixin {
  static const _badgeColor = Color(0xFFD92D3E);
  static const _transitionDuration = Duration(milliseconds: 220);
  late final AnimationController _attention = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  );
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion =
        MediaQuery.disableAnimationsOf(context) ||
        MediaQuery.accessibleNavigationOf(context);
    if (_reduceMotion) _attention.reset();
  }

  @override
  void didUpdateWidget(covariant UnreadNotificationButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.unreadCount > oldWidget.unreadCount && !_reduceMotion) {
      _attention.forward(from: 0);
    } else if (widget.unreadCount <= 0) {
      _attention.reset();
    }
  }

  @override
  void dispose() {
    _attention.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasUnread = widget.unreadCount > 0;
    final duration = _reduceMotion ? Duration.zero : _transitionDuration;
    final countLabel = widget.unreadCount > 99
        ? '99+'
        : '${widget.unreadCount}';

    return IconButton(
      onPressed: widget.onPressed,
      tooltip: widget.label,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints.tightFor(width: 48, height: 48),
      style: IconButton.styleFrom(shape: const CircleBorder()),
      icon: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _attention,
          builder: (context, _) {
            final progress = _attention.value;
            // Both settle exactly at rest; no timer or looping animation.
            final envelope = math.sin(math.pi * progress);
            final angle = math.sin(progress * math.pi * 6) * envelope * 0.16;
            final pulse = math.sin(progress * math.pi) * 0.13;
            return SizedBox.square(
              dimension: 48,
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  if (hasUnread && _attention.isAnimating)
                    Transform.scale(
                      scale: 1 + progress * 0.35,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _badgeColor.withValues(
                              alpha: (1 - progress) * 0.22,
                            ),
                          ),
                        ),
                      ),
                    ),
                  AnimatedContainer(
                    duration: duration,
                    curve: Curves.easeOutCubic,
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: hasUnread
                          ? _badgeColor.withValues(alpha: isDark ? 0.16 : 0.07)
                          : _badgeColor.withValues(alpha: 0),
                    ),
                    child: Transform.rotate(
                      angle: angle,
                      alignment: const Alignment(0, -0.5),
                      child: Icon(
                        hasUnread
                            ? Icons.notifications_rounded
                            : Icons.notifications_none_rounded,
                        size: 26,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    top: 0,
                    end: 0,
                    child: Transform.scale(
                      scale: 1 + pulse,
                      child: AnimatedSwitcher(
                        duration: duration,
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeIn,
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: ScaleTransition(
                            scale: animation,
                            child: child,
                          ),
                        ),
                        child: hasUnread
                            ? MediaQuery.withClampedTextScaling(
                                key: ValueKey(countLabel),
                                maxScaleFactor: 1.4,
                                child: Container(
                                  constraints: const BoxConstraints(
                                    minWidth: 23,
                                    maxWidth: 42,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 5,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _badgeColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: theme.scaffoldBackgroundColor,
                                      width: 2,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: _badgeColor.withValues(
                                          alpha: 0.18,
                                        ),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      countLabel,
                                      textDirection: TextDirection.ltr,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        height: 1.2,
                                        fontWeight: FontWeight.w800,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(key: ValueKey('read')),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
