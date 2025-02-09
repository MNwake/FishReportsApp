import 'package:flutter/material.dart';
import 'package:frontend/core/models/fish_graph_data.dart';
import 'package:frontend/core/models/fish_survey.dart';

class SurveyInfoCard extends StatelessWidget {
  final GraphData graphData;
  final FishSurvey survey;

  const SurveyInfoCard({
    super.key,
    required this.graphData,
    required this.survey,
  });

  @override
  Widget build(BuildContext context) {
    int totalFish = 0;
    for (var freq in graphData.data) {
      totalFish = totalFish + freq.quantity;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (survey.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  survey.imageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            const SizedBox(height: 16),
            Text(
              survey.speciesName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (survey.description.isNotEmpty) ...[
              Text(
                survey.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
            ],
            _InfoRow(
              label: 'Lake:',
              value: survey.lakeName,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'County:',
              value: survey.countyName,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'DOW Number:',
              value: survey.dowNumber,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Survey Date:',
              value: survey.surveyDate,
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Total Fish:',
              value: survey.totalCatch.toString(),
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Size Range:',
              value: '${survey.minLength} - ${survey.maxLength} inches',
            ),
            const SizedBox(height: 4),
            _InfoRow(
              label: 'Average Length:',
              value: '${_calculateAverageLength().toStringAsFixed(1)} inches',
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverageLength() {
    int totalFish = 0;
    double totalLength = 0;

    for (var freq in graphData.data) {
      totalFish += freq.quantity;
      totalLength += freq.length * freq.quantity;
    }

    return totalLength / totalFish;
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
} 