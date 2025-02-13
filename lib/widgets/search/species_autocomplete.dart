// species_autocomplete.dart
import 'package:flutter/material.dart';
import '../../models/species.dart';

class SpeciesAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? selectedSpecies;
  final List<Species> allSpecies;
  final Function(Species) onSelected;
  final Function() onClear;
  final Function(TextEditingController, String?, Function()) onFocusLost;

  const SpeciesAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedSpecies,
    required this.allSpecies,
    required this.onSelected,
    required this.onClear,
    required this.onFocusLost,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<Species>(
      focusNode: focusNode,
      textEditingController: controller,
      displayStringForOption: (Species option) => option.commonName,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return allSpecies;
        }
        return allSpecies.where((species) => species.commonName
            .toLowerCase()
            .contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (Species selection) {
        onSelected(selection);
        // Update the controller text here.
        controller.text = selection.commonName;
        print("DEBUG: Species selected on autocomplete: ${selection.commonName}");
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              onFocusLost(controller, selectedSpecies, onClear);
            }
          },
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'Species',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: onClear,
                    )
                  : null,
            ),
            onChanged: (value) {
              final matches = allSpecies.where((species) =>
                  species.commonName.toLowerCase().contains(value.toLowerCase()));
              if (matches.isEmpty && value.isNotEmpty) {
                controller.text = controller.text.substring(0, controller.text.length - 1);
                controller.selection = TextSelection.fromPosition(
                  TextPosition(offset: controller.text.length),
                );
              }
            },
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (!focusNode.hasFocus) return Container();
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 200, maxWidth: 350),
              child: ListView.builder(
                padding: EdgeInsets.zero,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return ListTile(
                    title: Text(option.commonName),
                    onTap: () {
                      onSelected(option);
                      FocusScope.of(context).unfocus();
                    },
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}