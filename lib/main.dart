import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';  // Importa la classe Snowglobe
import 'package:snowglobe_collection/screens/home_page.dart';
import 'package:snowglobe_collection/screens/map_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Supabase
  await Supabase.initialize(
    url: 'https://<your-project-ref>.supabase.co', // Sostituisci con il tuo URL di Supabase
    anonKey: '<your-anon-key>', // Sostituisci con la tua chiave anonima
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snowglobe Collection',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      // Home page principale
      home: HomePage(),
      // Definisci le rotte per navigare nelle schermate
      routes: {
        '/map': (context) => MapPage(
              snowglobe: ModalRoute.of(context)?.settings.arguments as Snowglobe,
            ),
      },
    );
  }
}
