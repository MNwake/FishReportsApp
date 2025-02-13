import 'package:flutter/material.dart';

class YearDropdown extends StatelessWidget {
  final String label;
  final int? selectedYear;
  final List<int> yearOptions;
  final Function(int?) onChanged;

  const YearDropdown({
    super.key,
    required this.label,
    required this.selectedYear,
    required this.yearOptions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        suffixIcon: _buildSuffixIcon(context),
        hintText: selectedYear?.toString() ?? 'Select Year',
      ),
      controller: TextEditingController(text: selectedYear?.toString() ?? ''),
    );
  }

  Widget _buildSuffixIcon(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedYear != null)
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => onChanged(null),
          ),
        IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () => _showYearPicker(context),
        ),
      ],
    );
  }

  void _showYearPicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(label),
          content: SizedBox(
            width: double.minPositive,
            height: 300,
            child: ListView.builder(
              itemCount: yearOptions.length,
              itemBuilder: (context, index) {
                final year = yearOptions[index];
                return ListTile(
                  title: Text(year.toString()),
                  selected: year == selectedYear,
                  onTap: () {
                    onChanged(year);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
} 