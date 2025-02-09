import 'package:flutter/foundation.dart';

@immutable
class FishSurvey {
  final String surveyID;
  final String dowNumber;
  final String lakeName;
  final String countyName;
  final String surveyDate;
  final String speciesName;
  final String imageUrl;
  final String description;
  final int totalCatch;
  final int maxLength;
  final int minLength;
  final bool isGameFish;

  const FishSurvey({
    required this.surveyID,
    required this.dowNumber,
    required this.lakeName,
    required this.countyName,
    required this.surveyDate,
    required this.speciesName,
    required this.imageUrl,
    required this.description,
    required this.totalCatch,
    required this.maxLength,
    required this.minLength,
    this.isGameFish = false,
  });

  factory FishSurvey.fromJson(Map<String, dynamic> json) {
    return FishSurvey(
      surveyID: json['surveyID']?.toString() ?? '',
      dowNumber: json['dow_number']?.toString() ?? '',
      lakeName: json['lake_name'] as String? ?? '',
      countyName: json['county_name'] as String? ?? '',
      surveyDate: json['survey_date'] as String? ?? '',
      speciesName: json['species_name'] as String? ?? '',
      imageUrl: json['image_url'] as String? ?? '',
      description: json['description'] as String? ?? '',
      totalCatch: json['total_catch'] as int? ?? 0,
      maxLength: json['max_length'] as int? ?? 0,
      minLength: json['min_length'] as int? ?? 0,
      isGameFish: json['game_fish'] == 'true',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'surveyID': surveyID,
      'dow_number': dowNumber,
      'county_name': countyName,
      'lake_name': lakeName,
      'survey_date': surveyDate,
      'species_name': speciesName,
      'image_url': imageUrl,
      'description': description,
      'min_length': minLength,
      'max_length': maxLength,
      'total_catch': totalCatch,
      'game_fish': isGameFish,
    };
  }
} 