// search_bar.dart
import 'package:flutter/material.dart';
import 'advanced_search_sheet.dart';
import '../models/search_state.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  
  const CustomSearchBar({
    super.key,
    required this.onSearch,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _searchController = TextEditingController();

  // Store the advanced search state so it persists between openings.
  AdvancedSearchState _advancedSearchState = AdvancedSearchState();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAdvancedSearch(BuildContext context) async {
    final result = await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AdvancedSearchSheet(initialState: _advancedSearchState),
    );
    
    // If the sheet returned an updated state, save it
    if (result != null && result is AdvancedSearchState) {
      setState(() {
        _advancedSearchState = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: SearchBar(
              controller: _searchController,
              hintText: 'Species, Lake, County...',
              leading: Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: const Icon(Icons.search),
              ),
              onSubmitted: widget.onSearch,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: () => _showAdvancedSearch(context),
            tooltip: 'Advanced Search',
          ),
        ],
      ),
    );
  }
}