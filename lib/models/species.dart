class Species {
  final String id;
  final String commonName;
  final bool gameFish;
  final String imageUrl;
  final String? description;
  final String? scientificName;
  final String? speciesGroup;

  Species({
    required this.id,
    required this.commonName,
    required this.gameFish,
    required this.imageUrl,
    this.description,
    this.scientificName,
    this.speciesGroup,
  });

  factory Species.fromJson(Map<String, dynamic> json) {
    return Species(
      id: json['id'] as String,
      commonName: json['common_name'] as String,
      gameFish: (json['game_fish'] as String).toLowerCase() == 'true',
      imageUrl: json['image_url'] as String,
      description: json['description'] as String?,
      scientificName: json['scientific_name'] as String?,
      speciesGroup: json['species_group'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'common_name': commonName,
    'game_fish': gameFish,
    'image_url': imageUrl,
    'description': description,
    'scientific_name': scientificName,
    'species_group': speciesGroup,
  };
} 