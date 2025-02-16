import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/search_bar.dart';
import '../widgets/horizontal_scroll_section.dart';
import '../widgets/survey_card.dart';
import '../widgets/species_card.dart';
import '../widgets/county_card.dart';
import '../widgets/advanced_search_sheet.dart';
import '../services/api_service.dart';
import '../models/fish_data.dart';
import '../models/species.dart';
import '../models/county.dart';
import '../models/search_state.dart';
import '../screens/species_screen.dart';
import '../screens/county_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<FishData> recentSurveys = [];
  List<FishData> biggestFish = [];
  List<FishData> mostCaught = [];
  bool isLoading = true;
  bool showGameFishOnly = false;
  final ApiService _apiService = ApiService();
  AdvancedSearchState _searchState = const AdvancedSearchState();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final recent = await _apiService.getSurveyData(
        sortBy: 'survey_date',
        order: 'desc',
        // limit: 10,
      );
      
      final biggest = await _apiService.getSurveyData(
        sortBy: 'max_length',
        order: 'desc',
        // limit: 10,
      );
      
      final most = await _apiService.getSurveyData(
        sortBy: 'total_catch',
        order: 'desc',
        // limit: 10,
      );

      setState(() {
        recentSurveys = recent;
        biggestFish = biggest;
        mostCaught = most;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Handle error...
    }
  }

  void _showAdvancedSearch() async {
    final result = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AdvancedSearchSheet(
        initialState: _searchState,
        onSearchComplete: null,
        onSearchError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Search error: $error')),
          );
        },
      ),
    );

    // Handle the result from the bottom sheet
    if (result != null && mounted) {
      try {
        setState(() => isLoading = true);
        
        final searchParams = result['searchParams'] as Map<String, dynamic>;
        final apiService = ApiService();
        
        // Fetch all data in parallel
        final results = await Future.wait([
          apiService.getSurveyData(
            species: searchParams['species'] as List<String>?,
            counties: searchParams['counties'] as List<String>?,
            lakes: searchParams['lake'] as List<String>?,
            sortBy: 'survey_date',
            order: 'desc',
            minYear: searchParams['minYear'] as String?,
            maxYear: searchParams['maxYear'] as String?,
            gameFishOnly: searchParams['game_fish'] == 'true',
          ),
          apiService.getSurveyData(
            species: searchParams['species'] as List<String>?,
            counties: searchParams['counties'] as List<String>?,
            lakes: searchParams['lake'] as List<String>?,
            sortBy: 'max_length',
            order: 'desc',
            minYear: searchParams['minYear'] as String?,
            maxYear: searchParams['maxYear'] as String?,
            gameFishOnly: searchParams['game_fish'] == 'true',
          ),
          apiService.getSurveyData(
            species: searchParams['species'] as List<String>?,
            counties: searchParams['counties'] as List<String>?,
            lakes: searchParams['lake'] as List<String>?,
            sortBy: 'total_catch',
            order: 'desc',
            minYear: searchParams['minYear'] as String?,
            maxYear: searchParams['maxYear'] as String?,
            gameFishOnly: searchParams['game_fish'] == 'true',
          ),
        ]);

        if (mounted) {
          setState(() {
            recentSurveys = results[0];
            biggestFish = results[1];
            mostCaught = results[2];
            _searchState = result['searchState'] as AdvancedSearchState;
            isLoading = false;
          });
        }
      } catch (e) {
        print('DEBUG: Error updating search results: $e');
        if (mounted) {
          setState(() => isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating results: $e')),
          );
        }
      }
    }
  }

  Widget _buildSection(String title, List<FishData> data) {
    return HorizontalScrollSection<FishData>(
      title: title,
      futureData: Future.value(data),
      onLoadMore: (page) async {
        final sortBy = title.toLowerCase().contains('recent') ? 'survey_date' :
                      title.toLowerCase().contains('biggest') ? 'max_length' : 'total_catch';
        
        return _apiService.getSurveyData(
          sortBy: sortBy,
          order: 'desc',
          page: page,
          limit: 50,
          species: _searchState.species.isNotEmpty ? _searchState.species : null,
          counties: _searchState.counties.isNotEmpty ? _searchState.counties.map((c) => c.id).toList() : null,
          lakes: _searchState.lakes.isNotEmpty ? _searchState.lakes : null,
          minYear: _searchState.minYear,
          maxYear: _searchState.maxYear,
          gameFishOnly: _searchState.gameFishOnly,
        );
      },
      itemBuilder: (survey) => SurveyCard(
        survey: survey,
        section: title.toLowerCase().replaceAll(' ', '_'),
      ),
    );
  }

  Widget _buildSpeciesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'By Species',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              Row(
                children: [
                  Text(
                    'Game Fish Only',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  Switch(
                    value: showGameFishOnly,
                    onChanged: (value) {
                      setState(() {
                        showGameFishOnly = value;
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: FutureBuilder<List<Species>>(
            future: _apiService.getSpecies(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              var species = snapshot.data!;
              
              // Filter by game fish if enabled
              if (showGameFishOnly) {
                species = species.where((s) => s.gameFish).toList();
              }

              // Filter by selected species from advanced search
              if (_searchState.species.isNotEmpty) {
                species = species.where((s) => _searchState.species.contains(s.id)).toList();
              }

              if (species.isEmpty) {
                return const Center(child: Text('No species match the current filters'));
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: species.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: SpeciesCard(
                      species: species[index],
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SpeciesScreen(species: species[index]),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCountySection() {
    return HorizontalScrollSection<County>(
      title: 'By County',
      futureData: _apiService.getCounties().then((counties) {
        // Filter counties based on advanced search selection
        if (_searchState.counties.isNotEmpty) {
          return counties.where((c) => 
            _searchState.counties.any((sc) => sc.id == c.id)
          ).toList();
        }
        return counties;
      }),
      itemBuilder: (data) => CountyCard(
        county: data,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CountyScreen(county: data),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MN Fish Survey Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _showAdvancedSearch,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildSection('Recent Surveys', recentSurveys),
                _buildSection('Biggest Fish', biggestFish),
                _buildSection('Most Caught', mostCaught),
                _buildSpeciesSection(),
                _buildCountySection(),
              ],
            ),
    );
  }
} 