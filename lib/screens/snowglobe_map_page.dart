import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';
import 'package:snowglobe_collection/services/snowglobe_service.dart';
import 'package:intl/intl.dart';
import '../colors.dart';

class SnowGlobeMapPage extends StatefulWidget {
  @override
  _SnowGlobeMapPageState createState() => _SnowGlobeMapPageState();
}

class _SnowGlobeMapPageState extends State<SnowGlobeMapPage> {
  final SnowGlobeService _snowglobeService = SnowGlobeService();
  List<SnowGlobe> _snowglobes = [];
  bool _isLoading = true;
  int? _selectedMarkerIndex;

  @override
  void initState() {
    super.initState();
    _loadSnowGlobes();
  }

  Future<void> _loadSnowGlobes() async {
    List<SnowGlobe> snowglobes = await _snowglobeService.fetchAllSnowGlobes();
    setState(() {
      _snowglobes = snowglobes;
      _isLoading = false;
    });
  }

  // List of at least 30 colors for markers
  final List<Color> _markerColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.brown,
    Colors.pink,
    Colors.indigo,
    Colors.cyan,
    Colors.amber,
    Colors.lime,
    Colors.deepOrange,
    Colors.deepPurple,
    Colors.lightBlue,
    Colors.lightGreen,
    Colors.yellow,
    Colors.grey,
    Colors.blueGrey,
    Colors.redAccent,
    Colors.blueAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
    Colors.purpleAccent,
    Colors.tealAccent,
    Colors.indigoAccent,
    Colors.cyanAccent,
    Colors.amberAccent,
    Colors.deepOrangeAccent,
    Colors.lightGreenAccent,
  ];

  // Get color based on year using modulus of the color list length
  Color _getColorForYear(int year) {
    return _markerColors[year % _markerColors.length];
  }

  // Format date for display
  String _formatDate(DateTime? date) {
    if (date == null) return "Unknown date";
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    List<Marker> pinMarkers = [];
    List<Marker> tooltipMarkers = [];

    // Filter snowglobes with valid coordinates
    List<SnowGlobe> validSnowGlobes = _snowglobes
        .where((s) => s.latitude != null && s.longitude != null)
        .toList();

    for (int i = 0; i < validSnowGlobes.length; i++) {
      SnowGlobe snowglobe = validSnowGlobes[i];
      bool isSelected = _selectedMarkerIndex == i;

      // Determine marker color:
      // if the snowglobe has no date, use black, otherwise use the color based on the year.
      Color markerColor = (snowglobe.date == null)
          ? Colors.black
          : _getColorForYear(snowglobe.date!.year);

      // Tooltip marker: will be displayed on top of everything when selected
      if (isSelected) {
        tooltipMarkers.add(
          Marker(
            point: LatLng(snowglobe.latitude!, snowglobe.longitude!),
            width: 160,
            height: 70,
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, -90), // Move tooltip above the pin
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.scaffoldBackground,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snowglobe.name ?? "Unnamed",
                      style: TextStyle(
                        color: AppColors.foreground,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${snowglobe.city ?? ""}, ${snowglobe.country ?? ""}",
                      style: TextStyle(color: AppColors.foreground, fontSize: 10),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(snowglobe.date),
                      style: TextStyle(color: AppColors.foreground, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Pin marker
      pinMarkers.add(
        Marker(
          point: LatLng(snowglobe.latitude!, snowglobe.longitude!),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedMarkerIndex = isSelected ? null : i;
              });
            },
            child: Icon(
              Icons.location_on,
              color: markerColor,
              size: 40,
            ),
          ),
        ),
      );
    }

    LatLng initialCenter = validSnowGlobes.isNotEmpty
        ? LatLng(validSnowGlobes.first.latitude!, validSnowGlobes.first.longitude!)
        : LatLng(0, 0);

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 5.0,
        onTap: (_, __) {
          // Deselect marker on map tap
          setState(() {
            _selectedMarkerIndex = null;
          });
        },
      ),
      children: [
        // Possible map styles (Tile providers):
        // - OpenStreetMap Standard: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        // - OpenStreetMap Humanitarian: "https://{s}.tile.openstreetmap.fr/hot/{z}/{x}/{y}.png"
        // - Stamen Toner: "https://stamen-tiles.a.ssl.fastly.net/toner/{z}/{x}/{y}.png"
        // - Stamen Watercolor: "https://stamen-tiles.a.ssl.fastly.net/watercolor/{z}/{x}/{y}.jpg"
        // - CartoDB Positron: "https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png"
        // - CartoDB Dark Matter: "https://cartodb-basemaps-a.global.ssl.fastly.net/dark_all/{z}/{x}/{y}.png"
        TileLayer(
          urlTemplate: "https://cartodb-basemaps-a.global.ssl.fastly.net/spotify_dark/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        // Pin markers layer
        MarkerLayer(markers: pinMarkers),
        // Tooltip markers layer (always on top)
        MarkerLayer(markers: tooltipMarkers),
      ],
    );
  }
}
