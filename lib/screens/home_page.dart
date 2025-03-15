import 'package:flutter/material.dart';
import 'package:snowglobe_collection/services/snowglobe_service.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';

class HomePage extends StatelessWidget {
  final SnowglobeService _snowglobeService = SnowglobeService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Snowglobe Collection')),
      body: FutureBuilder<List<Snowglobe>>(
        future: _snowglobeService.fetchSnowglobes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No snowglobes found.'));
          }

          final snowglobes = snapshot.data!;
          return ListView.builder(
            itemCount: snowglobes.length,
            itemBuilder: (context, index) {
              final snowglobe = snowglobes[index];
              return ListTile(
                title: Text(snowglobe.name),
                subtitle: Text('${snowglobe.size} - ${snowglobe.date.toLocal()}'),
                onTap: () {
                  // Aggiungi logica per aprire una schermata di dettaglio
                },
              );
            },
          );
        },
      ),
    );
  }
}
