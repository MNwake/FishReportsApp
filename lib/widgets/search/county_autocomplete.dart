// county_autocomplete.dart
import 'package:flutter/material.dart';
import '../../models/county.dart';

class CountyAutocomplete extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String? selectedCounty;
  final List<County> allCounties;
  final Function(County) onSelected;
  final Function() onClear;
  final Function(TextEditingController, String?, Function()) onFocusLost;

  const CountyAutocomplete({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.selectedCounty,
    required this.allCounties,
    required this.onSelected,
    required this.onClear,
    required this.onFocusLost,
  });

  @override
  Widget build(BuildContext context) {
    return RawAutocomplete<County>(
      focusNode: focusNode,
      textEditingController: controller,
      displayStringForOption: (County option) => option.countyName,
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) return allCounties;
        return allCounties.where((county) =>
            county.countyName.toLowerCase().contains(textEditingValue.text.toLowerCase()));
      },
      onSelected: (County selection) {
        print("DEBUG: County onSelected called with: ${selection.countyName}");
        onSelected(selection);
        WidgetsBinding.instance.addPostFrameCallback((_) {
          controller.text = selection.countyName;
        });
      },
      fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
        return Focus(
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              onFocusLost(controller, selectedCounty, onClear);
            }
          },
          child: TextFormField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: 'County',
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isNotEmpty
                  ? IconButton(icon: const Icon(Icons.clear), onPressed: onClear)
                  : null,
            ),
            onChanged: (value) {
              final matches = allCounties.where((county) =>
                  county.countyName.toLowerCase().contains(value.toLowerCase()));
              if (matches.isEmpty && value.isNotEmpty) {
                controller.text = controller.text.substring(0, controller.text.length - 1);
                controller.selection = TextSelection.fromPosition(
                    TextPosition(offset: controller.text.length));
              }
            },
          ),
        );
      },
      optionsViewBuilder: (context, onSelected, options) {
        if (!focusNode.hasFocus) return Container();
        return _buildOptionsView(context, onSelected, options);
      },
    );
  }

  Widget _buildOptionsView(BuildContext context, onSelected, Iterable<County> options) {
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
                title: Text(option.countyName),
                subtitle: Text('${option.lakes.length} lakes'),
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
  }
}