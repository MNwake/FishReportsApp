import 'species.dart';

class FishCount {
  final int length;
  final int quantity;

  FishCount({
    required this.length,
    required this.quantity,
  });

  factory FishCount.fromJson(Map<String, dynamic> json) {
    return FishCount(
      length: json['length'] as int,
      quantity: json['quantity'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'length': length,
    'quantity': quantity,
  };
}

class LengthData {
  final Species? species;
  final int minimumLength;
  final int maximumLength;
  final List<FishCount> fishCount;

  LengthData({
    this.species,
    required this.minimumLength,
    required this.maximumLength,
    required this.fishCount,
  });

  factory LengthData.fromJson(Map<String, dynamic> json) {
    return LengthData(
      species: json['species'] != null ? Species.fromJson(json['species']) : null,
      minimumLength: json['minimum_length'] as int,
      maximumLength: json['maximum_length'] as int,
      fishCount: (json['fishCount'] as List)
          .map((e) => FishCount.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'species': species?.toJson(),
    'minimum_length': minimumLength,
    'maximum_length': maximumLength,
    'fishCount': fishCount.map((e) => e.toJson()).toList(),
  };
}

class FishCatchSummary {
  final String? species;
  final int? totalCatch;

  FishCatchSummary({
    this.species,
    this.totalCatch,
  });

  factory FishCatchSummary.fromJson(Map<String, dynamic> json) {
    return FishCatchSummary(
      species: json['species'] as String?,
      totalCatch: json['totalCatch'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'species': species,
    'totalCatch': totalCatch,
  };
}

class Survey {
  final String surveyId;
  final String surveyDate;
  final List<FishCatchSummary> fishCatchSummaries;
  final Map<String, LengthData> lengths;

  Survey({
    required this.surveyId,
    required this.surveyDate,
    required this.fishCatchSummaries,
    required this.lengths,
  });

  factory Survey.fromJson(Map<String, dynamic> json) {
    return Survey(
      surveyId: json['surveyID'] as String,
      surveyDate: json['surveyDate'] as String,
      fishCatchSummaries: (json['fishCatchSummaries'] as List)
          .map((e) => FishCatchSummary.fromJson(e as Map<String, dynamic>))
          .toList(),
      lengths: (json['lengths'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(
          key,
          LengthData.fromJson(value as Map<String, dynamic>),
        ),
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'surveyID': surveyId,
    'surveyDate': surveyDate,
    'fishCatchSummaries': fishCatchSummaries.map((e) => e.toJson()).toList(),
    'lengths': lengths.map((key, value) => MapEntry(key, value.toJson())),
  };
}

class FishData {
  final String countyName;
  final String narrative;
  final int dowNumber;
  final String surveyType;
  final String surveySubType;
  final String imageUrl;
  final String lakeName;
  final int maxLength;
  final int minLength;
  final String speciesName;
  final String surveyId;
  final String surveyDate;
  final int totalCatch;

  FishData({
    required this.countyName,
    required this.narrative,
    required this.dowNumber,
    required this.surveyType,
    required this.surveySubType,
    required this.imageUrl,
    required this.lakeName,
    required this.maxLength,
    required this.minLength,
    required this.speciesName,
    required this.surveyId,
    required this.surveyDate,
    required this.totalCatch,
  });

  factory FishData.fromJson(Map<String, dynamic> json) {
    return FishData(
      countyName: json['county_name'] as String,
      narrative: json['narrative'] as String,
      dowNumber: int.parse(json['dow_number'].toString()),
      surveyType: json['survey_type'] as String,
      surveySubType: json['survey_sub_type'] as String,
      imageUrl: json['image_url'] as String,
      lakeName: json['lake_name'] as String,
      maxLength: int.parse(json['max_length'].toString()),
      minLength: int.parse(json['min_length'].toString()),
      speciesName: json['species_name'] as String,
      surveyId: json['surveyID'] as String,
      surveyDate: json['survey_date'] as String,
      totalCatch: int.parse(json['total_catch'].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
    'county_name': countyName,
    'narrative': narrative,
    'dow_number': dowNumber,
    'survey_type': surveyType,
    'survey_sub_type': surveySubType,
    'image_url': imageUrl,
    'lake_name': lakeName,
    'max_length': maxLength,
    'min_length': minLength,
    'species_name': speciesName,
    'surveyID': surveyId,
    'survey_date': surveyDate,
    'total_catch': totalCatch,
  };
} 