import 'package:flutter/material.dart';

class CustomHorizontalBarChart extends StatelessWidget {
  final Map<String, int> data;
  final String title;

  const CustomHorizontalBarChart({
    Key? key,
    required this.data,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Text(
          'Nessun dato disponibile',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    // Ordina le chiavi (ad es. in ordine alfabetico)
    List<String> sortedKeys = data.keys.toList()..sort();
    // Trova il valore massimo per calcolare la lunghezza proporzionale della barra
    int maxValue = data.values.fold(0, (prev, element) => element > prev ? element : prev);
    // Larghezza fissa per la label e altezza per ogni riga (barra)
    double labelWidth = 105;
    double rowHeight = 40;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 28, 28, 28),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titolo centrato
          Center(
            child: Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 16),
          // Utilizziamo un LayoutBuilder per ottenere la larghezza disponibile per le barre
          LayoutBuilder(
            builder: (context, constraints) {
              // Calcola la larghezza disponibile per le barre, sottraendo la larghezza fissa della label e lo spazio
              double availableWidth = constraints.maxWidth - labelWidth - 8;
              return Column(
                children: sortedKeys.map((key) {
                  int value = data[key] ?? 0;
                  // Calcola la larghezza della barra in base al valore rispetto al massimo
                  double barWidth = maxValue > 0 ? (value / maxValue) * availableWidth : 0;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        // Label con larghezza fissa, allineata a destra
                        Container(
                          width: labelWidth,
                          alignment: Alignment.centerRight,
                          child: Text(
                            key,
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                        SizedBox(width: 8),
                        // Barra con larghezza proporzionale e valore centrato
                        Container(
                          width: barWidth,
                          height: rowHeight,
                          decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Center(
                            child: Text(
                              value.toString(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}
