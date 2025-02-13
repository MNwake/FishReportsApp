// species_autocomplete.dart
import 'package:flutter/material.dart';
import '../../models/species.dart';

class SpeciesAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<String> selectedSpecies;
  final List<Species> allSpecies;
  final Function(List<String>) onSelectionChanged;
  final Function() onClear;

  const SpeciesAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedSpecies,
    required this.allSpecies,
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
            labelText: 'Species',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: selectedSpecies.isNotEmpty
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
        if (selectedSpecies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: selectedSpecies
                  .map((species) => Chip(
                        label: Text(species),
                        onDeleted: () {
                          final newSelection = List<String>.from(selectedSpecies)
                            ..remove(species);
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
    final List<String> tempSelection = List.from(selectedSpecies);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Species'),
          content: StatefulBuilder(
            builder: (context, setState) {
              // Sort species alphabetically by common name
              final sortedSpecies = List<Species>.from(allSpecies)
                ..sort((a, b) => a.commonName.compareTo(b.commonName));
                
              return SizedBox(
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: sortedSpecies.length,
                  itemBuilder: (context, index) {
                    final species = sortedSpecies[index];
                    return CheckboxListTile(
                      title: Text(species.commonName),
                      subtitle: species.gameFish ? const Text('Game Fish') : null,
                      value: tempSelection.contains(species.commonName),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelection.add(species.commonName);
                          } else {
                            tempSelection.remove(species.commonName);
                          }
                        });
                      },
                    );
                  },
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