import 'package:flutter/material.dart';
import 'package:frontend/core/models/fish_survey.dart';
import 'package:go_router/go_router.dart';

class FishSurveyCard extends StatelessWidget {
  final FishSurvey survey;
  final CardType type;

  const FishSurveyCard({
    super.key,
    required this.survey,
    required this.type,
  });

  String _getMetricText() {
    switch (type) {
      case CardType.recent:
        return 'Date: ${survey.surveyDate}';
      case CardType.biggest:
        return 'Length: ${survey.maxLength} inches';
      case CardType.mostCaught:
        return 'Count: ${survey.totalCatch}';
      case CardType.species:
        return survey.isGameFish ? 'Game Fish' : '';
    }
  }

  @override
  Widget build(BuildContext context) {

    Widget buildGameFishIndicator() {
      
      if (type == CardType.species) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: survey.isGameFish 
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                survey.isGameFish ? Icons.check_circle : Icons.cancel,
                size: 16,
                color: survey.isGameFish 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.error,
              ),
              const SizedBox(width: 4),
              Text(
                'Game Fish',
                style: TextStyle(
                  color: survey.isGameFish 
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }
      return const SizedBox.shrink();
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (type == CardType.species) {
            context.push('/search', extra: {'species': survey.speciesName});
          } else {
            final surveyId = '${survey.dowNumber}_${survey.speciesName}_${survey.surveyDate}';
            context.push('/survey/$surveyId');
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: survey.imageUrl.isNotEmpty
                  ? Image.network(
                      survey.imageUrl,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey[200],
                      width: double.infinity,
                      child: Icon(
                        Icons.water,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                    ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          survey.speciesName,
                          style: Theme.of(context).textTheme.titleMedium,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (type == CardType.species) buildGameFishIndicator(),
                      ],
                    ),
                    if (type != CardType.species) ...[
                      Text(
                        survey.lakeName,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        _getMetricText(),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum CardType {
  recent,
  biggest,
  mostCaught,
  species,
} 