import '../widgets/advanced_search_sheet.dart';
import '../models/search_state.dart';

import 'package:flutter/material.dart';
import '../widgets/search_bar.dart';
import '../widgets/horizontal_scroll_section.dart';
import '../widgets/survey_card.dart';
import '../widgets/species_card.dart';
import '../widgets/county_card.dart';
import '../services/api_service.dart';
import '../models/survey.dart';
import '../models/species.dart';
import '../models/county.dart';

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
      final recent = await _apiService.getRecentSurveys();
      final biggest = await _apiService.getBiggestFish();
      final most = await _apiService.getMostCaught();

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
    print("DEBUG: Opening advanced search with state: species=${_searchState.species}, counties=${_searchState.counties.map((c) => c.countyName)}, lakes=${_searchState.lakes}");
    
    final result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (context) => AdvancedSearchSheet(
        initialState: _searchState,
      ),
    );

    if (result != null) {
      print("DEBUG: Received result from advanced search sheet: $result");
      if (result is Map<String, dynamic>) {
        setState(() {
          recentSurveys = result['recentSurveys'] as List<FishData>;
          biggestFish = result['biggestFish'] as List<FishData>;
          mostCaught = result['mostCaught'] as List<FishData>;
          if (result['searchState'] != null) {
            _searchState = result['searchState'] as AdvancedSearchState;
            print("DEBUG: Updated search state from map: species=${_searchState.species}, counties=${_searchState.counties.map((c) => c.countyName)}, lakes=${_searchState.lakes}");
          }
        });
      } else if (result is AdvancedSearchState) {
        setState(() {
          _searchState = result;
          print("DEBUG: Updated search state directly: species=${_searchState.species}, counties=${_searchState.counties.map((c) => c.countyName)}, lakes=${_searchState.lakes}");
        });
      }
    } else {
      print("DEBUG: No result returned from advanced search sheet");
    }
  }

  Widget _buildSection(String title, List<FishData> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 240,
          child: data.isEmpty
              ? const Center(child: Text('No results found'))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: data.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: SurveyCard(
                        survey: data[index],
                        section: title.toLowerCase().replaceAll(' ', '_'),
                      ),
                    );
                  },
                ),
        ),
      ],
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
                HorizontalScrollSection<Species>(
                  title: 'By Species',
                  futureData: _apiService.getSpecies(),
                  itemBuilder: (data) => SpeciesCard(species: data),
                ),
                HorizontalScrollSection<County>(
                  title: 'By County',
                  futureData: _apiService.getCounties(),
                  itemBuilder: (data) => CountyCard(county: data),
                ),
              ],
            ),
    );
  }
} 