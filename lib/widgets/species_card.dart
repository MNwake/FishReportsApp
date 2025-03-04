import 'package:flutter/material.dart';
import '../models/species.dart';
import 'game_fish_badge.dart';

class SpeciesCard extends StatelessWidget {
  final Species species;
  final VoidCallback? onTap;

  const SpeciesCard({
    super.key,
    required this.species,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 200,
          height: 280,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 2,
                child: species.imageUrl.startsWith('assets') 
                    ? Image.asset(
                        species.imageUrl,
                        fit: BoxFit.cover,
                      )
                    : species.imageUrl.isEmpty
                        ? Image.asset(
                            'assets/images/No_Image_Available.jpg',
                            fit: BoxFit.cover,
                          )
                        : Image.network(
                            species.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Image.asset(
                                'assets/images/No_Image_Available.jpg',
                                fit: BoxFit.cover,
                              );
                            },
                          ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        species.commonName,
                        style: Theme.of(context).textTheme.titleMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      GameFishBadge(isGameFish: species.gameFish),
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