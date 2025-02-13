import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../models/species.dart';
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart'; // You'll need to add this package
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../widgets/game_fish_badge.dart';

class SurveyDetailScreen extends StatefulWidget {
  final FishData survey;

  const SurveyDetailScreen({
    super.key,
    required this.survey,
  });

  @override
  State<SurveyDetailScreen> createState() => _SurveyDetailScreenState();
}

class _SurveyDetailScreenState extends State<SurveyDetailScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  Map<String, dynamic>? graphData;
  Species? speciesData;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadGraphData();
    _loadSpeciesData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadSpeciesData() async {
    try {
      final species = await _apiService.getSpecies();
      final matchingSpecies = species.firstWhere(
        (s) => s.commonName.toLowerCase() == widget.survey.speciesName.toLowerCase(),
      );
      setState(() {
        speciesData = matchingSpecies;
      });
    } catch (e) {
      print('Error loading species data: $e');
    }
  }

  Future<void> _loadGraphData() async {
    try {
      final data = await _apiService.getGraphData(
        dow: widget.survey.dowNumber.toString(),
        species: widget.survey.speciesName,
        date: widget.survey.surveyDate,
      );
      setState(() {
        graphData = data;
      });
    } catch (e) {
      // Handle error
      print('Error loading graph data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.survey.lakeName),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero image section
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                widget.survey.imageUrl,
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
                  Text(
                    widget.survey.speciesName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Lake: ${widget.survey.lakeName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    'County: ${widget.survey.countyName}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),

                  // Stats card
                  _buildStatCard(),
                  const SizedBox(height: 24),


                  // Graph section
                  Text(
                    'Length Frequency Distribution',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: graphData == null
                        ? const Center(child: CircularProgressIndicator())
                        : _buildGraph(),
                  ),

                   // Survey details
                  Text(
                    'DOW Number: ${widget.survey.dowNumber}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Survey Type: ${widget.survey.surveySubType.isNotEmpty ? widget.survey.surveySubType : widget.survey.surveyType}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  
                  // Survey narrative
                  HtmlWidget(
                    widget.survey.narrative,
                    textStyle: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStat('Total Catch', widget.survey.totalCatch.toString()),
            _buildStat('Min Length', '${widget.survey.minLength}"'),
            _buildStat('Max Length', '${widget.survey.maxLength}"'),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildGraph() {
    if (graphData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Safely access the data array with null checking
    final fishCountData = graphData!['data'];
    if (fishCountData == null || fishCountData is! List) {
      return const Center(child: Text('No length frequency data available'));
    }

    // Convert the graph data into BarChartGroupData
    final List<BarChartGroupData> barGroups = [];
    
    for (final item in fishCountData) {
      try {
        final length = item['length'];
        final quantity = item['quantity'];
        
        if (length == null || quantity == null) continue;

        barGroups.add(
          BarChartGroupData(
            x: length is int ? length : int.parse(length.toString()),
            barRods: [
              BarChartRodData(
                toY: quantity is int ? quantity.toDouble() : double.parse(quantity.toString()),
                color: Theme.of(context).primaryColor,
                width: 16,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
            ],
          ),
        );
      } catch (e) {
        print('Error parsing graph data point: $e');
        continue;
      }
    }

    if (barGroups.isEmpty) {
      return const Center(child: Text('No length frequency data available'));
    }

    // Sort the bar groups by length (x value)
    barGroups.sort((a, b) => a.x.compareTo(b.x));

    // Calculate the range of lengths
    final minX = barGroups.first.x;
    final maxX = barGroups.last.x;
    final lengthRange = maxX - minX;

    // Adjust bar width based on length range
    // If range is small (like 5-10 inches), use wider bars and less spacing
    // If range is large (like 22-50 inches), use thinner bars
    final barWidth = lengthRange < 10 
        ? 24.0  // Wider bars for small ranges
        : (MediaQuery.of(context).size.width - 80) / (barGroups.length * 2);

    // Update the bar configuration
    final updatedBarGroups = barGroups.map((group) => 
      BarChartGroupData(
        x: group.x,
        barRods: [
          BarChartRodData(
            toY: group.barRods.first.toY,
            color: Theme.of(context).primaryColor,
            width: lengthRange < 10 ? barWidth : barWidth.clamp(8, 16).toDouble(),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      ),
    ).toList();

    // Calculate key points for labels
    final lengths = updatedBarGroups.map((g) => g.x).toList();
    final minLength = lengths.first;
    final maxLength = lengths.last;
    final midIndex = lengths.length ~/ 2;
    final q1Index = lengths.length ~/ 4;
    final q3Index = (lengths.length * 3) ~/ 4;

    final keyPoints = {
      minLength,  // Min
      lengths[q1Index],  // Q1
      lengths[midIndex], // Median
      lengths[q3Index],  // Q3
      maxLength,  // Max
    };

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        barTouchData: BarTouchData(enabled: false),
        maxY: updatedBarGroups.map((g) => g.barRods.first.toY).reduce((a, b) => a > b ? a : b) * 1.2,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Only show the key points
                if (!keyPoints.contains(value)) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    '${value.toInt()}"',
                    style: const TextStyle(fontSize: 12),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                // Only show integer values
                if (value != value.roundToDouble()) {
                  return const SizedBox.shrink();
                }
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 12),
                );
              },
              reservedSize: 40,
            ),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border.all(color: Colors.grey.shade300),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.shade300,
              strokeWidth: 1,
            );
          },
        ),
        barGroups: updatedBarGroups,
      ),
    );
  }
} 