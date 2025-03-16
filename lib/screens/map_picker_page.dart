// lib/screens/map_picker_page.dart
import 'package:flutter/material.dart';

class MapPickerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Seleziona posizione'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Ritorna coordinate dummy (es. coordinate di Roma)
            Navigator.pop(context, {'latitude': 41.9028, 'longitude': 12.4964});
          },
          child: Text('Seleziona posizione (dummy)'),
        ),
      ),
    );
  }
}
