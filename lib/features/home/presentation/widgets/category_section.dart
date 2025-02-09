import 'package:flutter/material.dart';

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _CategoryChip(
            label: 'Recent Surveys',
            icon: Icons.access_time,
            onTap: () {
              // TODO: Implement filtering by recent surveys
            },
          ),
          const SizedBox(width: 8),
          _CategoryChip(
            label: 'Biggest Fish',
            icon: Icons.straighten,
            onTap: () {
              // TODO: Implement filtering by size
            },
          ),
          const SizedBox(width: 8),
          _CategoryChip(
            label: 'Most Caught',
            icon: Icons.catching_pokemon,
            onTap: () {
              // TODO: Implement filtering by quantity
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onTap,
    );
  }
} 