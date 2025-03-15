import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';

class SnowglobeService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<List<Snowglobe>> fetchSnowglobes() async {
    final response = await _supabaseClient
        .from('snowglobes')
        .select()
        .execute();

    if (response.error != null) {
      throw Exception('Error fetching snowglobes: ${response.error?.message}');
    }

    List<dynamic> data = response.data;
    return data.map((item) => Snowglobe.fromMap(item)).toList();
  }
}
