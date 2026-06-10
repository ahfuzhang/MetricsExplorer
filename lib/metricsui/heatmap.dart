import 'dart:math' show max;

import 'package:flutter/material.dart';

class BucketData {
  final double upperBound;
  final List<double> points;
  final String tagLabel;
  BucketData({required this.upperBound, required this.points, required this.tagLabel});
}

class HeatmapChart extends StatefulWidget {
  final List<int> timestamps;
  final List<BucketData> buckets;
  final double minValue;
  final double maxValue;
  final String Function(double) formatValue;

  const HeatmapChart({
    super.key,
    required this.timestamps,
    required this.buckets,
    required this.minValue,
    required this.maxValue,
    required this.formatValue,
  });

  @override
  State<HeatmapChart> createState() => _HeatmapChartState();
}

class _HeatmapChartState extends State<HeatmapChart> {
  Offset? _hoverPos;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onHover: (e) {
        if (_hoverPos != e.localPosition) {
          setState(() => _hoverPos = e.localPosition);
        }
      },
      onExit: (_) => setState(() => _hoverPos = null),
      child: CustomPaint(
        painter: _HeatmapPainter(
          timestamps: widget.timestamps,
          buckets: widget.buckets,
          minValue: widget.minValue,
          maxValue: widget.maxValue,
          hoverPos: _hoverPos,
          formatValue: widget.formatValue,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _HeatmapPainter extends CustomPainter {
  static const _leftPad = 60.0;
  static const _rightPad = 8.0;
  static const _topPad = 4.0;
  static const _xAxisH = 22.0;
  static const _colorBarH = 10.0;
  static const _bottomPad = _xAxisH + _colorBarH + 14.0;

  final List<int> timestamps;
  final List<BucketData> buckets;
  final double minValue;
  final double maxValue;
  final Offset? hoverPos;
  final String Function(double) formatValue;

  _HeatmapPainter({
    required this.timestamps,
    required this.buckets,
    required this.minValue,
    required this.maxValue,
    required this.hoverPos,
    required this.formatValue,
  });

  Color _heatColor(double t) {
    const low = Color(0xFFECEFF1);
    const high = Color(0xFF0D47A1);
    return Color.lerp(low, high, t.clamp(0.0, 1.0))!;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final gridW = size.width - _leftPad - _rightPad;
    final gridH = size.height - _topPad - _bottomPad;
    if (gridW <= 0 || gridH <= 0) return;

    final n = timestamps.length;
    final m = buckets.length;
    if (n == 0 || m == 0) return;

    final cellW = gridW / n;
    final cellH = gridH / m;
    final valueRange = maxValue - minValue;

    // Determine hover cell
    int? hovCol, hovRow;
    final hp = hoverPos;
    if (hp != null) {
      final dx = hp.dx - _leftPad;
      final dy = hp.dy - _topPad;
      if (dx >= 0 && dx < gridW && dy >= 0 && dy < gridH) {
        hovCol = (dx / cellW).floor().clamp(0, n - 1);
        hovRow = (m - 1) - (dy / cellH).floor().clamp(0, m - 1);
      }
    }

    // Draw cells (row 0 = lowest bucket at bottom, row m-1 = highest at top)
    final cellPaint = Paint();
    for (int col = 0; col < n; col++) {
      for (int row = 0; row < m; row++) {
        final screenRow = (m - 1) - row;
        final left = _leftPad + col * cellW;
        final top = _topPad + screenRow * cellH;
        final rect = Rect.fromLTWH(left, top, cellW, cellH);

        final pts = buckets[row].points;
        final val = col < pts.length ? pts[col] : 0.0;
        final t = valueRange > 0 ? (val - minValue) / valueRange : 0.0;
        cellPaint.color = (hovCol == col && hovRow == row)
            ? _heatColor(t).withValues(alpha: 0.55)
            : _heatColor(t);
        canvas.drawRect(rect, cellPaint);
      }
    }

    // Grid border
    canvas.drawRect(
      Rect.fromLTWH(_leftPad, _topPad, gridW, gridH),
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Y-axis labels
    final tp = TextPainter(textDirection: TextDirection.ltr);
    final maxYLabels = max(1, (gridH / 14).floor());
    final yStep = max(1, (m / maxYLabels).ceil());
    for (int row = 0; row < m; row += yStep) {
      final screenRow = (m - 1) - row;
      final y = _topPad + (screenRow + 0.5) * cellH;
      tp.text = TextSpan(
        text: buckets[row].tagLabel,
        style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
      );
      tp.layout(maxWidth: _leftPad - 4);
      tp.paint(canvas, Offset(_leftPad - tp.width - 4, y - tp.height / 2));
    }

    // X-axis labels
    final maxXLabels = max(1, (gridW / 34).floor());
    final xStep = max(1, (n / maxXLabels).ceil());
    for (int col = 0; col < n; col += xStep) {
      final x = _leftPad + (col + 0.5) * cellW;
      final dt = DateTime.fromMillisecondsSinceEpoch(timestamps[col] * 1000);
      final label =
          '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
      tp.text = TextSpan(
        text: label,
        style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
      );
      tp.layout();
      tp.paint(canvas, Offset(x - tp.width / 2, _topPad + gridH + 4));
    }

    // Color bar
    final barTop = _topPad + gridH + _xAxisH;
    final barRect = Rect.fromLTWH(_leftPad, barTop, gridW, _colorBarH);
    canvas.drawRect(
      barRect,
      Paint()
        ..shader = LinearGradient(
          colors: [_heatColor(0), _heatColor(1)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(barRect),
    );
    canvas.drawRect(
      barRect,
      Paint()
        ..color = Colors.grey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );

    // Color bar min/max labels
    tp.text = TextSpan(
      text: formatValue(minValue),
      style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
    );
    tp.layout();
    tp.paint(canvas, Offset(_leftPad, barTop + _colorBarH + 2));

    tp.text = TextSpan(
      text: formatValue(maxValue),
      style: const TextStyle(fontSize: 9, color: Color(0xFF6B7280)),
    );
    tp.layout();
    tp.paint(canvas, Offset(_leftPad + gridW - tp.width, barTop + _colorBarH + 2));

    // Tooltip
    if (hovCol != null && hovRow != null) {
      _drawTooltip(canvas, size, hovCol, hovRow, cellW, cellH, m);
    }
  }

  void _drawTooltip(
      Canvas canvas, Size size, int col, int row, double cellW, double cellH, int m) {
    final bucket = buckets[row];
    final pts = bucket.points;
    final val = col < pts.length ? pts[col] : 0.0;
    final dt = DateTime.fromMillisecondsSinceEpoch(timestamps[col] * 1000);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    final tipText = '$time  ≤${bucket.tagLabel}  ${formatValue(val)}';

    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: tipText,
      style: const TextStyle(fontSize: 10, color: Color(0xFF212121)),
    );
    tp.layout(maxWidth: size.width - 24);

    final tipW = tp.width + 12;
    final tipH = tp.height + 8;
    final screenRow = (m - 1) - row;
    var tipX = _leftPad + (col + 1) * cellW + 4;
    var tipY = _topPad + screenRow * cellH - tipH - 2;
    tipX = tipX.clamp(0.0, size.width - tipW);
    tipY = tipY.clamp(0.0, size.height - tipH);

    final tipRRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(tipX, tipY, tipW, tipH),
      const Radius.circular(4),
    );
    canvas.drawRRect(tipRRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      tipRRect,
      Paint()
        ..color = Colors.grey.shade300
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    tp.paint(canvas, Offset(tipX + 6, tipY + 4));
  }

  @override
  bool shouldRepaint(_HeatmapPainter old) =>
      old.hoverPos != hoverPos ||
      !identical(old.timestamps, timestamps) ||
      !identical(old.buckets, buckets) ||
      old.minValue != minValue ||
      old.maxValue != maxValue;
}
