import 'dart:math';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../colors.dart';

class CustomLineChart extends StatelessWidget {
  final Map<String, int> data;
  final String title;

  CustomLineChart({required this.data, required this.title});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Nessun dato disponibile',
          style: TextStyle(color: AppColors.foreground),
        ),
      );
    }

    // Estrae gli anni e calcola il range
    List<int> years = data.keys.map((e) => int.tryParse(e) ?? 0).toList();
    int startYear = years.reduce(min);
    int endYear = years.reduce(max);

    // Crea una lista di punti per ogni anno (inserisce 0 per gli anni mancanti)
    List<FlSpot> spots = [];
    for (int year = startYear; year <= endYear; year++) {
      double count = (data[year.toString()] ?? 0).toDouble();
      spots.add(FlSpot(year.toDouble(), count));
    }

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Color.fromARGB(255, 28, 28, 28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Titolo centrato
          Container(
            margin: EdgeInsets.symmetric(vertical: 8),
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
          // Area del grafico a linee con padding extra a destra
          Container(
            padding: EdgeInsets.fromLTRB(10, 10, 30, 10),
            child: SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  borderData: FlBorderData(show: false),
                  // Aggiunge il touch data per visualizzare il tooltip
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((touchedSpot) {
                          final year = touchedSpot.x.toInt();
                          final value = touchedSpot.y.toInt();
                          return LineTooltipItem(
                            '$year\n$value',
                            TextStyle(color: AppColors.foreground, fontSize: 12, fontWeight: FontWeight.bold),
                          );
                        }).toList();
                      },
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.primary,
                      barWidth: 3,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    )
                  ],
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 32,
                        getTitlesWidget: (value, meta) {
                          // Mostra l'etichetta solo per anni interi
                          if (value % 1 == 0) {
                            return SideTitleWidget(
                              meta: meta,
                              space: 8,
                              child: Transform.rotate(
                                angle: -pi / 4, // Rotazione di 45 gradi
                                child: Text(
                                  value.toInt().toString(),
                                  style: TextStyle(color: AppColors.foreground, fontSize: 12),
                                ),
                              ),
                            );
                          }
                          return Container();
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
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
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  minX: startYear.toDouble(),
                  maxX: endYear.toDouble(),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
