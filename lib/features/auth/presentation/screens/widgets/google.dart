import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';



class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    const sweepAngle = 1.5708;
    final paints = [
      Paint()..color = const Color(0xFF4285F4),
      Paint()..color = const Color(0xFF34A853),
      Paint()..color = const Color(0xFFFBBC05),
      Paint()..color = const Color(0xFFEA4335),
    ];

    for (int i = 0; i < 4; i++) {
      paints[i].style = PaintingStyle.stroke;
      paints[i].strokeWidth = size.width * 0.22;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 0.72),
        i * sweepAngle - 0.2,
        sweepAngle - 0.1,
        false,
        paints[i],
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
