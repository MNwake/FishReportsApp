import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/core/models/fish_detail_data.dart';
import 'package:frontend/core/models/fish_graph_data.dart';
import 'package:frontend/features/fish_details/presentation/viewmodels/fish_details_viewmodel.dart';
import 'package:frontend/features/fish_details/presentation/widgets/fish_length_chart.dart';
import 'package:frontend/features/fish_details/presentation/widgets/survey_info_card.dart';

class SurveyDetailsPage extends ConsumerWidget {
  final String fishId;

  const SurveyDetailsPage({
    super.key,
    required this.fishId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailDataState = ref.watch(fishDetailsViewModelProvider(fishId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Survey Details'),
      ),
      body: detailDataState.when(
        data: (detailData) => _buildContent(context, detailData),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, FishDetailData detailData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SurveyInfoCard(
            graphData: detailData.graphData,
            survey: detailData.survey,
          ),
          const SizedBox(height: 24),
          Text(
            'Length Distribution',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: FishLengthChart(frequencies: detailData.graphData.data),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
} 