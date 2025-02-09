import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/models/county.dart';

class CountyCard extends StatelessWidget {
  final County county;

  const CountyCard({
    super.key,
    required this.county,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          context.push('/search', extra: {'county': county.name});
        },
        child: SizedBox(
          width: 200,
          height: 150,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                county.mapImageUrl,
                fit: BoxFit.contain,
                alignment: Alignment.center,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  child: Icon(
                    Icons.location_on,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 8, // Padding from bottom
                child: Text(
                  county.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 