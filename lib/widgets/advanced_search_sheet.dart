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
  List<String> selectedSpecies = [];
  List<County> selectedCounties = [];
  List<String> selectedLakes = [];

  // Available options
  List<String> availableLakes = [];
  List<County> allCounties = [];
  List<int> yearOptions = [];

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
    print("DEBUG: AdvancedSearchSheet initState with initialState: species=${widget.initialState.species}, counties=${widget.initialState.counties.map((c) => c.countyName)}, lakes=${widget.initialState.lakes}");
    
    selectedSpecies = List.from(widget.initialState.species);
    selectedCounties = List.from(widget.initialState.counties);
    selectedLakes = List.from(widget.initialState.lakes);
    minYear = widget.initialState.minYear;
    maxYear = widget.initialState.maxYear;
    gameFishOnly = widget.initialState.gameFishOnly;
    
    // Initialize text controllers
    _speciesController.text = selectedSpecies.join(', ');
    _countyController.text = selectedCounties.map((c) => c.countyName).join(', ');
    _lakeController.text = selectedLakes.join(', ');
    
    print("DEBUG: Controllers initialized: species=${_speciesController.text}, counties=${_countyController.text}, lakes=${_lakeController.text}");

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
      if (selectedCounties.isNotEmpty) {
        availableLakes = selectedCounties
            .expand((county) => county.lakes)
            .toSet()
            .toList()
          ..sort();
      } else {
        availableLakes = allCounties
            .expand((county) => county.lakes)
            .toSet()
            .toList()
          ..sort();
      }
      // Clear lake selections if they're not in available lakes
      selectedLakes.removeWhere((lake) => !availableLakes.contains(lake));
      _lakeController.text = selectedLakes.join(', ');
    });
  }

  void _handleSpeciesChanged(List<String> species) {
    setState(() {
      selectedSpecies = species;
      _speciesController.text = species.join(', ');
    });
    print("DEBUG: Species changed: $selectedSpecies");
  }

  void _handleCountiesChanged(List<County> counties) {
    setState(() {
      selectedCounties = counties;
      _countyController.text = counties.map((c) => c.countyName).join(', ');
      _updateAvailableLakes();
    });
    print("DEBUG: Counties changed: ${selectedCounties.map((c) => c.countyName)}");
  }

  void _handleLakesChanged(List<String> lakes) {
    setState(() {
      selectedLakes = lakes;
      _lakeController.text = lakes.join(', ');
    });
    print("DEBUG: Lakes changed: $selectedLakes");
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
              counties: selectedCounties,
              lakes: selectedLakes,
              minYear: minYear,
              maxYear: maxYear,
              gameFishOnly: gameFishOnly,
            );
            print("DEBUG: Closing sheet with state: species=$selectedSpecies, counties=${selectedCounties.map((c) => c.countyName)}, lakes=$selectedLakes");
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
          onSelectionChanged: _handleSpeciesChanged,
          onClear: () => setState(() {
            selectedSpecies.clear();
            _speciesController.clear();
          }),
        );
      },
    );
  }

  Widget _buildCountySection() {
    return CountyAutocomplete(
      controller: _countyController,
      focusNode: _countyFocus,
      selectedCounties: selectedCounties,
      allCounties: allCounties,
      onSelectionChanged: _handleCountiesChanged,
      onClear: () => setState(() {
        selectedCounties.clear();
        _countyController.clear();
        _updateAvailableLakes();
      }),
    );
  }

  Widget _buildLakeSection() {
    return LakeAutocomplete(
      controller: _lakeController,
      focusNode: _lakeFocus,
      selectedLakes: selectedLakes,
      availableLakes: availableLakes,
      onSelectionChanged: _handleLakesChanged,
      onClear: () => setState(() {
        selectedLakes.clear();
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
              counties: selectedCounties,
              lakes: selectedLakes,
              minYear: minYear,
              maxYear: maxYear,
              gameFishOnly: gameFishOnly,
            );
            print("DEBUG: Search button pressed with params: $searchParams");
            
            // Get the filtered data using the API service
            final recentSurveys = await _apiService.getRecentSurveys(
              species: searchParams['species'],
              county: searchParams['county'],
              lake: searchParams['lake'],
              minYear: searchParams['minYear'],
              maxYear: searchParams['maxYear'],
              gameFishOnly: searchParams['game_fish'] == 'true',
            );

            final biggestFish = await _apiService.getBiggestFish(
              species: searchParams['species'],
              county: searchParams['county'],
              lake: searchParams['lake'],
              minYear: searchParams['minYear'],
              maxYear: searchParams['maxYear'],
              gameFishOnly: searchParams['game_fish'] == 'true',
            );

            final mostCaught = await _apiService.getMostCaught(
              species: searchParams['species'],
              county: searchParams['county'],
              lake: searchParams['lake'],
              minYear: searchParams['minYear'],
              maxYear: searchParams['maxYear'],
              gameFishOnly: searchParams['game_fish'] == 'true',
            );

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
            print("DEBUG: Error during search: $e");
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

  // Update the search parameters builder to match the API expectations
  Map<String, dynamic> _buildSearchParams() {
    return {
      if (selectedSpecies.isNotEmpty) 'species': selectedSpecies,
      if (selectedCounties.isNotEmpty) 
        'county': selectedCounties
            .map((county) => county.countyName.replaceAll(' County', ''))
            .toList(),
      if (selectedLakes.isNotEmpty) 'lake': selectedLakes,
      if (minYear != null) 'minYear': minYear.toString(),
      if (maxYear != null) 'maxYear': maxYear.toString(),
      if (gameFishOnly) 'game_fish': 'true',
    };
  }

  void _initializeYearOptions() {
    final currentYear = DateTime.now().year;
    yearOptions = List.generate(30, (index) => currentYear - index);
  }
}