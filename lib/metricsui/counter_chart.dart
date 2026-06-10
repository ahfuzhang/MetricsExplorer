import 'dart:math' show max, min;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

const kSeriesColors = [
  Color(0xFF5C6BC0),
  Color(0xFF26A69A),
  Color(0xFFFF7043),
  Color(0xFFAB47BC),
  Color(0xFF66BB6A),
  Color(0xFF42A5F5),
];

typedef SeriesData = ({String label, List<double> points, Map<String, String> tags});

class CounterChart extends StatefulWidget {
  final List<int> timestamps;
  final List<SeriesData> series;
  final String unit;
  final String Function(double) formatValue;
  final bool isLoading;
  final String? error;

  const CounterChart({
    super.key,
    required this.timestamps,
    required this.series,
    this.unit = '',
    required this.formatValue,
    this.isLoading = false,
    this.error,
  });

  @override
  State<CounterChart> createState() => _CounterChartState();
}

class _CounterChartState extends State<CounterChart> {
  static const _chartHeight = 200.0;
  int? _hoveredIndex;

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return const SizedBox(
        height: _chartHeight,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (widget.error != null) {
      return Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Center(
          child: Text(
            'Chart: ${widget.error}',
            style: const TextStyle(color: Colors.red, fontSize: 11),
          ),
        ),
      );
    }

    final ts = widget.timestamps;
    final series = widget.series;
    if (ts.isEmpty || series.isEmpty) return const SizedBox.shrink();

    final n = ts.length;

    // Compute Y range across all series.
    double maxY = 0, minY = double.infinity;
    for (final s in series) {
      for (final v in s.points) {
        if (v > maxY) maxY = v;
        if (v < minY) minY = v;
      }
    }
    if (minY == double.infinity) minY = 0;
    final range = maxY - minY;
    final displayMax = maxY + (range > 0 ? range * 0.1 : max(maxY * 0.1, 0.001));
    final displayMin = (minY - (range > 0 ? range * 0.1 : 0)).clamp(0.0, double.infinity);

    final xInterval = max(1, (n / 6).ceil()).toDouble();

