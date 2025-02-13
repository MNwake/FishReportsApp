import 'package:flutter/material.dart';

class GameFishBadge extends StatelessWidget {
  final bool isGameFish;

  const GameFishBadge({
    super.key,
    required this.isGameFish,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isGameFish 
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isGameFish ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isGameFish ? Icons.check_circle : Icons.cancel,
            size: 16,
            color: isGameFish ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            'Game Fish',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isGameFish ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
} 