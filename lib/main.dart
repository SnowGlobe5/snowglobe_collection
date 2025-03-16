// lib/main.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'credentials.dart';
import 'screens/tabbed_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  // Autenticazione automatica con email e password
  final authResponse = await Supabase.instance.client.auth.signInWithPassword(
    email: userEmail,
    password: userPassword,
  );

  if (authResponse.user == null) {
    // Se non viene restituito un utente, qualcosa è andato storto.
    print("Errore di autenticazione: utente non autenticato.");
    // Gestisci l'errore in modo appropriato, ad esempio terminando l'app oppure mostrando un messaggio
  } else {
    print("Autenticazione avvenuta con successo: ${authResponse.user!.email}");
  }

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Snowglobe Collection',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Color(0xFF121212),
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
