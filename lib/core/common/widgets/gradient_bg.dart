import 'package:smarttask/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GradientBg extends StatelessWidget {
  const GradientBg({
    required this.child,
    super.key,
    this.useLinearGradient = true,
    this.opacity,
    this.showOverlay = true,
  });

  final Widget child;
  final bool useLinearGradient;
  final double? opacity;
  final bool showOverlay;

  @override
  Widget build(BuildContext context) {
    final gradientColors = context.primaryGradient.colors
        .map((color) => color.withOpacity(opacity ?? 1.0))
        .toList();

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: useLinearGradient
                ? LinearGradient(
                    begin: context.primaryGradient.begin,
                    end: context.primaryGradient.end,
                    colors: gradientColors,
                    stops: context.primaryGradient.stops,
                    transform: context.primaryGradient.transform,
                  )
                : RadialGradient(
                    center: Alignment.topCenter,
                    radius: 1.5,
                    colors: gradientColors,
                  ),
          ),
          child: child,
        ),
        if (showOverlay)
          Positioned.fill(
            child: CustomPaint(
              painter: GradientOverlayPainter(
                overlayColor: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
      ],
    );
  }
}

class GradientOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Paint _paint;

  GradientOverlayPainter({required this.overlayColor})
      : _paint = Paint()
          ..color = overlayColor
          ..style = PaintingStyle.fill
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 15);

  @override
  void paint(Canvas canvas, Size size) {
    final curves = [
      (yStart: 0.8, curve: 0.25, opacity: 0.05, width: 1.2),
      (yStart: 0.6, curve: 0.25, opacity: 0.05, width: 1.2),
      (yStart: 0.4, curve: 0.25, opacity: 0.05, width: 1.2),
      (yStart: 0.2, curve: 0.25, opacity: 0.05, width: 1.2),
    ];

    for (final curve in curves) {
      drawFlowingCurve(
          canvas, size, curve.yStart, curve.curve, curve.opacity, curve.width);
    }
  }

  void drawFlowingCurve(Canvas canvas, Size size, double yStart,
      double curveIntensity, double opacity, double widthFactor) {
    final path = Path();

    // Start from further left for diagonal effect
    path.moveTo(-size.width * 0.5, size.height * yStart);

    final List<Offset> points = [
      Offset(size.width * 0.2, size.height * (yStart - curveIntensity)),
      Offset(size.width * 0.4, size.height * (yStart - curveIntensity * 1.5)),
      Offset(size.width * widthFactor,
          size.height * (yStart - curveIntensity * 2)),
      Offset(size.width * (widthFactor + 0.3),
          size.height * (yStart - curveIntensity * 2.5)),
    ];

    path.cubicTo(
      points[0].dx,
      points[0].dy,
      points[1].dx,
      points[1].dy,
      points[2].dx,
      points[2].dy,
    );

    // Create wider, more diagonal fade
    path.lineTo(size.width * 1.5, size.height * (yStart - curveIntensity * 3));
    path.lineTo(size.width * 1.5, size.height * (yStart + 0.2));
    path.lineTo(-size.width * 0.5, size.height * (yStart + 0.2));
    path.close();

    // Draw with very soft white fade
    canvas.drawPath(
      path,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(opacity * 2),
            Colors.white.withOpacity(opacity * 0.3),
          ],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 20),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
