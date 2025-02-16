import 'species.dart';
import 'fish_data.dart';
import 'length_data.dart';

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

  int get year => DateTime.parse(surveyDate).year;

  static int getOldestYear(List<dynamic> surveys) {
    return 1962; // Fixed oldest year
  }

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