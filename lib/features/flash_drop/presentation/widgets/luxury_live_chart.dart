import 'package:flash_drop_app/features/flash_drop/presentation/widgets/painters/luxury_line_chart_painter.dart';
import 'package:flash_drop_app/features/flash_drop/presentation/widgets/painters/luxury_pointer_painter.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/historical_bid_point.dart';

class LuxuryLiveChart extends StatefulWidget {
  const LuxuryLiveChart({
    required this.historicalSeries,
    required this.liveSeries,
    super.key,
  });

  final List<HistoricalBidPoint> historicalSeries;
  final List<HistoricalBidPoint> liveSeries;

  @override
  State<LuxuryLiveChart> createState() => _LuxuryLiveChartState();
}

class _LuxuryLiveChartState extends State<LuxuryLiveChart>
    with TickerProviderStateMixin {
  late final AnimationController _revealController;
  late final Animation<double> _revealProgress;
  late final AnimationController _pointerController;
  late Animation<double> _pointerPriceAnimation;
  late List<HistoricalBidPoint> _chartSeries;
  bool _didRunInitialReveal = false;

  @override
  void initState() {
    super.initState();
    initializeControllers();
    _startInitialReveal();
  }

  @override
  void didUpdateWidget(covariant LuxuryLiveChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newMergedSeries = _buildMergedSeries(
      widget.historicalSeries,
      widget.liveSeries,
    );

    if (!_isTailOnlyPriceChange(_chartSeries, newMergedSeries)) {
      _chartSeries = newMergedSeries;
      if (!_didRunInitialReveal) {
        _startInitialReveal();
      } else {
        setState(() {});
      }
    }

    final previousPrice = _pointerPriceAnimation.value;
    final targetPrice = newMergedSeries.isEmpty
        ? previousPrice
        : newMergedSeries.last.price;
    _pointerPriceAnimation =
        Tween<double>(begin: previousPrice, end: targetPrice).animate(
          CurvedAnimation(
            parent: _pointerController,
            curve: Curves.easeOutCubic,
          ),
        );
    _pointerController
      ..stop()
      ..reset()
      ..forward();
  }

  @override
  void dispose() {
    _revealController.dispose();
    _pointerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minMax = _computeMinMax(_chartSeries);

    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedBuilder(
            animation: _revealProgress,
            builder: (context, _) => CustomPaint(
              painter: LuxuryLineChartPainter(
                mergedSeries: _chartSeries,
                progress: _revealProgress.value,
              ),
              child: const SizedBox.expand(),
            ),
          ),
          AnimatedBuilder(
            animation: _pointerPriceAnimation,
            builder: (context, _) => CustomPaint(
              painter: LuxuryPointerPainter(
                currentPrice: _pointerPriceAnimation.value,
                minPrice: minMax.$1,
                maxPrice: minMax.$2,
              ),
              child: const SizedBox.expand(),
            ),
          ),
        ],
      ),
    );
  }

  void _startInitialReveal() {
    _revealController
      ..reset()
      ..forward();
    _didRunInitialReveal = true;
  }

  List<HistoricalBidPoint> _buildMergedSeries(
    List<HistoricalBidPoint> historical,
    List<HistoricalBidPoint> live,
  ) {
    return <HistoricalBidPoint>[...historical, ...live];
  }

  (double, double) _computeMinMax(List<HistoricalBidPoint> series) {
    if (series.isEmpty) {
      return (0.0, 1.0);
    }

    var minPrice = series.first.price;
    var maxPrice = series.first.price;
    for (final point in series) {
      final price = point.price;
      if (price < minPrice) {
        minPrice = price;
      }
      if (price > maxPrice) {
        maxPrice = price;
      }
    }
    return (minPrice, maxPrice);
  }

  bool _isTailOnlyPriceChange(
    List<HistoricalBidPoint> previous,
    List<HistoricalBidPoint> next,
  ) {
    if (previous.length != next.length || previous.isEmpty || next.isEmpty) {
      return false;
    }

    for (int i = 0; i < previous.length - 1; i++) {
      if (previous[i].epochMs != next[i].epochMs ||
          previous[i].price != next[i].price) {
        return false;
      }
    }

    return previous.last.epochMs == next.last.epochMs;
  }

  void initializeControllers() {
    _chartSeries = _buildMergedSeries(
      widget.historicalSeries,
      widget.liveSeries,
    );

    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _revealProgress = CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutCubic,
    );
    _pointerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 240),
    );

    final initialPrice = _chartSeries.isEmpty ? 0.0 : _chartSeries.last.price;
    _pointerPriceAnimation = AlwaysStoppedAnimation<double>(initialPrice);
  }
}
