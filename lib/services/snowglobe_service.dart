import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';

class SnowglobeService {
  final supabase = Supabase.instance.client;

  // Recupera le snowglobes con paginazione
  Future<List<Snowglobe>> fetchSnowglobes({required int offset, required int limit}) async {
    final data = await supabase
        .from('snowglobes')
        .select()
        .order('date', ascending: false)
        .range(offset, offset + limit - 1);
    // Se qualcosa va storto, Supabase lancerà un'eccezione
    return (data as List<dynamic>)
        .map((item) => Snowglobe.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // Recupera tutte le snowglobes (utile per la mappa)
  Future<List<Snowglobe>> fetchAllSnowglobes() async {
    final data = await supabase
        .from('snowglobes')
        .select()
        .order('date', ascending: false);
    return (data as List<dynamic>)
        .map((item) => Snowglobe.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
