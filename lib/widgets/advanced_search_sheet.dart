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
import '../models/survey.dart';
import '../models/fish_data.dart';

class AdvancedSearchSheet extends StatefulWidget {
  final AdvancedSearchState initialState;
  final Function(Map<String, dynamic>)? onSearchComplete;
  final Function(String)? onSearchError;

  const AdvancedSearchSheet({
    super.key, 
    required this.initialState,
    this.onSearchComplete,
    this.onSearchError,
  });

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
  String? minYear;
  String? maxYear;
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

  // Add this field
  List<Species> allSpecies = [];

  // Add this state variable
  List<FishData> availableSurveys = [];

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
    _loadSpecies();
    _initializeYearOptions();
    _loadSurveys();
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

  void _loadSpecies() async {
    final species = await _apiService.getSpecies();
    setState(() {
      allSpecies = species;
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
                _buildFilterSection(
                  title: 'Species',
                  items: selectedSpecies,
                  onAddPressed: () => _showSpeciesSelector(context),
                  onItemDeleted: (species) {
                    final newSelection = List<String>.from(selectedSpecies)
                      ..remove(species);
                    _handleSpeciesChanged(newSelection);
                  },
                ),
                const SizedBox(height: 16),
                _buildFilterSection(
                  title: 'Counties',
                  items: selectedCounties.map((c) => c.countyName).toList(),
                  onAddPressed: () => _showCountySelector(context),
                  onItemDeleted: (county) {
                    final newSelection = selectedCounties
                        .where((c) => c.countyName != county)
                        .toList();
                    _handleCountiesChanged(newSelection);
                  },
                ),
                const SizedBox(height: 16),
                _buildFilterSection(
                  title: 'Lakes',
                  items: selectedLakes,
                  onAddPressed: () => _showLakeSelector(context),
                  onItemDeleted: (lake) {
                    final newSelection = List<String>.from(selectedLakes)
                      ..remove(lake);
                    _handleLakesChanged(newSelection);
                  },
                ),
                const SizedBox(height: 16),
                _buildYearFilterSection(),
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
            print("DEBUG: Closing sheet without saving changes");
            Navigator.pop(context);  // Simply close the sheet without returning any data
          }
        ),
      ],
    );
  }

  Widget _buildFilterSection({
    required String title,
    required List<String> items,
    required VoidCallback onAddPressed,
    required Function(String) onItemDeleted,
  }) {
    // Convert IDs to names for display if this is the species section
    final displayItems = title == 'Species' 
        ? items.map((id) => getSpeciesNameById(id)).toList()
        : items;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onAddPressed,
            ),
          ],
        ),
        if (items.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              children: displayItems
                  .map((item) => Chip(
                        label: Text(item),
                        onDeleted: () => onItemDeleted(
                          title == 'Species' 
                              ? items[displayItems.indexOf(item)]  // Pass ID for species
                              : item
                        ),
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildYearFilterSection() {
    final currentYear = DateTime.now().year;
    final minYearValue = Survey.getOldestYear(availableSurveys);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Years', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${this.minYear ?? minYearValue}'),
              Text('${this.maxYear ?? currentYear}'),
            ],
          ),
        ),
        RangeSlider(
          values: RangeValues(
            double.parse(this.minYear ?? minYearValue.toString()),
            double.parse(this.maxYear ?? currentYear.toString()),
          ),
          min: minYearValue.toDouble(),
          max: currentYear.toDouble(),
          divisions: currentYear - minYearValue,
          labels: RangeLabels(
            '${this.minYear ?? minYearValue}',
            '${this.maxYear ?? currentYear}',
          ),
          onChanged: (RangeValues values) {
            setState(() {
              this.minYear = values.start.round().toString();
              this.maxYear = values.end.round().toString();
            });
          },
        ),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                this.minYear = null;
                this.maxYear = null;
              });
            },
            child: const Text('Clear Range'),
          ),
        ),
      ],
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
              minYear: minYear?.toString(),
              maxYear: maxYear?.toString(),
              gameFishOnly: gameFishOnly,
            );
            print("DEBUG: Search button pressed with params: $searchParams");
            
            // Close the sheet immediately
            if (!mounted) return;
            Navigator.pop(context, {
              'searchParams': searchParams,
              'searchState': searchState,
            });

            // Run all API requests concurrently
            final results = await Future.wait([
              _apiService.getSurveyData(
                species: selectedSpecies,
                counties: selectedCounties.map((c) => c.id).toList(),
                sortBy: 'survey_date',
                order: 'desc',
                minYear: minYear?.toString(),
                maxYear: maxYear?.toString(),
                gameFishOnly: gameFishOnly,
              ),
              _apiService.getSurveyData(
                species: selectedSpecies,
                counties: selectedCounties.map((c) => c.id).toList(),
                sortBy: 'max_length',
                order: 'desc',
                minYear: minYear?.toString(),
                maxYear: maxYear?.toString(),
                gameFishOnly: gameFishOnly,
              ),
              _apiService.getSurveyData(
                species: selectedSpecies,
                counties: selectedCounties.map((c) => c.id).toList(),
                sortBy: 'total_catch',
                order: 'desc',
                minYear: minYear?.toString(),
                maxYear: maxYear?.toString(),
                gameFishOnly: gameFishOnly,
              ),
            ]);

            // Send results back through a callback
            if (widget.onSearchComplete != null) {
              widget.onSearchComplete!({
                'recentSurveys': results[0],
                'biggestFish': results[1],
                'mostCaught': results[2],
                'searchParams': searchParams,
                'searchState': searchState,
              });
            }

          } catch (e) {
            print("DEBUG: Error during search: $e");
            if (widget.onSearchError != null) {
              widget.onSearchError!(e.toString());
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
        'counties': selectedCounties.map((county) => county.id).toList(),
      if (selectedLakes.isNotEmpty) 'lake': selectedLakes,
      if (minYear != null) 'minYear': minYear,
      if (maxYear != null) 'maxYear': maxYear,
      if (gameFishOnly) 'game_fish': 'true',
    };
  }

  void _initializeYearOptions() {
    final currentYear = DateTime.now().year;
    yearOptions = List.generate(30, (index) => currentYear - index);
  }

  void _showSpeciesSelector(BuildContext context) {
    final List<String> tempSelection = List.from(selectedSpecies);
    bool tempGameFishOnly = gameFishOnly;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Species'),
          content: StatefulBuilder(
            builder: (context, setState) {
              List<Species> sortedSpecies = List<Species>.from(allSpecies)
                ..sort((a, b) => a.commonName.compareTo(b.commonName));
              
              if (tempGameFishOnly) {
                sortedSpecies = sortedSpecies.where((s) => s.gameFish).toList();
              }
                
              return SizedBox(
                width: double.maxFinite,
                height: 400,
                child: Column(
                  children: [
                    SwitchListTile(
                      title: const Text('Game Fish Only'),
                      value: tempGameFishOnly,
                      onChanged: (bool value) {
                        setState(() {
                          tempGameFishOnly = value;
                          if (value) {
                            tempSelection.removeWhere(
                              (speciesId) => !allSpecies
                                  .where((s) => s.gameFish)
                                  .map((s) => s.id)
                                  .contains(speciesId)
                            );
                          }
                        });
                      },
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: sortedSpecies.length,
                        itemBuilder: (context, index) {
                          final species = sortedSpecies[index];
                          return CheckboxListTile(
                            title: Text(species.commonName),
                            subtitle: species.gameFish ? const Text('Game Fish') : null,
                            value: tempSelection.contains(species.id),  // Changed to use ID
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  tempSelection.add(species.id);  // Store ID
                                } else {
                                  tempSelection.remove(species.id);  // Remove ID
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  gameFishOnly = tempGameFishOnly;
                  _handleSpeciesChanged(tempSelection);
                });
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showCountySelector(BuildContext context) {
    final List<County> tempSelection = List.from(selectedCounties);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Counties'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                height: 400,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCounties.length,
                  itemBuilder: (context, index) {
                    final county = allCounties[index];
                    return CheckboxListTile(
                      title: Text(county.countyName),
                      subtitle: Text('${county.lakes.length} lakes'),
                      value: tempSelection.contains(county),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelection.add(county);
                          } else {
                            tempSelection.remove(county);
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _handleCountiesChanged(tempSelection);
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }

  void _showLakeSelector(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _LakeSelectorDialog(
        selectedLakes: selectedLakes,
        availableLakes: availableLakes,
        onLakesChanged: _handleLakesChanged,
      ),
    );
  }

  // Add this method to load surveys
  void _loadSurveys() async {
    try {
      final surveys = await _apiService.getRecentSurveys();
      setState(() {
        availableSurveys = surveys;
      });
    } catch (e) {
      print('Error loading surveys: $e');
      // If loading fails, we'll use the fallback in getOldestYear
    }
  }

  // Add a helper method to convert between IDs and names
  String getSpeciesNameById(String id) {
    final species = allSpecies.firstWhere(
      (s) => s.id == id,
      orElse: () => Species(
        id: id,
        commonName: 'Unknown Species',
        scientificName: '',
        imageUrl: '',
        description: '',
        gameFish: false,
      ),
    );
    return species.commonName;
  }

  String? getSpeciesIdByName(String name) {
    final species = allSpecies.firstWhere(
      (s) => s.commonName == name,
      orElse: () => Species(
        id: '',
        commonName: '',
        scientificName: '',
        imageUrl: '',
        description: '',
        gameFish: false,
      ),
    );
    return species.id.isEmpty ? null : species.id;
  }
}

class _LakeSelectorDialog extends StatefulWidget {
  final List<String> selectedLakes;
  final List<String> availableLakes;
  final Function(List<String>) onLakesChanged;

  const _LakeSelectorDialog({
    required this.selectedLakes,
    required this.availableLakes,
    required this.onLakesChanged,
  });

  @override
  State<_LakeSelectorDialog> createState() => _LakeSelectorDialogState();
}

class _LakeSelectorDialogState extends State<_LakeSelectorDialog> {
  late TextEditingController searchController;
  late List<String> tempSelection;
  late List<String> filteredLakes;

  @override
  void initState() {
    super.initState();
    searchController = TextEditingController();
    tempSelection = List.from(widget.selectedLakes);
    filteredLakes = List.from(widget.availableLakes);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Select Lakes'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: const InputDecoration(
                hintText: 'Search lakes...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  if (value.isEmpty) {
                    filteredLakes = List.from(widget.availableLakes);
                  } else {
                    filteredLakes = widget.availableLakes
                        .where((lake) => lake.toLowerCase()
                            .contains(value.toLowerCase()))
                        .toList();
                  }
                });
              },
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Available Lakes: ${filteredLakes.length}'),
            ),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filteredLakes.length,
                itemBuilder: (context, index) {
                  final lake = filteredLakes[index];
                  return CheckboxListTile(
                    title: Text(lake),
                    value: tempSelection.contains(lake),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          tempSelection.add(lake);
                        } else {
                          tempSelection.remove(lake);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            widget.onLakesChanged(tempSelection);
            Navigator.pop(context);
          },
          child: const Text('Apply'),
        ),
      ],
    );
  }
}