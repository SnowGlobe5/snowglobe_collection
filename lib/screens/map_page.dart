import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';

class MapPage extends StatelessWidget {
  final Snowglobe snowglobe;

  MapPage({required this.snowglobe});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Snowglobe Location')),
      body: FlutterMap(
        options: MapOptions(
          center: LatLng(snowglobe.latitude!, snowglobe.longitude!),
          zoom: 13.0,
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                point: LatLng(snowglobe.latitude!, snowglobe.longitude!),
                builder: (ctx) => Icon(Icons.location_on, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
