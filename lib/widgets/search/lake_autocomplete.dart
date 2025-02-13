// lake_autocomplete.dart
import 'package:flutter/material.dart';

class LakeAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? selectedLake;
  final List<String> availableLakes;
  final Function(String) onSelected;
  final Function() onClear;

  const LakeAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedLake,
    required this.availableLakes,
    required this.onSelected,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<String>(
      focusNode: focusNode,
      textEditingController: controller,
      displayStringForOption: (String option) => option,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          print("DEBUG: optionsBuilder returning availableLakes: ${availableLakes.length}");
          return availableLakes;
        }
        final options = availableLakes.where((lake) =>
            lake.toLowerCase().contains(textEditingValue.text.toLowerCase()));
        print("DEBUG: optionsBuilder filtered options: ${options.toList()}");
        return options;
      },
      onSelected: onSelected,
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return TextFormField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: 'Lake Name',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.search),
            suffixIcon: controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: onClear,
                  )
                : null,
          ),
          onEditingComplete: () {
            focusNode.unfocus();
          },
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        print("DEBUG: optionsViewBuilder, options count: ${options.length}");
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 300, maxWidth: 350),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    child: Text(
                      'Available Lakes (${availableLakes.length})',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  Flexible(
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () {
                            onSelected(option);
                            FocusScope.of(context).unfocus();
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}