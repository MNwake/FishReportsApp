import 'package:frontend/core/models/fish_graph_data.dart';
import 'package:frontend/core/models/fish_survey.dart';

class FishDetailData {
  final FishSurvey survey;
  final GraphData graphData;

  FishDetailData({
    required this.survey,
    required this.graphData,
  });
} 