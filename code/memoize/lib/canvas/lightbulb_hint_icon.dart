import 'package:flutter/material.dart';

// This class extends Custom painter to draw a lightbulb icon manually on canvas. (Custom Canvas Feature)
class LightbulbPainter extends CustomPainter {
  // The color of the lightbulb icon.
  final Color color;
  const LightbulbPainter({required this.color});
  // The paint method is responsible for drawing the lightbulb icon on the canvas.
  @override
  void paint(Canvas canvas, Size size) {
    final outline = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fill = Paint()
      ..color = Colors.yellow.shade600
      ..style = PaintingStyle.fill;

    // Bulb oval shape
    final bulb = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.05,
      size.width * 0.6,
      size.height * 0.7,
    );

    canvas.drawOval(bulb, fill); 
    canvas.drawOval(bulb, outline);

    // Draws a line inside the bulb's left side
    canvas.drawLine(
      Offset(size.width * 0.4, size.height * 0.45),
      Offset(size.width * 0.4, size.height * 0.7),
      outline,
    );

    // Draws a line inside the bulb's right side
    canvas.drawLine(
      Offset(size.width * 0.6, size.height * 0.45),
      Offset(size.width * 0.6, size.height * 0.7),
      outline,
    );

    // Is an arc inside the bulb connecting two lines
    canvas.drawArc(
      Rect.fromLTWH(
        size.width * 0.4,
        size.height * 0.4,
        size.width * 0.2,
        size.height * 0.15,
      ),
      0, 3.14, false, outline,
    );

    // Base rectangle shape
    final base = Rect.fromLTWH(
      size.width * 0.35,
      size.height * 0.75,
      size.width * 0.3,
      size.height * 0.18,
    );

    canvas.drawRect(base, Paint()..color = Colors.grey.shade300);
    canvas.drawRect(base, outline);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
