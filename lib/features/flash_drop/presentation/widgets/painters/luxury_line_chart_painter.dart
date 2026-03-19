import 'package:flash_drop_app/features/flash_drop/domain/entities/historical_bid_point.dart';
import 'package:flutter/material.dart';

class LuxuryLineChartPainter extends CustomPainter {
  const LuxuryLineChartPainter({
    required this.mergedSeries,
    required this.progress,
  });

  final List<HistoricalBidPoint> mergedSeries;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final backgroundPaint = Paint()
      ..shader = const LinearGradient(
        colors: <Color>[Color(0xFF0F1722), Color(0xFF0A1118)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(rect);

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(18)),
      backgroundPaint,
    );

    if (mergedSeries.length < 2) {
      return;
    }

    final leftPadding = size.width * 0.04;
    final rightPadding = size.width * 0.04;
    final topPadding = size.height * 0.10;
    final bottomPadding = size.height * 0.10;
    final drawWidth = size.width - leftPadding - rightPadding;
    final drawHeight = size.height - topPadding - bottomPadding;

    if (drawWidth <= 0 || drawHeight <= 0) {
      return;
    }

    final rawPath = Path();
    final pointCount = mergedSeries.length;
    var minPrice = mergedSeries.first.price;
    var maxPrice = mergedSeries.first.price;

    for (int i = 0; i < pointCount; i++) {
      final price = mergedSeries[i].price;
      if (price < minPrice) {
        minPrice = price;
      }
      if (price > maxPrice) {
        maxPrice = price;
      }

      final x = leftPadding + (i / (pointCount - 1)) * drawWidth;
      if (i == 0) {
        rawPath.moveTo(x, price);
      } else {
        rawPath.lineTo(x, price);
      }
    }

    final range = maxPrice - minPrice;
    final safeRange = range == 0 ? 1.0 : range;
    final bottomY = size.height - bottomPadding;
    final scaleY = -drawHeight / safeRange;
    final translateY = bottomY + (drawHeight * minPrice / safeRange);
    final transformMatrix = Matrix4.identity()
      ..translateByDouble(0.0, translateY, 0.0, 1.0)
      ..scaleByDouble(1.0, scaleY, 1.0, 1.0);
    final linePath = rawPath.transform(transformMatrix.storage);

    final fillPath = Path.from(linePath)
      ..lineTo(size.width - rightPadding, size.height)
      ..lineTo(leftPadding, size.height)
      ..close();

    final clampedProgress = progress.clamp(0.0, 1.0);
    final revealX = leftPadding + drawWidth * clampedProgress;

    const lineColor = Color(0xFFE88585);

    final fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: <Color>[
          lineColor.withValues(alpha: 0.20),
          lineColor.withValues(alpha: 0.0),
        ],
      ).createShader(rect)
      ..isAntiAlias = true;

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..color = lineColor
      ..isAntiAlias = true;

    final gridPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = const Color(0x22FFFFFF);

    for (int i = 1; i <= 3; i++) {
      final y = topPadding + (drawHeight / 4) * i;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    canvas.save();
    canvas.clipRect(Rect.fromLTWH(0, 0, revealX, size.height));
    canvas.drawPath(fillPath, fillPaint);
    canvas.drawPath(linePath, linePaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant LuxuryLineChartPainter oldDelegate) {
    return oldDelegate.mergedSeries != mergedSeries ||
        oldDelegate.progress != progress;
  }
}
