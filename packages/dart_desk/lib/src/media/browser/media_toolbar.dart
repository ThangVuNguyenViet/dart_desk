import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:signals/signals_flutter.dart';

import '../../data/models/image_types.dart';
import 'media_browser_state.dart';

class MediaToolbar extends StatefulWidget {
  final MediaBrowserState state;

  const MediaToolbar({super.key, required this.state});

  @override
  State<MediaToolbar> createState() => _MediaToolbarState();
}

class _MediaToolbarState extends State<MediaToolbar> {
  late final _searchController =
      TextEditingController(text: widget.state.search.value);
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.state.search.value = value;
      widget.state.page.value = 0;
      widget.state.loadAssets();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Search
          Expanded(
            child: ShadInput(
              key: const ValueKey('media_search'),
              controller: _searchController,
              placeholder: const Text('Search media...'),
              onChanged: _onSearchChanged,
              leading: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FaIcon(
                  FontAwesomeIcons.magnifyingGlass,
                  size: 14,
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),

          // Type filter
          ShadSelect<MediaTypeFilter>(
            key: const ValueKey('media_filter_type'),
            initialValue: MediaTypeFilter.all,
            onChanged: (value) {
              if (value == null) return;
              widget.state.typeFilter.value = value;
              widget.state.page.value = 0;
              widget.state.loadAssets();
            },
            options: MediaTypeFilter.values
                .map((t) => ShadOption(value: t, child: Text(_typeLabel(t))))
                .toList(),
            selectedOptionBuilder: (context, value) =>
                Text(_typeLabel(value)),
          ),
          const SizedBox(width: 8),

          // Sort
          ShadSelect<MediaSort>(
            initialValue: MediaSort.dateDesc,
            onChanged: (value) {
              if (value == null) return;
              widget.state.sort.value = value;
              widget.state.loadAssets();
            },
            options: MediaSort.values
                .map(
                    (s) => ShadOption(value: s, child: Text(_sortLabel(s))))
                .toList(),
            selectedOptionBuilder: (context, value) =>
                Text(_sortLabel(value)),
          ),
          const SizedBox(width: 8),

          // Grid/List toggle
          Watch((context) {
            final isGrid = widget.state.isGridView.watch(context);
            return ShadButton.outline(
              size: ShadButtonSize.sm,
              onPressed: () =>
                  widget.state.isGridView.value = !isGrid,
              child: FaIcon(
                isGrid
                    ? FontAwesomeIcons.list
                    : FontAwesomeIcons.tableColumns,
                size: 14,
              ),
            );
          }),
        ],
      ),
    );
  }

  String _typeLabel(MediaTypeFilter type) => switch (type) {
        MediaTypeFilter.all => 'All types',
        MediaTypeFilter.image => 'Images',
        MediaTypeFilter.video => 'Videos',
        MediaTypeFilter.file => 'Files',
      };

  String _sortLabel(MediaSort sort) => switch (sort) {
        MediaSort.dateDesc => 'Newest first',
        MediaSort.dateAsc => 'Oldest first',
        MediaSort.nameAsc => 'Name A-Z',
        MediaSort.nameDesc => 'Name Z-A',
        MediaSort.sizeDesc => 'Largest',
        MediaSort.sizeAsc => 'Smallest',
      };
}
