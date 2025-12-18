import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// Widget pour afficher un graphique circulaire
class PieChartWidget extends StatelessWidget {
  final List<PieChartSection> sections;
  final String title;
  final double radius;

  const PieChartWidget({
    super.key,
    required this.sections,
    required this.title,
    this.radius = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (sections.isEmpty) {
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
              height: radius * 2 + 50,
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: radius * 0.5,
                        sections: sections.map((section) => PieChartSectionData(
                          value: section.value,
                          title: section.title,
                          color: section.color,
                          radius: radius,
                          titleStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: section.textColor ?? Colors.white,
                          ),
                        )).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: sections.map((section) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: section.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                section.label,
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${section.percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[700],
                              ),
                            ),
                          ],
                        ),
                      )).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Section pour le graphique circulaire
class PieChartSection {
  final double value;
  final String title;
  final Color color;
  final String label;
  final Color? textColor;

  PieChartSection({
    required this.value,
    required this.title,
    required this.color,
    required this.label,
    this.textColor,
  });

  double get percentage {
    // Le pourcentage sera calculé par rapport au total dans le widget parent
    return value;
  }
}




