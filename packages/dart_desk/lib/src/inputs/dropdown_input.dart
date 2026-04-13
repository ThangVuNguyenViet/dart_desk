import 'package:collection/collection.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

@Preview(name: 'CmsDropdownInput')
Widget preview() => ShadApp(
  home: CmsDropdownInput<String>(
    field: const CmsDropdownField(
      name: 'category',
      title: 'Category',
      option: CmsDropdownSimpleOption(
        options: [
          DropdownOption(value: 'tech', label: 'Technology'),
          DropdownOption(value: 'health', label: 'Health'),
          DropdownOption(value: 'finance', label: 'Finance'),
        ],
        placeholder: 'Select a category',
      ),
    ),
  ),
);

class CmsDropdownInput<T> extends StatelessWidget {
  const CmsDropdownInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  final CmsDropdownField<T> field;
  final CmsData? data;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fieldOption = field.option;
    if (fieldOption == null) {
      return _CmsDropdownInput<T>(
        title: field.title,
        description: field.description,
        data: data,
        onChanged: onChanged,
      );
    }

    final options = fieldOption.options(context);

    // If options is a Future, use FutureBuilder to handle async loading
    if (options is Future<List<DropdownOption<T>>>) {
      final defaultValue = fieldOption.defaultValue;
      return FutureBuilder(
        future: Future.wait([
          options,
          if (defaultValue is Future<T?>) defaultValue,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DropdownOption<T>> loadedOptions =
              snapshot.data?.first as List<DropdownOption<T>>? ?? [];
          final loadedDefaultValue = (defaultValue is Future<T?>)
              ? snapshot.data?.last as T?
              : defaultValue;

          return _CmsDropdownInput<T>(
            title: field.title,
            description: field.description,
            placeholder: fieldOption.placeholder,
            options: loadedOptions,
            defaultValue: loadedDefaultValue,
            data: data,
            onChanged: onChanged,
            fromMap: field.fromMap,
          );
        },
      );
    }

    return _CmsDropdownInput<T>(
      title: field.title,
      description: field.description,
      placeholder: fieldOption.placeholder,
      options: options,
      defaultValue: fieldOption.defaultValue as T?,
      data: data,
      onChanged: onChanged,
      fromMap: field.fromMap,
    );
  }
}

class _CmsDropdownInput<T> extends StatefulWidget {
  final List<DropdownOption<T>> options;
  final T? defaultValue;
  final CmsData? data;
  final String title;
  final String? description;
  final String? placeholder;
  final T Function(Map<String, dynamic>)? fromMap;

  final ValueChanged<T?>? onChanged;

  const _CmsDropdownInput({
    super.key,
    this.onChanged,
    this.defaultValue,
    this.data,
    this.options = const [],
    required this.title,
    this.description,
    this.placeholder,
    this.fromMap,
  });

  @override
  State<_CmsDropdownInput<T>> createState() => _CmsDropdownInputState<T>();
}

class _CmsDropdownInputState<T> extends State<_CmsDropdownInput<T>> {
  late ShadSelectController<T> _controller;
  List<DropdownOption<T>> _filteredOptions = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _controller = ShadSelectController<T>(initialValue: _resolveInitialSet());
    _filteredOptions = widget.options;
  }

  @override
  void didUpdateWidget(_CmsDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      final resolved = _resolveInitialSet();
      _controller.value = resolved;
    }
    if (widget.options != oldWidget.options) {
      _applySearch();
    }
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _applySearch();
  }

  void _applySearch() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _filteredOptions = widget.options;
      } else {
        final lower = _searchQuery.toLowerCase();
        _filteredOptions = widget.options
            .where((opt) => opt.label.toLowerCase().contains(lower))
            .toList();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Resolves the initial value set, returning empty set when no valid selection.
  Set<T> _resolveInitialSet() {
    final raw = widget.data?.value ?? widget.defaultValue;
    if (raw == null) return {};
    final T value;
    if (raw is T) {
      value = raw;
    } else if (widget.fromMap != null && raw is Map) {
      value = widget.fromMap!(Map<String, dynamic>.from(raw));
    } else {
      value = raw as T;
    }
    return {value};
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final options = widget.options;

    if (options.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.border),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('No options available', style: theme.textTheme.muted),
          ),
          if (widget.description != null) ...[
            const SizedBox(height: 4),
            Text(widget.description!, style: theme.textTheme.muted),
          ],
        ],
      );
    }

    // Convert dropdown options to select options
    final selectOptions = _filteredOptions
        .map(
          (option) =>
              ShadOption<T>(value: option.value, child: Text(option.label)),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title.isNotEmpty) ...[
          Text(
            widget.title,
            style: theme.textTheme.small.copyWith(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
        ],
        ShadSelect<T>.withSearch(
          controller: _controller,
          searchPlaceholder: const Text('Search...'),
          onSearchChanged: _onSearchChanged,
          placeholder: Text(
            widget.placeholder ?? 'Select an option...',
            style: theme.textTheme.muted,
          ),
          allowDeselection: true,
          options: selectOptions,
          selectedOptionBuilder: (context, T value) {
            final option = options.firstWhereOrNull(
              (opt) => opt.value == value,
            );
            return Text(option?.label ?? value.toString());
          },
          onChanged: (value) {
            widget.onChanged?.call(value);
          },
        ),
        if (widget.description != null) ...[
          const SizedBox(height: 4),
          Text(widget.description!, style: theme.textTheme.muted),
        ],
      ],
    );
  }
}