    // Build line bars.
    final bars = series.asMap().entries.map((entry) {
      final idx = entry.key;
      final s = entry.value;
      final color = kSeriesColors[idx % kSeriesColors.length];
      final pts = s.points;
      final count = min(n, pts.length);
      final spots = List.generate(count, (i) => FlSpot(i.toDouble(), pts[i]));
      return LineChartBarData(
        spots: spots,
        isCurved: true,
        curveSmoothness: 0.3,
        color: color,
        barWidth: 2,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.22),
              color.withValues(alpha: 0.02),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
      );
    }).toList();

    final hoveredIdx = _hoveredIndex;
    final showingIndicators = (hoveredIdx == null || bars.isEmpty)
        ? <ShowingTooltipIndicators>[]
        : () {
            final spots = bars.asMap().entries
                .where((e) => hoveredIdx < e.value.spots.length)
                .map((e) => LineBarSpot(e.value, e.key, e.value.spots[hoveredIdx]))
                .toList();
            return spots.isEmpty
                ? <ShowingTooltipIndicators>[]
                : [ShowingTooltipIndicators(spots)];
          }();

    // Horizontal crosshair lines for each series at the hovered index.
    final extraLines = <HorizontalLine>[];
    final extraVerticalLines = <VerticalLine>[];
    if (hoveredIdx != null) {
      for (int i = 0; i < series.length; i++) {
        final pts = series[i].points;
        if (hoveredIdx < pts.length) {
          extraLines.add(HorizontalLine(
            y: pts[hoveredIdx],
            color: kSeriesColors[i % kSeriesColors.length].withValues(alpha: 0.5),
            strokeWidth: 1,
            dashArray: [5, 4],
          ));
        }
      }
      extraVerticalLines.add(VerticalLine(
        x: hoveredIdx.toDouble(),
        color: Colors.grey.withValues(alpha: 0.5),
        strokeWidth: 1,
        dashArray: [5, 4],
      ));
    }

    return SizedBox(
      height: _chartHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 16, 4),
        child: LineChart(
          LineChartData(
            minX: 0,
            maxX: (n - 1).toDouble(),
            minY: displayMin,
            maxY: displayMax,
            showingTooltipIndicators: showingIndicators,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(
                color: Colors.grey.shade200,
                strokeWidth: 1,
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey.shade300),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 64,
                  getTitlesWidget: (v, _) => Text(
                    widget.formatValue(v),
                    style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
                    textAlign: TextAlign.right,
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 26,
                  interval: xInterval,
                  getTitlesWidget: (v, _) {
                    final i = v.toInt().clamp(0, ts.length - 1);
                    final dt = DateTime.fromMillisecondsSinceEpoch(ts[i] * 1000);
                    final hh = dt.hour.toString().padLeft(2, '0');
                    final mm = dt.minute.toString().padLeft(2, '0');
                    return Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$hh:$mm',
                        style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
                      ),
                    );
                  },
                ),
              ),
            ),
            lineTouchData: LineTouchData(
              // Disable built-in threshold-based detection so the tooltip
              // never disappears while the cursor is over the chart.
              handleBuiltInTouches: false,
              // Large threshold so lineBarSpots always resolves to the
              // nearest column regardless of vertical mouse position.
              touchSpotThreshold: 1000,
              touchCallback: (FlTouchEvent event, LineTouchResponse? response) {
                if (!mounted) return;
                int? newIdx;
                if (event is! FlPointerExitEvent) {
                  final spots = response?.lineBarSpots;
                  if (spots != null && spots.isNotEmpty) {
                    newIdx = spots.first.spotIndex;
                  }
                }
                if (newIdx != _hoveredIndex) {
                  setState(() => _hoveredIndex = newIdx);
                }
              },
              getTouchedSpotIndicator: (barData, spotIndexes) =>
                  spotIndexes.map((_) => TouchedSpotIndicatorData(
                        FlLine(
                          color: Colors.grey.withValues(alpha: 0.5),
                          strokeWidth: 1,
                          dashArray: [5, 4],
                        ),
                        FlDotData(
                          show: true,
                          getDotPainter: (spot, percent, bar, index) =>
                              FlDotCirclePainter(
                                radius: 5,
                                color: barData.color ?? Colors.grey,
                                strokeWidth: 2,
                                strokeColor: Colors.white,
                              ),
                        ),
                      )).toList(),
              touchTooltipData: LineTouchTooltipData(
                getTooltipColor: (_) => Colors.white,
                tooltipBorder: BorderSide(color: Colors.grey.shade300),
                tooltipRoundedRadius: 4,
                getTooltipItems: (spots) => spots.asMap().entries.map((entry) {
                  final spot = entry.value;
                  final i = spot.x.toInt().clamp(0, ts.length - 1);
                  final dt = DateTime.fromMillisecondsSinceEpoch(ts[i] * 1000);
                  final hh = dt.hour.toString().padLeft(2, '0');
                  final mm = dt.minute.toString().padLeft(2, '0');
                  final header = entry.key == 0 ? '$hh:$mm\n' : '';
                  return LineTooltipItem(
                    header,
                    const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF6B7280),
                      fontWeight: FontWeight.w500,
                    ),
                    children: [
                      TextSpan(
                        text: '${widget.formatValue(spot.y)}${widget.unit}',
                        style: TextStyle(
                          fontSize: 11,
                          color: kSeriesColors[spot.barIndex % kSeriesColors.length],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
            ),
            extraLinesData: ExtraLinesData(
              horizontalLines: extraLines,
              verticalLines: extraVerticalLines,
            ),
            lineBarsData: bars,
          ),
        ),
      ),
    );
  }
}
