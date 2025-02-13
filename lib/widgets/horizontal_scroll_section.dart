import 'package:flutter/material.dart';

class HorizontalScrollSection<T> extends StatelessWidget {
  final String title;
  final Future<List<T>> futureData;
  final Widget Function(T) itemBuilder;

  const HorizontalScrollSection({
    super.key,
    required this.title,
    required this.futureData,
    required this.itemBuilder,
  });

  String _getSectionId() {
    switch (title.toLowerCase()) {
      case 'biggest fish':
        return 'biggest';
      case 'most caught':
        return 'most_caught';
      case 'recent surveys':
      default:
        return 'recent';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 240,
          child: FutureBuilder<List<T>>(
            future: futureData,
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final items = snapshot.data!;

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: itemBuilder(items[index]),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
} 