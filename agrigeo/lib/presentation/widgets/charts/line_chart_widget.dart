import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget pour afficher un graphique linéaire
class LineChartWidget extends StatelessWidget {
  final List<ChartDataPoint> dataPoints;
  final String title;
  final String? yAxisLabel;
  final Color lineColor;
  final Color fillColor;
  final double? minY;
  final double? maxY;

  const LineChartWidget({
    super.key,
    required this.dataPoints,
    required this.title,
    this.yAxisLabel,
    this.lineColor = Colors.green,
    this.fillColor = Colors.green,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    if (dataPoints.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Aucune donnée disponible'),
            ],
          ),
        ),
      );
    }

    final spots = dataPoints.map((point) => FlSpot(point.x, point.y)).toList();
    final minYValue = minY ?? (dataPoints.map((p) => p.y).reduce((a, b) => a < b ? a : b) * 0.9);
    final maxYValue = maxY ?? (dataPoints.map((p) => p.y).reduce((a, b) => a > b ? a : b) * 1.1);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxYValue - minYValue) / 5,
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.grey.withValues(alpha: 0.2),
                        strokeWidth: 1,
                      );
                    },
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          if (index >= 0 && index < dataPoints.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                dataPoints[index].label,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 50,
                        interval: (maxYValue - minYValue) / 5,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.grey[600],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
                  ),
                  minX: 0,
                  maxX: (dataPoints.length - 1).toDouble(),
                  minY: minYValue,
                  maxY: maxYValue,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      isStrokeCapRound: true,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: fillColor.withValues(alpha: 0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (yAxisLabel != null) ...[
              const SizedBox(height: 8),
              Text(
                yAxisLabel!,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Point de données pour les graphiques
class ChartDataPoint {
  final double x;
  final double y;
  final String label;

  ChartDataPoint({
    required this.x,
    required this.y,
    required this.label,
  });
}

