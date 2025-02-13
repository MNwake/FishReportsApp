// advanced_search_sheet.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/species.dart';
import '../models/county.dart';
import '../models/search_state.dart';
import './search/species_autocomplete.dart';
import './search/county_autocomplete.dart';
import './search/lake_autocomplete.dart';
import './search/year_dropdown.dart';

class AdvancedSearchSheet extends StatefulWidget {
  final AdvancedSearchState initialState;
  const AdvancedSearchSheet({super.key, required this.initialState});


  @override
  State<AdvancedSearchSheet> createState() => _AdvancedSearchSheetState();
}

class _AdvancedSearchSheetState extends State<AdvancedSearchSheet> {
  final _formKey = GlobalKey<FormState>();

  // Selected values
  String? selectedSpecies;
  County? selectedCounty;
  String? selectedLake;

  // Available options
  List<String> availableLakes = []; // This will be filtered based on county
  List<County> allCounties = [];
  List<int> yearOptions = []; // Fixed: now properly populated

  // Other state
  int? minYear;
  int? maxYear;
  bool gameFishOnly = false;

  // Services and controllers
  final ApiService _apiService = ApiService();
  final TextEditingController _speciesController = TextEditingController();
  final TextEditingController _countyController = TextEditingController();
  final TextEditingController _lakeController = TextEditingController();

  // Focus nodes
  final FocusNode _speciesFocus = FocusNode();
  final FocusNode _countyFocus = FocusNode();
  final FocusNode _lakeFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    print("DEBUG: AdvancedSearchSheet initState with initialState: species=${widget.initialState.species}, county=${widget.initialState.county?.countyName}, lake=${widget.initialState.lake}");
    
    selectedSpecies = widget.initialState.species;
    selectedCounty = widget.initialState.county;
    selectedLake = widget.initialState.lake;
    gameFishOnly = widget.initialState.gameFishOnly;
    
    // Initialize text controllers accordingly
    _speciesController.text = widget.initialState.species ?? '';
    _countyController.text = widget.initialState.county?.countyName ?? '';
    _lakeController.text = widget.initialState.lake ?? '';
    
    print("DEBUG: Controllers initialized: species=${_speciesController.text}, county=${_countyController.text}, lake=${_lakeController.text}");

