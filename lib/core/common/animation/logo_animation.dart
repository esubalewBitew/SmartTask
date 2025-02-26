import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class CBRSLogoAnimation extends StatefulWidget {
  final double size;
  
  const CBRSLogoAnimation({
    Key? key,
    this.size = 200.0,
  }) : super(key: key);

  @override
  State<CBRSLogoAnimation> createState() => _CBRSLogoAnimationState();
}

class _CBRSLogoAnimationState extends State<CBRSLogoAnimation> 
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _arrowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    ));

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.size, widget.size * 0.4),
      painter: CBRSLogoPainter(
        arrowProgress: _arrowAnimation,
      ),
    );
  }
}

class CBRSLogoPainter extends CustomPainter {
  final Animation<double> arrowProgress;

  CBRSLogoPainter({required this.arrowProgress}) : super(repaint: arrowProgress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF004225)
      ..style = PaintingStyle.fill
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      text: TextSpan(
        text: 'CBRS',
        style: TextStyle(
          color: const Color(0xFF004225),
          fontSize: size.height * 0.8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    // Draw CBRS text
    textPainter.paint(canvas, Offset(size.width * 0.1, size.height * 0.1));

    // Draw globe icon inside C
    final globeIconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(FontAwesomeIcons.globe.codePoint),
        style: TextStyle(
          fontFamily: FontAwesomeIcons.globe.fontFamily,
          package: FontAwesomeIcons.globe.fontPackage,
          fontSize: size.height * 0.3,
          color: const Color(0xFF8BC34A),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    globeIconPainter.paint(
      canvas, 
      Offset(size.width * 0.15, size.height * 0.35),
    );

    // Animated arrow
    final progress = arrowProgress.value;
    final arrowPath = Path();
    
    // Create curved arrow path
    final startPoint = Offset(size.width * 0.2, size.height * 0.3);
    final endPoint = Offset(size.width * 0.85, size.height * 0.3);
    final controlPoint = Offset(size.width * 0.5, size.height * 0.1);
    
    final currentEndX = startPoint.dx + (endPoint.dx - startPoint.dx) * progress;
    final currentEndY = startPoint.dy + 
        (math.sin(progress * math.pi) * -size.height * 0.2);

    arrowPath.moveTo(startPoint.dx, startPoint.dy);
    arrowPath.quadraticBezierTo(
      controlPoint.dx * progress,
      controlPoint.dy,
      currentEndX,
      currentEndY,
    );

    // Arrow head
    if (progress > 0.9) {
      final headProgress = (progress - 0.9) * 10;
      final headSize = size.width * 0.05;
      arrowPath.lineTo(
        currentEndX - headSize * headProgress,
        currentEndY - headSize * headProgress,
      );
      arrowPath.moveTo(currentEndX, currentEndY);
      arrowPath.lineTo(
        currentEndX - headSize * headProgress,
        currentEndY + headSize * headProgress,
      );
    }

    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(CBRSLogoPainter oldDelegate) {
    return arrowProgress != oldDelegate.arrowProgress;
  }
}
