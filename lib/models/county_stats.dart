import 'county.dart';

class CountyStats {
  final Map<String, double> speciesDistribution;
  final int numberOfLakes;
  final int totalSurveys;
  final int totalFishCaught;
  final int numberOfSpecies;
  final double averageFishPerSurvey;
  final List<String> surveyIds;
  final County county;

  CountyStats({
    required this.speciesDistribution,
    required this.numberOfLakes,
    required this.totalSurveys,
    required this.totalFishCaught,
    required this.numberOfSpecies,
    required this.averageFishPerSurvey,
    required this.surveyIds,
    required this.county,
  });

  factory CountyStats.fromJson(Map<String, dynamic> json) {
    // Convert species distribution map values to doubles
    final Map<String, dynamic> rawDistribution = json['species_distribution'] as Map<String, dynamic>;
    final Map<String, double> distribution = rawDistribution.map(
      (key, value) => MapEntry(key, (value as num).toDouble()),
    );

    return CountyStats(
      speciesDistribution: distribution,
      numberOfLakes: json['number_of_lakes'] as int,
      totalSurveys: json['total_surveys'] as int,
      totalFishCaught: json['total_fish_caught'] as int,
      numberOfSpecies: json['number_of_species'] as int,
      averageFishPerSurvey: (json['average_fish_per_survey'] as num).toDouble(),
      surveyIds: List<String>.from(json['survey_ids'] as List),
      county: County.fromJson(json['county'] as Map<String, dynamic>),
    );
  }
} 