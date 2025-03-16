import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';

class SnowglobeService {
  final supabase = Supabase.instance.client;

  // Retrieves snowglobes with pagination, sorting, and filters
  Future<List<Snowglobe>> fetchSnowglobes({
    required int offset,
    required int limit,
    String sortField = 'date',
    String sortOrder = 'desc',
    Map<String, String> filters = const {},
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Start with the base query
    var query = supabase.from('snowglobes').select();

    // Apply date range filter if provided
    if (startDate != null) {
      // Filter for dates greater than or equal to startDate
      query = query.gte('date', startDate.toIso8601String());
    }
    
    if (endDate != null) {
      // Filter for dates less than or equal to endDate (end of day)
      DateTime endOfDay = DateTime(endDate.year, endDate.month, endDate.day, 23, 59, 59);
      query = query.lte('date', endOfDay.toIso8601String());
    }

    // Apply other filters if provided (case-insensitive partial match)
    filters.forEach((field, value) {
      if (value.isNotEmpty && field != 'date') {  // Skip date filter as we handle it separately
        query = query.filter(field, 'ilike', '%$value%');
      }
    });

    // Apply sorting
    bool ascending = sortOrder.toLowerCase() == 'asc';
    
    // Apply pagination and sorting in the final execution
    final data = await query
        .order(sortField, ascending: ascending)
        .range(offset, offset + limit - 1);

    // Supabase will throw an exception if something goes wrong
    return (data as List<dynamic>)
        .map((item) => Snowglobe.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // Retrieves all snowglobes (useful for the map)
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