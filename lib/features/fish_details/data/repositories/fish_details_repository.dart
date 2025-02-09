import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/fish_detail_data.dart';
import 'package:frontend/core/services/api_service.dart';

final fishDetailsRepositoryProvider = Provider<FishDetailsRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FishDetailsRepository(apiService);
});

class FishDetailsRepository {
  final ApiService _apiService;

  FishDetailsRepository(this._apiService);

  Future<FishDetailData> getFishDetails(String fishId) async {
    final parts = fishId.split('_');
    final dow = parts[0];
    final species = parts[1];
    final date = parts[2];

    final graphData = await _apiService.getFishGraphData(
      dow: dow,
      species: species,
      date: date,
    );

    final surveys = await _apiService.getFishSurveys(species: species);
    final survey = surveys.firstWhere(
      (s) => s.dowNumber == dow && s.surveyDate == date,
    );

    return FishDetailData(
      graphData: graphData,
      survey: survey,
    );
  }
} 