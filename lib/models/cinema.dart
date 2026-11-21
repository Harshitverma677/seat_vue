/// Typed data model representing a Cinema hall in Delhi or other cities.
class Cinema {
  final String id;
  final String name;
  final String locality;
  final String city;
  final List<String> formats;
  final String address;
  final double rating;
  final double distanceKm;

  const Cinema({
    required this.id,
    required this.name,
    required this.locality,
    this.city = 'Delhi',
    required this.formats,
    required this.address,
    this.rating = 4.6,
    this.distanceKm = 3.2,
  });
}
