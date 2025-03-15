class Snowglobe {
  final String id;
  final String name;
  final String size;
  final DateTime date;
  final String code;
  final String shape;
  final String country;
  final String city;
  final double? latitude;
  final double? longitude;
  final String? imageUrl;

  Snowglobe({
    required this.id,
    required this.name,
    required this.size,
    required this.date,
    required this.code,
    required this.shape,
    required this.country,
    required this.city,
    this.latitude,
    this.longitude,
    this.imageUrl,
  });

  factory Snowglobe.fromMap(Map<String, dynamic> map) {
    return Snowglobe(
      id: map['id'],
      name: map['name'],
      size: map['size'],
      date: DateTime.parse(map['date']),
      code: map['code'],
      shape: map['shape'],
      country: map['country'] ?? '',
      city: map['city'] ?? '',
      latitude: map['latitude'],
      longitude: map['longitude'],
      imageUrl: map['image_url'],
    );
  }
}
