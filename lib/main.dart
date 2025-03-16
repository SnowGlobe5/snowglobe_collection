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
      debugShowCheckedModeBanner: false,
      title: 'Snowglobe Collection',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212), // Dark background
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurpleAccent,
          secondary: Colors.deepPurple,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF1E1E1E),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Color(0xFF1E1E1E),
          selectedItemColor: Colors.deepPurpleAccent,
          unselectedItemColor: Colors.grey,
        ),
      ),
      home: TabbedHome(),
    );
  }
}