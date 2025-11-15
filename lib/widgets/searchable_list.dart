import 'package:flutter/material.dart';

/// Generic "search + list + select" widget.
/// T is whatever type your items are (Map, model class, etc).
class SearchableList<T> extends StatefulWidget {
  final List<T> items;

  /// Main text for each row
  final String Function(T item) labelBuilder;

  /// Optional smaller subtitle line
  final String Function(T item)? subtitleBuilder;

  /// Filter logic: return true if item matches search text
  final bool Function(T item, String searchText) filter;

  /// Called when the user taps an item
  final void Function(T item)? onSelected;

  /// Placeholder text for the search bar
  final String searchHint;

  /// Text shown when no results match
  final String emptyText;

  const SearchableList({
    super.key,
    required this.items,
    required this.labelBuilder,
    required this.filter,
    this.subtitleBuilder,
    this.onSelected,
    this.searchHint = 'Search',
    this.emptyText = 'No items found',
  });

  @override
  State<SearchableList<T>> createState() => _SearchableListState<T>();
}

class _SearchableListState<T> extends State<SearchableList<T>> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchText = '';
  T? _selectedItem;

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchText = _searchCtrl.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  List<T> get _filteredItems {
    if (_searchText.isEmpty) return widget.items;
    return widget.items
        .where((item) => widget.filter(item, _searchText))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            labelText: widget.searchHint,
            prefixIcon: const Icon(Icons.search),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? Center(child: Text(widget.emptyText))
              : ListView.separated(
                  itemCount: filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = filtered[index];
                    final selected = identical(item, _selectedItem);

                    return ListTile(
                      title: Text(widget.labelBuilder(item)),
                      subtitle: widget.subtitleBuilder != null
                          ? Text(widget.subtitleBuilder!(item))
                          : null,
                      selected: selected,
                      trailing:
                          selected ? const Icon(Icons.check) : null,
                      onTap: () {
                        setState(() {
                          _selectedItem = item;
                        });
                        widget.onSelected?.call(item);
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }
}
