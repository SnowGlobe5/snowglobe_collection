// lib/main.dart
import 'package:flutter/material.dart';
import 'colors.dart';
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
      title: 'SnowGlobe Collection',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        colorScheme: ColorScheme.dark(
          primary: AppColors.primary,
          secondary: AppColors.secondary,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.appBarBackground,
          titleTextStyle: TextStyle(
            color: AppColors.foreground,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: AppColors.appBarBackground,
          selectedItemColor: AppColors.selectedItem,
          unselectedItemColor: AppColors.unselectedItem,
        ),
      ),
      home: TabbedHome(),
    );
  }
}
