import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../colors.dart';

class CustomPieChart extends StatelessWidget {
  final Map<String, int> data;
  final String title;
  final int maxSections;

  CustomPieChart({
    required this.data,
    required this.title,
    this.maxSections = 5,
  });

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

    // Ordina le entry in ordine decrescente in base al valore
    List<MapEntry<String, int>> entries = data.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));

    // Raggruppa le restanti voci in "Other" se ce ne sono più di maxSections
    List<MapEntry<String, int>> displayEntries = entries;
    int othersTotal = 0;
    if (entries.length > maxSections) {
      displayEntries = entries.take(maxSections).toList();
      othersTotal = entries.skip(maxSections).fold(0, (sum, entry) => sum + entry.value);
      displayEntries.add(MapEntry("Other", othersTotal));
    }

    int total = data.values.fold(0, (sum, element) => sum + element);
    List<PieChartSectionData> sections = [];
    double radius = 50; // raggio usato per la fetta

    // Loop per ogni sezione del grafico
    for (int i = 0; i < displayEntries.length; i++) {
      final entry = displayEntries[i];
      final double percentage = (entry.value / total * 100);
      
      // Crea la label da visualizzare
      String label = '${entry.key}\n${percentage.toStringAsFixed(1)}%';
      
      // Calcola l'offset: se il testo sta bene (e la fetta non è troppo piccola) lo manteniamo all'interno
      double offset = 0.6; // offset di default (all'interno)
      if (percentage < 5 ) {
        offset = 1.3 + (i-3) * 0.6; // sposta la label all'esterno
      }
      
      sections.add(PieChartSectionData(
        color: AppColors.primary.withOpacity(1 - (i * 0.1)),
        value: entry.value.toDouble(),
        title: label,
        radius: radius,
        titleStyle: TextStyle(fontSize: 10, color: AppColors.foreground),
        titlePositionPercentageOffset: offset,
      ));
    }

    return Container(
      margin: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 28, 28, 28),
        borderRadius: BorderRadius.circular(12),
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
          // Area del grafico a torta
          Container(
            padding: EdgeInsets.all(10),
            child: SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: sections,
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
