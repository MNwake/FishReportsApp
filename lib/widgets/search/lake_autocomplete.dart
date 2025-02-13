// lake_autocomplete.dart
import 'package:flutter/material.dart';

class LakeAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> selectedLakes;
  final List<String> availableLakes;
  final Function(List<String>) onSelectionChanged;
  final Function() onClear;

  const LakeAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedLakes,
    required this.availableLakes,
    required this.onSelectionChanged,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          readOnly: true,
          decoration: InputDecoration(
            labelText: 'Lakes',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: selectedLakes.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  )
                : null,
          ),
          onTap: () {
            _showMultiSelect(context);
          },
        ),
        if (selectedLakes.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: selectedLakes
                  .map((lake) => Chip(
                        label: Text(lake),
                        onDeleted: () {
                          final newSelection = List<String>.from(selectedLakes)
                            ..remove(lake);
                          onSelectionChanged(newSelection);
                        },
                      ))
                  .toList(),
            ),
          ),
      ],
    );
  }

  Future<void> _showMultiSelect(BuildContext context) async {
    final List<String> tempSelection = List.from(selectedLakes);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Lakes'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                height: 400, // Fixed height for scrolling
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text('Available Lakes: ${availableLakes.length}'),
                    ),
                    Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: availableLakes.length,
                        itemBuilder: (context, index) {
                          final lake = availableLakes[index];
                          return CheckboxListTile(
                            title: Text(lake),
                            value: tempSelection.contains(lake),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  tempSelection.add(lake);
                                } else {
                                  tempSelection.remove(lake);
                                }
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSelectionChanged(tempSelection);
                controller.text = tempSelection.join(', ');
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        );
      },
    );
  }
}