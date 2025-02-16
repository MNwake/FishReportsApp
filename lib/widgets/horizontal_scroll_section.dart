import 'package:flutter/material.dart';

class HorizontalScrollSection<T> extends StatefulWidget {
  final String title;
  final String? subtitle;
  final Future<List<T>> futureData;
  final Widget Function(T) itemBuilder;
  final Future<List<T>> Function(int page)? onLoadMore;

  const HorizontalScrollSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.futureData,
    required this.itemBuilder,
    this.onLoadMore,
  });

  @override
  State<HorizontalScrollSection<T>> createState() => _HorizontalScrollSectionState<T>();
}

class _HorizontalScrollSectionState<T> extends State<HorizontalScrollSection<T>> {
  final ScrollController _scrollController = ScrollController();
  List<T> _items = [];
  bool _isLoading = false;
  int _currentPage = 1;
  
  @override
  void initState() {
    super.initState();
    _loadInitialData();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final initialData = await widget.futureData;
    if (mounted) {
      setState(() => _items = initialData);
    }
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _isLoading || widget.onLoadMore == null) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    // Load more when user scrolls past 80% of the list
    if (currentScroll >= (maxScroll * 0.8)) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    if (_isLoading) return;

    setState(() => _isLoading = true);
    try {
      final newItems = await widget.onLoadMore!(_currentPage + 1);
      if (mounted && newItems.isNotEmpty) {
        setState(() {
          _items.addAll(newItems);
          _currentPage++;
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              if (widget.subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  widget.subtitle!,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ],
          ),
        ),
        SizedBox(
          height: 240,
          child: Stack(
            children: [
              ListView.builder(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                itemCount: _items.length + (_isLoading ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index == _items.length) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: widget.itemBuilder(_items[index]),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
} 