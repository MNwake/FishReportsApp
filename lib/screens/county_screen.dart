import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../models/county.dart';
import '../models/county_stats.dart';
import '../widgets/survey_card.dart';
import '../services/api_service.dart';
import '../models/fish_data.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/species.dart';
import '../widgets/species_distribution_chart.dart';
import '../widgets/horizontal_scroll_section.dart';

class CountyScreen extends ConsumerStatefulWidget {
  final County county;

  const CountyScreen({super.key, required this.county});

  @override
  ConsumerState<CountyScreen> createState() => _CountyScreenState();
}

class _CountyScreenState extends ConsumerState<CountyScreen> {
  @override
  Widget build(BuildContext context) {
    final statsAsync = ref.watch(countyStatsProvider(widget.county.id));
    final surveysAsync = ref.watch(countySurveysProvider(widget.county.id));

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('MN County'),
          ],
        ),
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // County header with thumbnail and info
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // County thumbnail
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: SizedBox(
                        width: 100,
                        height: 100,
                        child: Image.network(
                          widget.county.mapImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Icon(Icons.map_outlined, size: 48),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // County info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.county.countyName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Area: ${widget.county.areaSqMiles.toStringAsFixed(1)} sq miles',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Stats card
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStat(
                          context,
                          'Lakes',
                          stats.numberOfLakes.toString(),
                          'Total Lakes',
                        ),
                        _buildStat(
                          context,
                          'Species',
                          stats.numberOfSpecies.toString(),
                          'Different Species',
                        ),
                        _buildStat(
                          context,
                          'Fish Caught',
                          NumberFormat.compact().format(stats.totalFishCaught),
                          'Total Fish',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Species Distribution Section
              Text(
                'Species Distribution',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              Consumer(
                builder: (context, ref, child) {
                  final speciesAsync = ref.watch(allSpeciesProvider);
                  
                  return speciesAsync.when(
                    data: (species) => SpeciesDistributionChart(
                      distribution: stats.speciesDistribution,
                      allSpecies: species,
                    ),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(child: Text('Error: $error')),
                  );
                },
              ),
              const SizedBox(height: 24),

              // Recent Surveys Section
              _buildRecentSurveys(stats.surveyIds),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value, String subtitle) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
          textAlign: TextAlign.center,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentSurveys(List<String> surveyIds) {
    return HorizontalScrollSection<FishData>(
      title: 'Recent Surveys',
      futureData: _fetchSurveyData(surveyIds),
      onLoadMore: (page) async {
        final apiService = ref.read(apiServiceProvider);
        return apiService.getSurveyData(
          counties: [widget.county.id],
          page: page,
          sortBy: 'survey_date',
          order: 'desc',
        );
      },
      itemBuilder: (survey) => SurveyCard(
        survey: survey,
        section: 'county_details',
      ),
    );
  }

  Future<List<FishData>> _fetchSurveyData(List<String> surveyIds) async {
    final apiService = ref.read(apiServiceProvider);
    return apiService.getSurveyData(
      counties: [widget.county.id],
      limit: 50,
      sortBy: 'survey_date',
      order: 'desc',
    );
  }
}

// Provider for county stats
final countyStatsProvider = FutureProvider.family<CountyStats, String>(
  (ref, countyId) async {
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.getCountyStats(countyId);
    return CountyStats.fromJson(response);
  },
);

// Provider for county surveys
final countySurveysProvider = FutureProvider.family<List<FishData>, String>(
  (ref, countyId) async {
    final apiService = ref.read(apiServiceProvider);
    return apiService.getSurveyData(counties: [countyId]);
  },
);

// Add a provider to fetch species details
final speciesProvider = FutureProvider.family<Species, String>(
  (ref, speciesId) async {
    final apiService = ref.read(apiServiceProvider);
    final species = await apiService.getSpeciesById(speciesId);
    return Species.fromJson(species);
  },
);

// Add this provider at the bottom of the file
final allSpeciesProvider = FutureProvider<List<Species>>((ref) async {
  final apiService = ref.read(apiServiceProvider);
  return apiService.getSpecies();
}); 