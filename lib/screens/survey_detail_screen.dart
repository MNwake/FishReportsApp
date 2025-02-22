import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../models/species.dart';
import '../services/api_service.dart';
import 'package:fl_chart/fl_chart.dart'; // You'll need to add this package
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import '../widgets/game_fish_badge.dart';
import '../models/fish_data.dart';
import '../widgets/length_distribution_chart.dart';
import '../models/length_data.dart';
import 'package:intl/intl.dart';

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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Survey Report'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero image section
            Container(
              width: double.infinity,  // Takes full width
              child: widget.survey.imageUrl.startsWith('assets/') 
                  ? Image.asset(
                      widget.survey.imageUrl,
                      fit: BoxFit.fitWidth,  // Fits to width
                    )
                  : Image.network(
                      widget.survey.imageUrl,
                      fit: BoxFit.fitWidth,  // Fits to width
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset(
                          'assets/images/No_Image_Available.jpg',
                          fit: BoxFit.fitWidth,  // Fits to width
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
                  Text(
                    'Survey Date: ${DateFormat.yMMMMd().format(DateTime.parse(widget.survey.surveyDate))}',
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

    final fishCountData = graphData!['data'];
    if (fishCountData == null || fishCountData is! List) {
      return const Center(child: Text('No length frequency data available'));
    }

    // Convert API data to LengthData format
    final List<LengthData> chartData = fishCountData.map<LengthData>((item) {
      return LengthData.fromJson(item);
    }).toList();

    return LengthDistributionChart(graphData: chartData);
  }
} 