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
      imageUrl: json['image_url'] == null || (json['image_url'] as String).isEmpty 
          ? 'assets/images/No_Image_Available.jpg' 
          : json['image_url'] as String,
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