import 'package:frontend/core/models/fish_survey.dart';

class FishDetailData {
  final GraphData graphData;
  final FishSurvey survey;

  FishDetailData({
    required this.graphData,
    required this.survey,
  });

  factory FishDetailData.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing FishDetailData from JSON:');
    print(json);
    
    return FishDetailData(
      graphData: GraphData.fromJson(json['data'] ?? {}),
      survey: FishSurvey.fromJson(json),
    );
  }
}

class GraphData {
  final List<LengthFrequency> data;

  GraphData({required this.data});

  factory GraphData.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] as List;
    return GraphData(
      data: dataList.map((item) => LengthFrequency.fromJson(item)).toList(),
    );
  }
}

class LengthFrequency {
  final int length;
  final int quantity;

  LengthFrequency({
    required this.length,
    required this.quantity,
  });

  factory LengthFrequency.fromJson(Map<String, dynamic> json) {
    return LengthFrequency(
      length: json['length'] as int,
      quantity: json['quantity'] as int,
    );
  }

  @override
  String toString() => 'LengthFrequency(length: $length, quantity: $quantity)';
}