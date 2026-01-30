import 'package:flutter/material.dart';
import 'package:teybatseller/features/tour/data/models/tour_step_model.dart';

/// Tour highlight overlay with dimmed background and spotlight effect
class TourHighlight extends StatelessWidget {
  const TourHighlight({
    required this.step,
    super.key,
  });

  final TourStepModel step;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: true,
        child: CustomPaint(
          painter: _SpotlightPainter(
            step: step,
          ),
        ),
      ),
    );
  }
}

class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.step,
  });

  final TourStepModel step;

  @override
  void paint(Canvas canvas, Size size) {
    // Draw semi-transparent dark overlay
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7);

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      overlayPaint,
    );

    // For fullScreen highlight, don't cut out any area
    if (step.highlightArea == HighlightArea.fullScreen) {
      return;
    }

    // Try to get target widget position using GlobalKey
    if (step.targetWidgetKey != null) {
      final RenderBox? renderBox =
          step.targetWidgetKey!.currentContext?.findRenderObject() as RenderBox?;

      if (renderBox != null && renderBox.hasSize) {
        final position = renderBox.localToGlobal(Offset.zero);
        final targetRect = position & renderBox.size;

        // Add padding around target
        final highlightRect = targetRect.inflate(8);

        // Cut out the highlight area using BlendMode.clear
        final clearPaint = Paint()
          ..blendMode = BlendMode.clear;

        switch (step.highlightArea) {
          case HighlightArea.rectangle:
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                highlightRect,
                const Radius.circular(12),
              ),
              clearPaint,
            );
            break;

          case HighlightArea.circle:
            final center = highlightRect.center;
            final radius = (highlightRect.width + highlightRect.height) / 4;
            canvas.drawCircle(center, radius, clearPaint);
            break;

          case HighlightArea.custom:
          case HighlightArea.fullScreen:
            // Already handled
            break;
        }

        // Draw border around highlight
        final borderPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2;

        switch (step.highlightArea) {
          case HighlightArea.rectangle:
            canvas.drawRRect(
              RRect.fromRectAndRadius(
                highlightRect,
                const Radius.circular(12),
              ),
              borderPaint,
            );
            break;

          case HighlightArea.circle:
            final center = highlightRect.center;
            final radius = (highlightRect.width + highlightRect.height) / 4;
            canvas.drawCircle(center, radius, borderPaint);
            break;

          case HighlightArea.custom:
          case HighlightArea.fullScreen:
            break;
        }
      }
    }
  }

  @override
  bool shouldRepaint(_SpotlightPainter oldDelegate) {
    return oldDelegate.step.id != step.id;
  }
}
