import 'package:flutter/material.dart';

class CloudPattern extends StatelessWidget {
  final Color color;
  final double opacity;

  const CloudPattern({
    super.key,
    this.color = Colors.white,
    this.opacity = 0.1,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: CloudPainter(color: color, opacity: opacity),
      child: Container(),
    );
  }
}

class CloudPainter extends CustomPainter {
  final Color color;
  final double opacity;

  CloudPainter({
    required this.color,
    required this.opacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(opacity)
      ..style = PaintingStyle.fill;

    // Draw multiple soft cloud shapes
    _drawCloud(canvas, paint, size.width * 0.2, size.height * 0.1, size.width * 0.3);
    _drawCloud(canvas, paint, size.width * 0.7, size.height * 0.2, size.width * 0.25);
    _drawCloud(canvas, paint, size.width * 0.1, size.height * 0.4, size.width * 0.2);
    _drawCloud(canvas, paint, size.width * 0.5, size.height * 0.6, size.width * 0.35);
    _drawCloud(canvas, paint, size.width * 0.8, size.height * 0.8, size.width * 0.3);
  }

  void _drawCloud(Canvas canvas, Paint paint, double x, double y, double size) {
    final path = Path();
    
    // Create a soft cloud shape using multiple circles
    path.addOval(Rect.fromCircle(center: Offset(x, y), radius: size * 0.3));
    path.addOval(Rect.fromCircle(center: Offset(x + size * 0.25, y), radius: size * 0.4));
    path.addOval(Rect.fromCircle(center: Offset(x + size * 0.5, y), radius: size * 0.3));
    path.addOval(Rect.fromCircle(center: Offset(x + size * 0.25, y - size * 0.1), radius: size * 0.35));

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CloudPainter oldDelegate) => false;
}
