import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:teybatseller/core/theme/app_colors.dart';
import 'package:teybatseller/features/tour/data/models/tour_step_model.dart';
import 'package:teybatseller/features/tour/utils/tour_keys.dart';

/// Highlights a specific widget by dimming the rest of the screen
/// with a spotlight effect
class TourHighlight extends StatefulWidget {
  const TourHighlight({
    required this.step,
    super.key,
  });

  final TourStepModel step;

  @override
  State<TourHighlight> createState() => _TourHighlightState();
}

class _TourHighlightState extends State<TourHighlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get target widget bounds if key is provided
    Rect? targetRect;
    if (widget.step.targetWidgetKey != null) {
      targetRect = TourKeys.getWidgetBounds(widget.step.targetWidgetKey!);
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: [
            // Dimmed background with hole for target
            CustomPaint(
              painter: _SpotlightPainter(
                targetRect: targetRect,
                highlightArea: widget.step.highlightArea,
                pulseAnimation: _pulseAnimation,
              ),
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for spotlight effect
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.targetRect,
    required this.highlightArea,
    required this.pulseAnimation,
  }) : super(repaint: pulseAnimation);

  final Rect? targetRect;
  final HighlightArea highlightArea;
  final Animation<double> pulseAnimation;

  @override
  void paint(Canvas canvas, Size size) {
    if (targetRect == null || highlightArea == HighlightArea.fullScreen) {
      // No highlight, just dimmed background
      return;
    }

    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    // Create hole in overlay based on highlight area type
    RRect highlightRRect;
    if (highlightArea == HighlightArea.circle) {
      final center = targetRect!.center;
      final radius = (targetRect!.width > targetRect!.height
              ? targetRect!.width
              : targetRect!.height) /
          2 +
          16.w;
      highlightRRect = RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: radius),
        Radius.circular(radius),
      );
    } else {
      // Rectangle or custom (default to rectangle with rounded corners)
      highlightRRect = RRect.fromRectAndRadius(
        targetRect!.inflate(8.w),
        Radius.circular(12.r),
      );
    }

    path.addRRect(highlightRRect);
    path.fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw animated pulse border around target
    final borderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.w * pulseAnimation.value;

    canvas.drawRRect(highlightRRect, borderPaint);

    // Draw subtle glow
    final glowPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.3 * pulseAnimation.value)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.w
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 4.w);

    canvas.drawRRect(highlightRRect, glowPaint);
  }

  @override
  bool shouldRepaint(covariant _SpotlightPainter oldDelegate) {
    return oldDelegate.targetRect != targetRect ||
        oldDelegate.highlightArea != highlightArea;
  }
}
