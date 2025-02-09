import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/fish_graph_data.dart';
import 'package:frontend/core/models/paginated_response.dart';
import 'package:frontend/core/services/api_service.dart';
import 'package:frontend/core/models/county.dart';
import 'package:frontend/core/models/fish_survey.dart';

final fishRepositoryProvider = Provider<FishRepository>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return FishRepository(apiService);
});

class FishRepository {
  final ApiService _apiService;

  FishRepository(this._apiService);

  Future<List<FishSurvey>> getFishSurveys({
    String? species,
    List<String>? counties,
    int? page,
  }) async {
    return _apiService.getFishSurveys(
      species: species,
      counties: counties,
      page: page,
    );
  }

  Future<List<FishSurvey>> getRecentSurveys() async {
    return _apiService.getFishSurveys(
      sortBy: 'survey_date',
      order: 'desc',
      limit: 10,
    );
  }

  Future<List<FishSurvey>> getBiggestFish() async {
    return _apiService.getFishSurveys(
      sortBy: 'max_length',
      order: 'desc',
      limit: 10,
    );
  }

  Future<List<FishSurvey>> getMostCaught() async {
    return _apiService.getFishSurveys(
      sortBy: 'total_catch',
      order: 'desc',
      limit: 10,
    );
  }

  Future<List<Map<String, dynamic>>> getSpecies() async {
    return _apiService.getSpecies();
  }

  Future<List<County>> getCounties() async {
    return _apiService.getCounties();
  }

  Future<GraphData> getFishGraphData({
    required String dow,
    required String species,
    required String date,
  }) async {
    return _apiService.getFishGraphData(
      dow: dow,
      species: species,
      date: date,
    );
  }

  Future<List<FishSurvey>> searchFishSurveys({
    String? species,
    List<String>? counties,
    int? page,
  }) async {
    return _apiService.getFishSurveys(
      species: species,
      counties: counties,
      page: page,
    );
  }
}