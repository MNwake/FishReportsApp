import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/fish_survey.dart';
import 'package:frontend/core/repositories/fish_repository.dart';
import 'package:frontend/core/models/county.dart';

final homeViewModelProvider = StateNotifierProvider<HomeViewModel, AsyncValue<List<FishSurvey>>>((ref) {
  final repository = ref.watch(fishRepositoryProvider);
  return HomeViewModel(repository);
});

final recentSurveysProvider = FutureProvider<List<FishSurvey>>((ref) async {
  final repository = ref.watch(fishRepositoryProvider);
  return repository.getRecentSurveys();
});

final biggestFishProvider = FutureProvider<List<FishSurvey>>((ref) async {
  final repository = ref.watch(fishRepositoryProvider);
  return repository.getBiggestFish();
});

final mostCaughtProvider = FutureProvider<List<FishSurvey>>((ref) async {
  final repository = ref.watch(fishRepositoryProvider);
  return repository.getMostCaught();
});

final countiesProvider = FutureProvider<List<County>>((ref) async {
  final repository = ref.watch(fishRepositoryProvider);
  return repository.getCounties();
});

final allSpeciesProvider = FutureProvider<List<FishSurvey>>((ref) async {
  final repository = ref.watch(fishRepositoryProvider);
  final speciesData = await repository.getSpecies();
  
  return speciesData.map((json) => FishSurvey(
    surveyID: '${json['code']}_species',
    speciesName: json['common_name'] as String? ?? '',
    imageUrl: json['image_url'] as String? ?? '',
    isGameFish: json['game_fish'] == true,
    dowNumber: '',
    lakeName: '',
    countyName: '',
    surveyDate: '',
    description: '',
    totalCatch: 0,
    maxLength: 0,
    minLength: 0,
  )).toList();
});

class HomeViewModel extends StateNotifier<AsyncValue<List<FishSurvey>>> {
  final FishRepository _repository;
  int _currentPage = 1;
  String? _searchQuery;
  List<String>? _selectedCounties;
  
  HomeViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      final surveys = await _repository.searchFishSurveys();
      state = AsyncValue.data(surveys);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> searchFish(String query) async {
    try {
      final surveys = await _repository.searchFishSurveys(species: query);
      state = AsyncValue.data(surveys);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> filterByCounties(List<String> counties) async {
    _selectedCounties = counties.isEmpty ? null : counties;
    _currentPage = 1;
    await loadInitialData();
  }

  Future<void> loadNextPage() async {
    if (state.hasError || state.isLoading) return;
    
    _currentPage++;
    try {
      final newSurveys = await _repository.searchFishSurveys(
        page: _currentPage,
        species: _searchQuery,
        counties: _selectedCounties,
      );
      
      final currentData = state.value ?? [];
      state = AsyncValue.data([...currentData, ...newSurveys]);
    } catch (error, stackTrace) {
      _currentPage--;
      state = AsyncValue.error(error, stackTrace);
    }
  }
} 