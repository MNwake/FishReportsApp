class County {
  final String id;
  final String countyName;
  final String fipsCode;
  final String countySeat;
  final int established;
  final String origin;
  final String etymology;
  final int population;
  final double areaSqMiles;
  final String mapImageUrl;
  final List<String> lakes;

  County({
    required this.id,
    required this.countyName,
    required this.fipsCode,
    required this.countySeat,
    required this.established,
    required this.origin,
    required this.etymology,
    required this.population,
    required this.areaSqMiles,
    required this.mapImageUrl,
    required this.lakes,
  });

  factory County.fromJson(Map<String, dynamic> json) {
    try {
      return County(
        id: json['id']?.toString() ?? '',
        countyName: json['county_name']?.toString() ?? '',
        fipsCode: json['fips_code']?.toString() ?? '',
        countySeat: json['county_seat']?.toString() ?? '',
        established: int.tryParse(json['established']?.toString() ?? '0') ?? 0,
        origin: json['origin']?.toString() ?? '',
        etymology: json['etymology']?.toString() ?? '',
        population: int.tryParse(json['population']?.toString() ?? '0') ?? 0,
        areaSqMiles: double.tryParse(json['area_sq_miles']?.toString() ?? '0') ?? 0.0,
        mapImageUrl: json['map_image_url']?.toString() ?? '',
        lakes: json['lakes']?.cast<String>() ?? [],
      );
    } catch (e) {
      print('Error parsing county: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'county_name': countyName,
    'fips_code': fipsCode,
    'county_seat': countySeat,
    'established': established,
    'origin': origin,
    'etymology': etymology,
    'population': population,
    'area_sq_miles': areaSqMiles,
    'map_image_url': mapImageUrl,
    'lakes': lakes,
  };
} 