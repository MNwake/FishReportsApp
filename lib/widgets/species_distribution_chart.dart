import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/species.dart';

class SpeciesDistributionChart extends StatelessWidget {
  final Map<String, double> distribution;
  final List<Species> allSpecies;
  final double threshold;

  const SpeciesDistributionChart({
    super.key,
    required this.distribution,
    required this.allSpecies,
    this.threshold = 3.0,
  });

  @override
  Widget build(BuildContext context) {
    final sortedSpecies = distribution.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Filter out species with less than threshold% to avoid cluttering the chart
    final significantSpecies = sortedSpecies.where((e) => e.value >= threshold).toList();
    double othersPercentage = sortedSpecies
        .where((e) => e.value < threshold)
        .fold(0.0, (sum, item) => sum + item.value);

    // Add "Others" category if there are species with < threshold%
    if (othersPercentage > 0) {
      significantSpecies.add(MapEntry('Others', othersPercentage));
    }

    return Column(
      children: [
        SizedBox(
          height: 300,
          child: PieChart(
            PieChartData(
              sections: significantSpecies.map((entry) {
                return PieChartSectionData(
                  color: _getSpeciesColor(entry.key),
                  value: entry.value,
                  title: '${entry.value.toStringAsFixed(1)}%',
                  radius: 100,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                );
              }).toList(),
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Legend
        Wrap(
          spacing: 16,
          runSpacing: 8,
          children: significantSpecies.map((entry) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: _getSpeciesColor(entry.key),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  entry.key == 'Others' 
                      ? 'Others' 
                      : _getSpeciesName(entry.key),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  String _getSpeciesName(String speciesId) {
    final species = allSpecies.firstWhere(
      (s) => s.id == speciesId,
      orElse: () => Species(
        id: speciesId,
        commonName: 'Unknown Species',
        scientificName: '',
        imageUrl: '',
        description: '',
        gameFish: false,
      ),
    );
    return species.commonName;
  }

  Color _getSpeciesColor(String speciesId) {
    if (speciesId == 'Others') {
      return Colors.grey;
    }

    // Base colors with multiple shades
    final List<Color> colors = [
      Colors.blue[400]!,
      Colors.blue[700]!,
      Colors.red[400]!,
      Colors.red[700]!,
      Colors.green[400]!,
      Colors.green[700]!,
      Colors.orange[400]!,
      Colors.orange[700]!,
      Colors.purple[400]!,
      Colors.purple[700]!,
      Colors.teal[400]!,
      Colors.teal[700]!,
      Colors.pink[400]!,
      Colors.pink[700]!,
      Colors.amber[400]!,
      Colors.amber[700]!,
      Colors.indigo[400]!,
      Colors.indigo[700]!,
      Colors.lime[400]!,
      Colors.lime[700]!,
      Colors.cyan[400]!,
      Colors.cyan[700]!,
      Colors.brown[400]!,
      Colors.brown[700]!,
      // Additional colors with different shades
      Colors.deepOrange[400]!,
      Colors.deepOrange[700]!,
      Colors.lightBlue[400]!,
      Colors.lightBlue[700]!,
      Colors.lightGreen[400]!,
      Colors.lightGreen[700]!,
      Colors.deepPurple[400]!,
      Colors.deepPurple[700]!,
    ];

    // Use a more sophisticated hash function to better distribute colors
    int hash = 0;
    for (int i = 0; i < speciesId.length; i++) {
      hash = speciesId.codeUnitAt(i) + ((hash << 5) - hash);
    }
    hash = hash.abs();

    return colors[hash % colors.length];
  }
} 