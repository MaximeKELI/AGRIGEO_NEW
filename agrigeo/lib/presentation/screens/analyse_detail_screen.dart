import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/analyse_sol_model.dart';

class AnalyseDetailScreen extends StatelessWidget {
  final AnalyseSolModel analyse;

  const AnalyseDetailScreen({
    super.key,
    required this.analyse,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'analyse'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations générales',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow('Date de prélèvement', _formatDate(analyse.datePrelevement)),
                    if (analyse.ph != null)
                      _buildInfoRow('pH', analyse.ph!.toStringAsFixed(2)),
                    if (analyse.humidite != null)
                      _buildInfoRow('Humidité', '${analyse.humidite!.toStringAsFixed(2)}%'),
                    if (analyse.texture != null)
                      _buildInfoRow('Texture', analyse.texture!),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (analyse.azoteN != null || analyse.phosphoreP != null || analyse.potassiumK != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nutriments (mg/kg)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (analyse.azoteN != null)
                        _buildNutrientRow('Azote (N)', analyse.azoteN!, Colors.blue),
                      if (analyse.phosphoreP != null)
                        _buildNutrientRow('Phosphore (P)', analyse.phosphoreP!, Colors.orange),
                      if (analyse.potassiumK != null)
                        _buildNutrientRow('Potassium (K)', analyse.potassiumK!, Colors.purple),
                      const SizedBox(height: 16),
                      if (analyse.azoteN != null && analyse.phosphoreP != null && analyse.potassiumK != null)
                        SizedBox(
                          height: 200,
                          child: _buildNutrientsChart(),
                        ),
                    ],
                  ),
                ),
              ),
            if (analyse.observations != null && analyse.observations!.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Observations',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(analyse.observations!),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildNutrientRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            '${value.toStringAsFixed(2)} mg/kg',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNutrientsChart() {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxNutrientValue() * 1.2,
        barTouchData: BarTouchData(enabled: false),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                switch (value.toInt()) {
                  case 0:
                    return const Text('N');
                  case 1:
                    return const Text('P');
                  case 2:
                    return const Text('K');
                  default:
                    return const Text('');
                }
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: const FlGridData(show: true),
        borderData: FlBorderData(show: false),
        barGroups: [
          if (analyse.azoteN != null)
            BarChartGroupData(
              x: 0,
              barRods: [
                BarChartRodData(
                  toY: analyse.azoteN!,
                  color: Colors.blue,
                  width: 20,
                ),
              ],
            ),
          if (analyse.phosphoreP != null)
            BarChartGroupData(
              x: 1,
              barRods: [
                BarChartRodData(
                  toY: analyse.phosphoreP!,
                  color: Colors.orange,
                  width: 20,
                ),
              ],
            ),
          if (analyse.potassiumK != null)
            BarChartGroupData(
              x: 2,
              barRods: [
                BarChartRodData(
                  toY: analyse.potassiumK!,
                  color: Colors.purple,
                  width: 20,
                ),
              ],
            ),
        ],
      ),
    );
  }

  double _getMaxNutrientValue() {
    double max = 0;
    if (analyse.azoteN != null && analyse.azoteN! > max) max = analyse.azoteN!;
    if (analyse.phosphoreP != null && analyse.phosphoreP! > max) max = analyse.phosphoreP!;
    if (analyse.potassiumK != null && analyse.potassiumK! > max) max = analyse.potassiumK!;
    return max > 0 ? max : 100;
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateStr;
    }
  }
}

