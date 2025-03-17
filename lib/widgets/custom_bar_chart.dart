import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math; 
import '../colors.dart';

class CustomBarChart extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final bool rotateLabels; // Nuovo parametro per ruotare le label

  CustomBarChart({
    required this.data,
    required this.title,
    this.rotateLabels = false, // Default: false (label normali)
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Color.fromARGB(255, 28, 28, 28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Barra del titolo centrata
          Container(
            margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 28, 28, 28),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.0)),
            ),
            child: Center(
              child: Text(
                title,
                style: TextStyle(
                  color: AppColors.foreground,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Sezione del grafico
          Container(
            padding: EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12.0)),
            ),
            child: _buildChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Nessun dato disponibile',
          style: TextStyle(color: AppColors.foreground, fontSize: 16),
        ),
      );
    }

    List<String> sortedKeys = data.keys.toList()..sort();
    List<BarChartGroupData> barGroups = List.generate(sortedKeys.length, (index) {
      final key = sortedKeys[index];
      final value = data[key] ?? 0;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: value.toDouble(),
            color: AppColors.primary,
            width: 16,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(6),
            ),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: data.values.isEmpty
                  ? 10
                  : data.values.reduce((a, b) => a > b ? a : b).toDouble(),
              color: AppColors.primary.withOpacity(0.1),
            ),
          ),
        ],
      );
    });

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          // Configurazione dei tooltip
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipRoundedRadius: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  rod.toY.toString(),
                  TextStyle(
                    color: AppColors.foreground,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),
          ),
          borderData: FlBorderData(show: false),
          barGroups: barGroups,
          titlesData: FlTitlesData(
            show: true,
            // Etichette sull'asse x (in basso)
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (double value, TitleMeta meta) {
                  int index = value.toInt();
                  if (index < sortedKeys.length) {
                    final label = Text(
                      sortedKeys[index],
                      style: TextStyle(color: AppColors.foreground, fontSize: 12),
                    );
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: rotateLabels
                          ? Transform.rotate(
                              angle: math.pi / 4, // 45 gradi in radianti
                              child: label,
                            )
                          : label,
                    );
                  }
                  return Container();
                },
              ),
            ),
            // Etichette sull'asse y (a sinistra)
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (double value, TitleMeta meta) {
                  return SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      value.toInt().toString(),
                      style: TextStyle(color: AppColors.foreground, fontSize: 12),
                    ),
                  );
                },
              ),
            ),
            // Nascondo le etichette in alto e a destra
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }
}