    _loadData();
    _initializeYearOptions();
  }

  void _loadData() async {
    final counties = await _apiService.getCounties();
    setState(() {
      allCounties = counties;
      // Initialize available lakes with all lakes from all counties
      availableLakes = counties
          .expand((county) => county.lakes)
          .toSet()
          .toList()
        ..sort();
    });
  }

  // Update available lakes when county changes
  void _updateAvailableLakes() {
    setState(() {
      if (selectedCounty != null) {
        availableLakes = List<String>.from(selectedCounty!.lakes);
      } else {
        availableLakes = allCounties
            .expand((county) => county.lakes)
            .toSet()
            .toList()
          ..sort();
      }
      // Clear lake selection if it's not in the available lakes
      if (selectedLake != null && !availableLakes.contains(selectedLake)) {
        selectedLake = null;
        _lakeController.clear();
      }
    });
  }

  void _handleSpeciesSelected(Species species) {
    setState(() {
      selectedSpecies = species.commonName;
      _speciesController.text = species.commonName;
      print("DEBUG: Species selected: ${selectedSpecies}");
    });
  }

  void _handleCountySelected(County county) {
    setState(() {
      selectedCounty = county;
      _countyController.text = county.countyName;
      _updateAvailableLakes();
      print("DEBUG: County selected: ${selectedCounty?.countyName}");
    });
    // Future.delayed(const Duration(milliseconds: 100), () {
    //   _lakeFocus.requestFocus();
    //   print("DEBUG: Lake focus requested delayed");
    // });
  }

  void _handleLakeSelected(String lake) {
    setState(() {
      selectedLake = lake;
      _lakeController.text = lake;
    });
    print("DEBUG: Lake selected: $lake");
  }

  void _handleCountyCleared() {
    setState(() {
      selectedCounty = null;
      _countyController.clear();
      selectedLake = null;
      _lakeController.clear();
      _updateAvailableLakes();
    });
  }

  void _initializeYearOptions() {
    final currentYear = DateTime.now().year;
    setState(() {
      yearOptions = List.generate(currentYear - 1950 + 1, (index) => currentYear - index);
    });
  }

  @override
  void dispose() {
    _speciesController.dispose();
    _countyController.dispose();
    _lakeController.dispose();
    _speciesFocus.dispose();
    _countyFocus.dispose();
    _lakeFocus.dispose();
    super.dispose();
  }

  // We no longer force the text in the field builder
  void _handleFocusLost(TextEditingController controller, String? selectedValue, void Function() onClear) {
    // if (controller.text.isNotEmpty && selectedValue == null) {
    //   onClear();
    // }
    print("DEBUG: Focus lost");
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              controller: scrollController,
              children: [
                _buildHeader(),
                const SizedBox(height: 16),
                _buildSpeciesSection(),
                const SizedBox(height: 16),
                _buildCountySection(),
                const SizedBox(height: 16),
                _buildLakeSection(),
                const SizedBox(height: 16),
                _buildYearSection(),
                const SizedBox(height: 16),
                _buildGameFishSwitch(),
                const SizedBox(height: 24),
                _buildSearchButton(),
                if (MediaQuery.of(context).viewInsets.bottom > 0)
                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Advanced Search', style: Theme.of(context).textTheme.titleLarge),
        IconButton(
          icon: const Icon(Icons.close), 
          onPressed: () {
            final state = AdvancedSearchState(
              species: selectedSpecies,
              county: selectedCounty,
              lake: selectedLake,
              minYear: minYear,
              maxYear: maxYear,
              gameFishOnly: gameFishOnly,
            );
            print("DEBUG: Closing sheet with state: species=${state.species}, county=${state.county?.countyName}, lake=${state.lake}");
            Navigator.pop(context, state);
          }
        ),
      ],
    );
  }

  Widget _buildSpeciesSection() {
    return FutureBuilder<List<Species>>(
      future: _apiService.getSpecies(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const CircularProgressIndicator();
        return SpeciesAutocomplete(
          controller: _speciesController,
          focusNode: _speciesFocus,
          selectedSpecies: selectedSpecies,
          allSpecies: snapshot.data!,
          onSelected: _handleSpeciesSelected,
          onClear: () => setState(() {
            selectedSpecies = null;
            _speciesController.clear();
          }),
          onFocusLost: _handleFocusLost,
        );
      },
    );
  }

  Widget _buildCountySection() {
    return CountyAutocomplete(
      key: ValueKey(selectedCounty?.countyName ?? "all"),
      controller: _countyController,
      focusNode: _countyFocus,
      selectedCounty: selectedCounty?.countyName,
      allCounties: allCounties,
      onSelected: _handleCountySelected,
      onClear: _handleCountyCleared,
      onFocusLost: _handleFocusLost,
    );
  }

  Widget _buildLakeSection() {
    return LakeAutocomplete(
      key: ValueKey(selectedCounty?.countyName ?? "all"),
      controller: _lakeController,
      focusNode: _lakeFocus,
      selectedLake: selectedLake,
      availableLakes: availableLakes,
      onSelected: _handleLakeSelected,
      onClear: () => setState(() {
        selectedLake = null;
        _lakeController.clear();
      }),
    );
  }

  Widget _buildYearSection() {
    return Row(
      children: [
        Expanded(
          child: YearDropdown(
            label: 'Min Year',
            selectedYear: minYear,
            yearOptions: yearOptions,
            onChanged: (value) => setState(() => minYear = value),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: YearDropdown(
            label: 'Max Year',
            selectedYear: maxYear,
            yearOptions: yearOptions,
            onChanged: (value) => setState(() => maxYear = value),
          ),
        ),
      ],
    );
  }

  Widget _buildGameFishSwitch() {
    return SwitchListTile(
      title: const Text('Game Fish Only'),
      value: gameFishOnly,
      onChanged: (value) => setState(() => gameFishOnly = value),
    );
  }

  Widget _buildSearchButton() {
    return ElevatedButton(
      onPressed: () async {
        if (_formKey.currentState!.validate()) {
          try {
            final searchParams = _buildSearchParams();
            final searchState = AdvancedSearchState(
              species: selectedSpecies,
              county: selectedCounty,
              lake: selectedLake,
              minYear: minYear,
              maxYear: maxYear,
              gameFishOnly: gameFishOnly,
            );
            print("DEBUG: Search button pressed with state: species=${searchState.species}, county=${searchState.county?.countyName}, lake=${searchState.lake}");
            
            // Get the filtered data using the API service
            final recentSurveys = await _apiService.getRecentSurveys(
              search: searchParams['search'],
              species: searchParams['species'],
              counties: searchParams['county'] != null 
                  ? (searchParams['county'] as List<String>)  // Cast to correct type
                  : null,
              minYear: searchParams['minYear'],
              maxYear: searchParams['maxYear'],
              gameFishOnly: searchParams['game_fish'] == 'true',
            );

            final biggestFish = await _apiService.getBiggestFish(
              search: searchParams['search'],
              species: searchParams['species'],
              counties: searchParams['county'] != null 
                  ? (searchParams['county'] as List<String>)  // Cast to correct type
                  : null,
              minYear: searchParams['minYear'],
              maxYear: searchParams['maxYear'],
              gameFishOnly: searchParams['game_fish'] == 'true',
            );

            final mostCaught = await _apiService.getMostCaught(
              search: searchParams['search'],
              species: searchParams['species'],
              counties: searchParams['county'] != null 
                  ? (searchParams['county'] as List<String>)  // Cast to correct type
                  : null,
              minYear: searchParams['minYear'],
              maxYear: searchParams['maxYear'],
              gameFishOnly: searchParams['game_fish'] == 'true',
            );

            // Return the results to HomeScreen
            if (mounted) {
              Navigator.pop(context, {
                'recentSurveys': recentSurveys,
                'biggestFish': biggestFish,
                'mostCaught': mostCaught,
                'searchParams': searchParams,
                'searchState': searchState,
              });
            }
          } catch (e) {
            // Show error dialog
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Error'),
                  content: Text('Failed to fetch search results: $e'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            }
          }
        }
      },
      child: const Text('Search'),
    );
  }

  // Add this method to build the search parameters
  Map<String, dynamic> _buildSearchParams() {
    String? cleanCountyName;
    if (selectedCounty != null) {
      // Remove the word "County" and trim any whitespace
      cleanCountyName = selectedCounty!.countyName.replaceAll(' County', '');
    }

    return {
      if (selectedSpecies != null) 'species': selectedSpecies,
      if (cleanCountyName != null) 'county': <String>[cleanCountyName],
      if (selectedLake != null) 'search': selectedLake,
      if (minYear != null) 'minYear': minYear.toString(),
      if (maxYear != null) 'maxYear': maxYear.toString(),
      if (gameFishOnly) 'game_fish': 'true',
    };
  }
}