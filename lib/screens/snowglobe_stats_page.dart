import 'package:flutter/material.dart';
import 'package:snowglobe_collection/widgets/custom_line_chart.dart';
import 'package:snowglobe_collection/widgets/custom_horizontal_bar_chart.dart';
import 'package:snowglobe_collection/widgets/custom_pie_chart.dart';
import 'package:snowglobe_collection/widgets/custom_bar_chart.dart';
import 'package:snowglobe_collection/services/snowglobe_service.dart';

class SnowGlobeStatsPage extends StatefulWidget {
  @override
  _SnowGlobeStatsPageState createState() => _SnowGlobeStatsPageState();
}

class _SnowGlobeStatsPageState extends State<SnowGlobeStatsPage> {
  late Map<String, int> yearData;
  late Map<String, int> countryData;
  late Map<String, int> sizeData;
  late Map<String, int> shapeData;

  bool isLoading = true;
  final SnowGlobeService _service = SnowGlobeService();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      yearData = await _service.getAcquisitionsPerYear() ?? {};
      countryData = await _service.getCountryDistribution() ?? {};
      sizeData = await _service.getSizeDistribution() ?? {};
      shapeData = await _service.getShapeDistribution() ?? {};
    } catch (e) {
      print('Error loading data: $e');
      yearData = {};
      countryData = {};
      sizeData = {};
      shapeData = {};
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SnowGlobe Statistics')),
      body: Padding(
        padding: const EdgeInsets.all(0.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  // Grafico a linee per il trend degli anni
                  CustomLineChart(
                    data: yearData.isNotEmpty ? yearData : {'No Data': 0},
                    title: 'Acquisitions per Year',
                  ),
                  // Oppure usa il grafico a barre orizzontale per le country:
                  CustomHorizontalBarChart(
                    data: countryData.isNotEmpty ? countryData : {'No Data': 0},
                    title: 'Country Distribution',
                  ),
                  // Grafico a torta per la distribuzione delle dimensioni
                  CustomPieChart(
                    data: sizeData.isNotEmpty ? sizeData : {'No Data': 0},
                    title: 'Size Distribution',
                  ),
                  // Grafico a barre per la distribuzione delle forme (verticale)
                  CustomBarChart(
                    data: shapeData.isNotEmpty ? shapeData : {'No Data': 0},
                    title: 'Shape Distribution',
                  ),
                ],
              ),
      ),
    );
  }
}
