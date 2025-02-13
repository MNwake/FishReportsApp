// county_autocomplete.dart
import 'package:flutter/material.dart';
import '../../models/county.dart';

class CountyAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final List<County> selectedCounties;
  final List<County> allCounties;
  final Function(List<County>) onSelectionChanged;
  final Function() onClear;

  const CountyAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedCounties,
    required this.allCounties,
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
            labelText: 'Counties',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: selectedCounties.isNotEmpty
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
        if (selectedCounties.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Wrap(
              spacing: 8.0,
              children: selectedCounties
                  .map((county) => Chip(
                        label: Text(county.countyName),
                        onDeleted: () {
                          final newSelection = List<County>.from(selectedCounties)
                            ..remove(county);
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
    final List<County> tempSelection = List.from(selectedCounties);

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Counties'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SizedBox(
                width: double.maxFinite,
                height: 400, // Fixed height for scrolling
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: allCounties.length,
                  itemBuilder: (context, index) {
                    final county = allCounties[index];
                    return CheckboxListTile(
                      title: Text(county.countyName),
                      subtitle: Text('${county.lakes.length} lakes'),
                      value: tempSelection.contains(county),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            tempSelection.add(county);
                          } else {
                            tempSelection.remove(county);
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
                controller.text = tempSelection.map((c) => c.countyName).join(', ');
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