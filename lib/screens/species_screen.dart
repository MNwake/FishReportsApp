import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max;
import '../models/species.dart';
import '../models/species_stats.dart';
import '../models/county.dart';
import '../models/length_data.dart';
import '../widgets/game_fish_badge.dart';
import '../widgets/county_card.dart';
import '../widgets/horizontal_scroll_section.dart';
import '../services/api_service.dart';
import '../screens/county_screen.dart';
import '../widgets/length_distribution_chart.dart';

class SpeciesScreen extends ConsumerWidget {
  final Species species;

  const SpeciesScreen({super.key, required this.species});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(speciesStatsProvider(species));
    final apiService = ref.read(apiServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(species.commonName),
      ),
      body: statsAsync.when(
        data: (stats) => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero image section
              if (species.imageUrl.isNotEmpty)
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Image.network(
                    species.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.image_not_supported, size: 48),
                      );
                    },
                  ),
                ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Species name and basic info
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            species.commonName,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                        GameFishBadge(isGameFish: species.gameFish),
                      ],
                    ),
                    if (species.scientificName != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        species.scientificName!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    if (species.description != null) ...[
                      const SizedBox(height: 16),
                      Text(species.description!),
                    ],
                    const SizedBox(height: 24),

                    // Stats card
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStat(
                              context,
                              'Lakes Present',
                              '${stats.percentLakes.toStringAsFixed(1)}%',
                              'of all lakes',
                            ),
                            _buildStat(
                              context,
                              'Average Length',
                              '${stats.averageLength.toStringAsFixed(1)}″',
                              'Range: ${stats.shortestLength}″-${stats.biggestLength}″',
                            ),
                            _buildStat(
                              context,
                              'Total Caught',
                              NumberFormat.compact().format(stats.totalFish),
                              'All surveys',
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Length Distribution Graph
                    Text(
                      'Length Distribution',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    _buildLengthDistributionChart(context, stats.graphData),
                    const SizedBox(height: 24),

                    // Counties List Section
                    Text(
                      'Found in These Counties',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${stats.counties.where((c) => c.percentage > 0).length} counties with this species',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sort and build the counties list
                    FutureBuilder<List<County>>(
                      future: ref.read(apiServiceProvider).getCounties(),
                      builder: (context, countiesSnapshot) {
                        if (!countiesSnapshot.hasData) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        final counties = stats.counties
                            .where((c) => c.percentage > 0)
                            .map((countyStats) {
                              final county = countiesSnapshot.data!.firstWhere(
                                (c) => c.id == countyStats.id,
                                orElse: () => County(
                                  id: '',
                                  countyName: 'Unknown County',
                                  fipsCode: '',
                                  countySeat: '',
                                  established: 0,
                                  origin: '',
                                  etymology: '',
                                  population: 0,
                                  areaSqMiles: 0,
                                  mapImageUrl: '',
                                  lakes: [],
                                ),
                              );
                              return MapEntry(county, countyStats.percentage);
                            })
                            .toList()
                          ..sort((a, b) => a.key.countyName.compareTo(b.key.countyName));  // Sort alphabetically by county name

                        return ListView(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          children: counties.map((entry) {
                            final county = entry.key;
                            final percentage = entry.value;
                            
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => CountyScreen(county: county),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            county.countyName,
                                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Icon(
                                            Icons.chevron_right,
                                            color: Theme.of(context).colorScheme.primary,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}% of lakes in county have ${species.commonName}',
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: Theme.of(context).textTheme.bodySmall?.color,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
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

  Widget _buildLengthDistributionChart(BuildContext context, List<LengthData> graphData) {
    return SizedBox(
      height: 300,
      child: LengthDistributionChart(graphData: graphData),
    );
  }
}

// Provider for species stats
final speciesStatsProvider = FutureProvider.family<SpeciesStats, Species>(
  (ref, species) async {
    final apiService = ref.read(apiServiceProvider);
    final response = await apiService.getSpeciesStats(species.id);
    return SpeciesStats.fromJson(response);
  },
);