// home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:frontend/features/home/presentation/viewmodels/home_viewmodel.dart';
import 'package:frontend/features/home/presentation/widgets/category_header.dart';
import 'package:frontend/features/home/presentation/widgets/county_card.dart';
import 'package:frontend/features/home/presentation/widgets/fish_survey_card.dart';
import 'package:frontend/features/home/presentation/widgets/search_bar_widget.dart';
import 'package:frontend/core/models/county.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentSurveysState = ref.watch(recentSurveysProvider);
    final biggestFishState = ref.watch(biggestFishProvider);
    final mostCaughtState = ref.watch(mostCaughtProvider);
    final allSpeciesState = ref.watch(allSpeciesProvider);
    final countiesState = ref.watch(countiesProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Search App Bar
          SliverAppBar(
            floating: true,
            expandedHeight: 120,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Theme.of(context).colorScheme.surface,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SearchBarWidget(),
                  ),
                ),
              ),
            ),
          ),

          // Recent Surveys Section
          const SliverToBoxAdapter(
            child: CategoryHeader(title: 'Recent Surveys'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: recentSurveysState.when(
                data: (surveys) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: surveys.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 200,
                      child: FishSurveyCard(
                        survey: surveys[index],
                        type: CardType.recent,
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ),

          // Biggest Fish Section
          const SliverToBoxAdapter(
            child: CategoryHeader(title: 'Biggest Fish'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: biggestFishState.when(
                data: (surveys) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: surveys.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 200,
                      child: FishSurveyCard(
                        survey: surveys[index],
                        type: CardType.biggest,
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ),

          // Most Caught Section
          const SliverToBoxAdapter(
            child: CategoryHeader(title: 'Most Caught'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: mostCaughtState.when(
                data: (surveys) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: surveys.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 200,
                      child: FishSurveyCard(
                        survey: surveys[index],
                        type: CardType.mostCaught,
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ),

          // By Species Section
          const SliverToBoxAdapter(
            child: CategoryHeader(title: 'Browse by Species'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: allSpeciesState.when(
                data: (species) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: species.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 200,
                      child: FishSurveyCard(
                        survey: species[index],
                        type: CardType.species,
                      ),
                    ),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ),

          // Counties Section
          const SliverToBoxAdapter(
            child: CategoryHeader(title: 'Browse by County'),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 160,
              child: countiesState.when(
                data: (counties) => ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: counties.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: CountyCard(county: counties[index]),
                  ),
                ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
          ),

          const SliverPadding(padding: EdgeInsets.only(bottom: 32)),
        ],
      ),
    );
  }
} 