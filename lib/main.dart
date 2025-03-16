import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/tabbed_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializza Supabase (sostituisci URL e anonKey con i tuoi valori)
  await Supabase.initialize(
    url: 'https://lgnkyhsdymwjxtjmimyi.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imxnbmt5aHNkeW13anh0am1pbXlpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDIwNjc0MjUsImV4cCI6MjA1NzY0MzQyNX0.OtYeEWlRVMwClIUZ8CUxZOrFiRYsokKjs-DW_MT8Pww',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Snowglobe Collection',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.deepPurple,
        // Se l'accentColor non viene più usato, puoi utilizzare colorScheme
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple,
        ),
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
        ),
      ),
      home: TabbedHome(),
    );
  }
}
