// search_state.dart
import 'county.dart';

class AdvancedSearchState {
  final List<String> species;
  final List<County> counties;
  final List<String> lakes;
  final int? minYear;
  final int? maxYear;
  final bool gameFishOnly;

  const AdvancedSearchState({
    this.species = const [],
    this.counties = const [],
    this.lakes = const [],
    this.minYear,
    this.maxYear,
    this.gameFishOnly = false,
  });

  AdvancedSearchState copyWith({
    List<String>? species,
    List<County>? counties,
    List<String>? lakes,
    int? minYear,
    int? maxYear,
    bool? gameFishOnly,
  }) {
    return AdvancedSearchState(
      species: species ?? this.species,
      counties: counties ?? this.counties,
      lakes: lakes ?? this.lakes,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      gameFishOnly: gameFishOnly ?? this.gameFishOnly,
    );
  }
}