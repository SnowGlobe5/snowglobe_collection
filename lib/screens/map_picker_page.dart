// lib/screens/map_picker_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import '../colors.dart';

class MapPickerPage extends StatefulWidget {
  @override
  _MapPickerPageState createState() => _MapPickerPageState();
}

class _MapPickerPageState extends State<MapPickerPage> {
  LatLng? _selectedPosition;
  String? _selectedCity;
  String? _selectedCountry;
  String? _selectedAddress; // Per la visualizzazione
  final MapController _mapController = MapController();

  Future<void> _updateAddress(LatLng position) async {
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        setState(() {
          _selectedCity = (place.locality != null && place.locality!.isNotEmpty)
    ? place.locality!
    : (place.subLocality != null && place.subLocality!.isNotEmpty)
        ? place.subLocality!
        : (place.name != null && place.name!.isNotEmpty)
            ? place.name!
            : "Unknown city";
          _selectedCountry = place.country ?? "Unknown country";
          _selectedAddress = "${_selectedCity}, ${_selectedCountry}";
        });
      } else {
        setState(() {
          _selectedCity = "Unknown city";
          _selectedCountry = "Unknown country";
          _selectedAddress = "Unknown location";
        });
      }
    } catch (e) {
      setState(() {
        _selectedCity = "Error";
        _selectedCountry = "";
        _selectedAddress = "Error retrieving address";
      });
    }
  }

  void _onMapTap(TapPosition tapPosition, LatLng latlng) {
    setState(() {
      _selectedPosition = latlng;
      _selectedCity = null;
      _selectedCountry = null;
      _selectedAddress = null;
    });
    _updateAddress(latlng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Select Location')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(45.464211, 9.191383), // Centro di default (es. Milano)
                onTap: _onMapTap,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: ['a', 'b', 'c'],
                ),
                if (_selectedPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _selectedPosition!,
                        child: Icon(
                          Icons.location_on,
                          color: AppColors.primary,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              _selectedAddress != null
                  ? 'Selected location: $_selectedAddress'
                  : 'Tap on the map to select a location',
              style: TextStyle(fontSize: 16),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton.icon(
              onPressed: _selectedPosition == null
                  ? null
                  : () {
                      Navigator.pop(context, {
                        'latitude': _selectedPosition!.latitude,
                        'longitude': _selectedPosition!.longitude,
                        'city': _selectedCity ?? '',
                        'country': _selectedCountry ?? '',
                      });
                    },
              icon: Icon(Icons.check),
              label: Text('Confirm'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
