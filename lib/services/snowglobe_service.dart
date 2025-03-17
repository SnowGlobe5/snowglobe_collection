import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:snowglobe_collection/models/snowglobe.dart';

class SnowglobeService {
  final supabase = Supabase.instance.client;

  // Retrieves snowglobes with pagination, sorting, and filters.
  Future<List<Snowglobe>> fetchSnowglobes({
    required int offset,
    required int limit,
    String sortField = 'date',
    String sortOrder = 'desc',
    Map<String, String> filters = const {},
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Start with the base query.
    var query = supabase.from('snowglobes').select();

    // Apply date range filter if provided.
    if (startDate != null) {
      // Filter for dates greater than or equal to startDate.
      query = query.gte('date', startDate.toIso8601String());
    }

    if (endDate != null) {
      // Filter for dates less than or equal to endDate (end of day).
      DateTime endOfDay = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        23,
        59,
        59,
      );
      query = query.lte('date', endOfDay.toIso8601String());
    }

    // Apply other filters if provided (case-insensitive partial match).
    filters.forEach((field, value) {
      if (value.isNotEmpty && field != 'date') {
        // Skip date filter since it's handled separately.
        query = query.filter(field, 'ilike', '%$value%');
      }
    });

    // Apply sorting.
    bool ascending = sortOrder.toLowerCase() == 'asc';

    // Apply pagination and sorting in the final query.
    final data = await query
        .order(sortField, ascending: ascending)
        .range(offset, offset + limit - 1);

    // Supabase will throw an exception if something goes wrong.
    return (data as List<dynamic>)
        .map((item) => Snowglobe.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  // Retrieves all snowglobes (useful for the map).
  Future<List<Snowglobe>> fetchAllSnowglobes() async {
    final data = await supabase
        .from('snowglobes')
        .select()
        .order('date', ascending: false);
    return (data as List<dynamic>)
        .map((item) => Snowglobe.fromMap(item as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, int>> getAcquisitionsPerYear() async {
    try {
      final response = await supabase
          .from('snowglobes')
          .select('date')
          .order('date', ascending: true);

      final data = response as List<dynamic>;
      final Map<String, int> yearCounts = {};
      for (final item in data) {
        final dateStr = item['date'] as String?;
        if (dateStr == null) continue;
        final date = DateTime.tryParse(dateStr);
        if (date == null) continue;
        final year = date.year.toString();
        yearCounts[year] = (yearCounts[year] ?? 0) + 1;
      }
      return yearCounts;
    } catch (e) {
      throw Exception('Error loading data: $e');
    }
  }

  Future<Map<String, int>> getCountryDistribution() async {
    try {
      final response = await supabase
          .from('snowglobes')
          .select('country')
          .not('country', 'is', null);

      final data = response as List<dynamic>;
      final Map<String, int> countryCounts = {};
      for (final item in data) {
        final country = item['country'] as String?;
        if (country == null) continue;
        countryCounts[country] = (countryCounts[country] ?? 0) + 1;
      }
      return countryCounts;
    } catch (e) {
      throw Exception('Error loading data: $e');
    }
  }

  Future<Map<String, int>> getSizeDistribution() async {
    try {
      final response = await supabase.from('snowglobes').select('size');

      final data = response as List<dynamic>;
      final Map<String, int> sizeCounts = {};
      for (final item in data) {
        final size = item['size'] as String?;
        if (size == null) continue;
        sizeCounts[size] = (sizeCounts[size] ?? 0) + 1;
      }
      return sizeCounts;
    } catch (e) {
      throw Exception('Error loading data: $e');
    }
  }

  Future<Map<String, int>> getShapeDistribution() async {
    try {
      final response = await supabase.from('snowglobes').select('shape');

      final data = response as List<dynamic>;
      final Map<String, int> shapeCounts = {};
      for (final item in data) {
        final shape = item['shape'] as String?;
        if (shape == null) continue;
        shapeCounts[shape] = (shapeCounts[shape] ?? 0) + 1;
      }
      return shapeCounts;
    } catch (e) {
      throw Exception('Error loading data: $e');
    }
  }

  Future<Snowglobe?> insertSnowglobe({
    required String name,
    required String size,
    DateTime? date,
    required String code,
    required String shape,
    String? country,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = await supabase.from('snowglobes').insert({
        'name': name,
        'size': size,
        'date': date?.toIso8601String(),
        'code': code,
        'shape': shape,
        'country': country,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
        'image_url': null, // Will be updated after image upload.
      }).select() as List<dynamic>;

      if (data.isNotEmpty) {
        return Snowglobe.fromMap(data[0] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error inserting record: $e');
    }
  }

  // Updates an existing snowglobe record.
  Future<bool> updateSnowglobe({
    required int id,
    required String name,
    required String size,
    DateTime? date,
    required String code,
    required String shape,
    String? country,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final data = await supabase.from('snowglobes').update({
        'name': name,
        'size': size,
        'date': date?.toIso8601String(),
        'code': code,
        'shape': shape,
        'country': country,
        'city': city,
        'latitude': latitude,
        'longitude': longitude,
      }).eq('id', id).select() as List<dynamic>;

      return data.isNotEmpty;
    } catch (e) {
      throw Exception('Error updating record: $e');
    }
  }

  // Deletes a snowglobe record by its ID.
  Future<bool> deleteSnowglobe(int id) async {
    try {
      await supabase.from('snowglobes').delete().eq('id', id);
      return true;
    } catch (e) {
      throw Exception('Error deleting record: $e');
    }
  }
}
