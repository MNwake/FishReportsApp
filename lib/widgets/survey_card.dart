import 'package:flutter/material.dart';
import '../models/survey.dart';
import '../screens/survey_detail_screen.dart';

class SurveyCard extends StatelessWidget {
  final FishData survey;
  final String section; // 'recent', 'biggest', or 'most_caught'

  const SurveyCard({
    super.key,
    required this.survey,
    required this.section,
  });

  String _getSubtitle() {
    switch (section) {
      case 'biggest':
        return '${survey.maxLength}"';
      case 'most_caught':
        return '${survey.totalCatch} Caught';
      case 'recent':
      default:
        // Format the date here
        final date = DateTime.parse(survey.surveyDate);
        return '${date.month}/${date.day}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SurveyDetailScreen(survey: survey),
            ),
          );
        },
        child: SizedBox(
          width: 200,
          height: 300,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: Image.network(
                  survey.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.image_not_supported, size: 48),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10.0, 2.0, 4.0, 2.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        survey.speciesName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 2),R
                      Text(
                        survey.lakeName,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // const SizedBox(height: 2),
                      Text(
                        _getSubtitle(),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 