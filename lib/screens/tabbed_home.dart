// lib/screens/tabbed_home.dart
import 'package:flutter/material.dart';
import 'snowglobe_list_page.dart';
import 'snowglobe_map_page.dart';
import 'snowglobe_stats_page.dart';
import 'snowglobe_insertion_page.dart';

class TabbedHome extends StatefulWidget {
  @override
  _TabbedHomeState createState() => _TabbedHomeState();
}

class _TabbedHomeState extends State<TabbedHome> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    SnowGlobeListPage(),
    SnowGlobeMapPage(),
    SnowGlobeStatsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                // Naviga alla pagina di inserimento
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SnowGlobeInsertionPage()),
                );
              },
              child: Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'List',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Stats',
          ),
        ],
      ),
    );
  }
}
