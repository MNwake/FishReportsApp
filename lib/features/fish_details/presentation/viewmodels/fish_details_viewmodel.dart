import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/fish_detail_data.dart';
import 'package:frontend/core/models/fish_graph_data.dart';
import 'package:frontend/features/fish_details/data/repositories/fish_details_repository.dart';

final fishDetailsViewModelProvider = FutureProvider.family<FishDetailData, String>((ref, fishId) {
  final repository = ref.watch(fishDetailsRepositoryProvider);
  return repository.getFishDetails(fishId);
});

class FishDetailsViewModel extends StateNotifier<AsyncValue<FishDetailData>> {
  final FishRepository _repository;
  final String fishId;

  FishDetailsViewModel(this._repository, this.fishId) : super(const AsyncValue.loading()) {
    loadData();
  }

  Future<void> loadData() async {
    try {
      // Parse the fishId to get the required parameters
      final parts = fishId.split('_');
      final dow = parts[0];
      final species = parts[1];
      final date = parts[2];

      // Get both survey and graph data
      final graphData = await _repository.getFishGraphData(
        dow: dow,
        species: species,
        date: date,
      );

      // Get the survey data
      final surveys = await _repository.getFishSurveys(
        species: species,
      );

      // Find the matching survey
      final survey = surveys.data.firstWhere(
        (s) => s.dowNumber == dow && s.surveyDate == date,
      );

      state = AsyncValue.data(FishDetailData(
        survey: survey,
        graphData: graphData,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 