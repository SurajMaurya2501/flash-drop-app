import 'package:flutter/material.dart';

class LuxuryPointerPainter extends CustomPainter {
  const LuxuryPointerPainter({
    required this.currentPrice,
    required this.minPrice,
    required this.maxPrice,
  });

  final double currentPrice;
  final double minPrice;
  final double maxPrice;

  @override
  void paint(Canvas canvas, Size size) {
    final rightPadding = size.width * 0.04;
    final topPadding = size.height * 0.10;
    final bottomPadding = size.height * 0.10;
    final drawHeight = size.height - topPadding - bottomPadding;

    if (drawHeight <= 0) {
      return;
    }

    final safeRange = (maxPrice - minPrice) == 0 ? 1.0 : (maxPrice - minPrice);
    final bottomY = size.height - bottomPadding;
    final normalized = ((currentPrice - minPrice) / safeRange).clamp(0.0, 1.0);
    final markerY = bottomY - normalized * drawHeight;
    final markerX = size.width - rightPadding;

    final glowPaint = Paint()
      ..color = const Color(0x55F0CB8B)
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final markerPaint = Paint()
      ..color = const Color(0xFFF0CB8B)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(markerX, markerY), 7.0, glowPaint);
    canvas.drawCircle(Offset(markerX, markerY), 4.2, markerPaint);
  }

  @override
  bool shouldRepaint(covariant LuxuryPointerPainter oldDelegate) {
    return oldDelegate.currentPrice != currentPrice ||
        oldDelegate.minPrice != minPrice ||
        oldDelegate.maxPrice != maxPrice;
  }
}
