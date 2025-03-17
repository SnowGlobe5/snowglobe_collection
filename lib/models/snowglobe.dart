class SnowGlobe {
  final int id;
  final String name;
  final String size;
  final DateTime? date;
  final String code;
  final String shape;
  final String? country;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;

  SnowGlobe({
    required this.id,
    required this.name,
    required this.size,
    this.date,
    required this.code,
    required this.shape,
    this.country,
    this.city,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  factory SnowGlobe.fromMap(Map<String, dynamic> map) {
    return SnowGlobe(
      id: map['id'],
      name: map['name'],
      size: map['size'],
      date: map['date'] != null ? DateTime.tryParse(map['date']) : null,
      code: map['code'],
      shape: map['shape'],
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      latitude: map['latitude'] != null ? (map['latitude'] as num).toDouble() : null,
      longitude: map['longitude'] != null ? (map['longitude'] as num).toDouble() : null,
      imageUrl: map['image_url'],
    );
  }
}
