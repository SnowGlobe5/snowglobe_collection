import 'package:flutter/material.dart';
import 'snowglobe_list_page.dart';
import 'snowglobe_map_page.dart';

class TabbedHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Due tab: Lista e Mappa
      child: Scaffold(
        appBar: AppBar(
          title: Text('Snowglobe Collection'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Lista'),
              Tab(text: 'Mappa'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SnowglobeListPage(),
            SnowglobeMapPage(),
          ],
        ),
        // Bottone per aggiungere un nuovo record (stub)
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Implement add new record
            print("Add new record tapped");
          },
          child: Icon(Icons.add),
        ),
      ),
    );
  }
}
