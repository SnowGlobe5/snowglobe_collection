import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';
import 'package:snowglobe_collection/services/snowglobe_service.dart';
import 'package:intl/intl.dart';

class SnowglobeMapPage extends StatefulWidget {
  @override
  _SnowglobeMapPageState createState() => _SnowglobeMapPageState();
}

class _SnowglobeMapPageState extends State<SnowglobeMapPage> {
  final SnowglobeService _snowglobeService = SnowglobeService();
  List<Snowglobe> _snowglobes = [];
  bool _isLoading = true;
  int? _selectedMarkerIndex;

  @override
  void initState() {
    super.initState();
    _loadSnowglobes();
  }

  Future<void> _loadSnowglobes() async {
    List<Snowglobe> snowglobes = await _snowglobeService.fetchAllSnowglobes();
    setState(() {
      _snowglobes = snowglobes;
      _isLoading = false;
    });
  }

  // Map year to a specific color
  Color _getColorForYear(int year) {
    List<Color> colors = [
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
    ];
    return colors[year % colors.length];
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

    List<Marker> markers = [];

    // Filter valid snowglobes
    List<Snowglobe> validSnowglobes =
        _snowglobes
            .where((s) => s.latitude != null && s.longitude != null)
            .toList();

    // Create markers
    for (int i = 0; i < validSnowglobes.length; i++) {
      Snowglobe snowglobe = validSnowglobes[i];
      int year = snowglobe.date?.year ?? DateTime.now().year;
      bool isSelected = _selectedMarkerIndex == i;

      // Add tooltip as a separate marker slightly above the pin location
      if (isSelected) {
        // Add tooltip - adjust position to be above the pin
        markers.add(
          Marker(
            point: LatLng(
              snowglobe.latitude!, // Move slightly up on the map
              snowglobe.longitude!,
            ),
            width: 160,
            height: 70,
            alignment: Alignment.bottomCenter,
            child: Transform.translate(
              offset: Offset(0, -90), // Sposta il box 20 pixel verso l'alto
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      snowglobe.name ?? "Unnamed",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      "${snowglobe.city ?? ""}, ${snowglobe.country ?? ""}",
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(snowglobe.date),
                      style: TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }

      // Add the pin marker
      markers.add(
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
              color: _getColorForYear(year),
              size: 40,
            ),
          ),
        ),
      );
    }

    LatLng initialCenter =
        validSnowglobes.isNotEmpty
            ? LatLng(
              validSnowglobes.first.latitude!,
              validSnowglobes.first.longitude!,
            )
            : LatLng(0, 0);

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: 5.0,
        onTap: (_, __) {
          // Close tooltip when tapping on the map
          setState(() {
            _selectedMarkerIndex = null;
          });
        },
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: ['a', 'b', 'c'],
        ),
        MarkerLayer(markers: markers),
      ],
    );
  }
}
