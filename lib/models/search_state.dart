// search_state.dart
import 'county.dart';

class AdvancedSearchState {
  final List<String> species;
  final List<County> counties;
  final List<String> lakes;
  final String? minYear;
  final String? maxYear;
  final bool gameFishOnly;
  final int? limit;
  final int? page;

  const AdvancedSearchState({
    this.species = const [],
    this.counties = const [],
    this.lakes = const [],
    this.minYear,
    this.maxYear,
    this.gameFishOnly = false,
    this.limit,
    this.page,
  });

  AdvancedSearchState copyWith({
    List<String>? species,
    List<County>? counties,
    List<String>? lakes,
    String? minYear,
    String? maxYear,
    bool? gameFishOnly,
    int? limit,
    int? page,
  }) {
    return AdvancedSearchState(
      species: species ?? this.species,
      counties: counties ?? this.counties,
      lakes: lakes ?? this.lakes,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      gameFishOnly: gameFishOnly ?? this.gameFishOnly,
      limit: limit ?? this.limit,
      page: page ?? this.page,
    );
  }
}