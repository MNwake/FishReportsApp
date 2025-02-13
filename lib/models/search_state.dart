// search_state.dart
import 'county.dart';

class AdvancedSearchState {
  final String? species;
  final County? county;
  final String? lake;
  final int? minYear;
  final int? maxYear;
  final bool gameFishOnly;

  const AdvancedSearchState({
    this.species,
    this.county,
    this.lake,
    this.minYear,
    this.maxYear,
    this.gameFishOnly = false,
  });

  AdvancedSearchState copyWith({
    String? species,
    County? county,
    String? lake,
    int? minYear,
    int? maxYear,
    bool? gameFishOnly,
  }) {
    return AdvancedSearchState(
      species: species ?? this.species,
      county: county ?? this.county,
      lake: lake ?? this.lake,
      minYear: minYear ?? this.minYear,
      maxYear: maxYear ?? this.maxYear,
      gameFishOnly: gameFishOnly ?? this.gameFishOnly,
    );
  }
}