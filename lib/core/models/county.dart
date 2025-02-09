class County {
  final String name;
  final String mapImageUrl;

  County({
    required this.name,
    required this.mapImageUrl,
  });

  factory County.fromJson(Map<String, dynamic> json) {
    return County(
      name: json['county_name'] as String,
      mapImageUrl: json['map_image_url'] as String,
    );
  }
} 