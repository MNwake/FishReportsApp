import 'length_data.dart';

class SpeciesStats {
  final String species;
  final double averageLength;
  final int shortestLength;
  final int biggestLength;
  final double percentLakes;
  final int totalFish;
  final List<LengthData> graphData;
  final List<CountyPercentage> counties;

  SpeciesStats({
    required this.species,
    required this.averageLength,
    required this.shortestLength,
    required this.biggestLength,
    required this.percentLakes,
    required this.totalFish,
    required this.graphData,
    required this.counties,
  });

  factory SpeciesStats.fromJson(Map<String, dynamic> json) {
    return SpeciesStats(
      species: json['species'] as String,
      averageLength: (json['average_length'] as num).toDouble(),
      shortestLength: json['shortest_length'] as int,
      biggestLength: json['biggest_length'] as int,
      percentLakes: (json['percent_lakes'] as num).toDouble(),
      totalFish: json['total_fish'] as int,
      graphData: (json['graph_data'] as List)
          .map((data) => LengthData.fromJson(data as Map<String, dynamic>))
          .toList(),
      counties: (json['counties'] as List)
          .map((data) => CountyPercentage.fromJson(data as Map<String, dynamic>))
          .toList(),
    );
  }
}

class CountyPercentage {
  final String id;
  final double percentage;

  CountyPercentage({
    required this.id,
    required this.percentage,
  });

  factory CountyPercentage.fromJson(Map<String, dynamic> json) {
    return CountyPercentage(
      id: json['id'] as String,
      percentage: (json['percentage'] as num).toDouble(),
    );
  }
} 