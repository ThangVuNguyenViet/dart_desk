import 'package:collection/collection.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskDropdownInput')
Widget preview() => ShadApp(
  home: DeskDropdownInput<String>(
    field: const DeskDropdownField(
      name: 'category',
      title: 'Category',
      option: DeskDropdownSimpleOption(
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

class DeskDropdownInput<T> extends StatelessWidget {
  const DeskDropdownInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  final DeskDropdownField<T> field;
  final DeskData? data;
  final ValueChanged<T?>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fieldOption = field.option;
    if (fieldOption == null) {
      return _DeskDropdownInput<T>(
        title: field.title,
        description: field.description,
        isOptional: false,
        data: data,
        onChanged: onChanged,
      );
    }

    final options = fieldOption.options(context);

    // If options is a Future, use FutureBuilder to handle async loading
    if (options is Future<List<DropdownOption<T>>>) {
      final initialValue = fieldOption.initialValue;
      return FutureBuilder(
        future: Future.wait([
          options,
          if (initialValue is Future<T?>) initialValue,
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<DropdownOption<T>> loadedOptions =
              snapshot.data?.first as List<DropdownOption<T>>? ?? [];
          final loadedDefaultValue = (initialValue is Future<T?>)
              ? snapshot.data?.last as T?
              : initialValue;

          return _DeskDropdownInput<T>(
            title: field.title,
            description: field.description,
            isOptional: fieldOption.optional,
            placeholder: fieldOption.placeholder,
            options: loadedOptions,
            initialValue: loadedDefaultValue,
            data: data,
            onChanged: onChanged,
            fromMap: field.fromMap,
          );
        },
      );
    }

    return _DeskDropdownInput<T>(
      title: field.title,
      description: field.description,
      isOptional: fieldOption.optional,
      placeholder: fieldOption.placeholder,
      options: options,
      initialValue: fieldOption.initialValue as T?,
      data: data,
      onChanged: onChanged,
      fromMap: field.fromMap,
    );
  }
}

class _DeskDropdownInput<T> extends StatefulWidget {
  final List<DropdownOption<T>> options;
  final T? initialValue;
  final DeskData? data;
  final String title;
  final String? description;
  final String? placeholder;
  final bool isOptional;
  final T Function(Map<String, dynamic>)? fromMap;

  final ValueChanged<T?>? onChanged;

  const _DeskDropdownInput({
    super.key,
    this.onChanged,
    this.initialValue,
    this.data,
    this.options = const [],
    required this.title,
    this.description,
    this.placeholder,
    this.isOptional = false,
    this.fromMap,
  });

  @override
  State<_DeskDropdownInput<T>> createState() => _DeskDropdownInputState<T>();
}

class _DeskDropdownInputState<T> extends State<_DeskDropdownInput<T>> {
  late ShadSelectController<T> _controller;
  List<DropdownOption<T>> _filteredOptions = [];
  String _searchQuery = '';
  late bool _isEnabled;
  T? _lastValue;

  bool get _isOptional => widget.isOptional;

  @override
  void initState() {
    super.initState();
    _controller = ShadSelectController<T>(initialValue: _resolveInitialSet());
    _filteredOptions = widget.options;
    _isEnabled = _isOptional ? widget.data?.value != null : true;
    _lastValue = _resolveRawValue();
  }

  @override
  void didUpdateWidget(_DeskDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      final resolved = _resolveInitialSet();
      _controller.value = resolved;
      if (_isOptional) {
        setState(() => _isEnabled = widget.data?.value != null);
      }
    }
    if (widget.options != oldWidget.options) {
      _applySearch();
    }
  }

  T? _resolveRawValue() {
    final raw = widget.data?.value ?? widget.initialValue;
    if (raw == null) return null;
    if (raw is T) return raw;
    if (widget.fromMap != null && raw is Map) {
      return widget.fromMap!(Map<String, dynamic>.from(raw));
    }
    return raw as T?;
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastValue = _controller.value.firstOrNull;
        _isEnabled = false;
        _controller.value = {};
      } else {
        _isEnabled = true;
        final restore = _lastValue;
        _controller.value = restore != null ? {restore} : {};
      }
    });
    widget.onChanged?.call(enabled ? _lastValue : null);
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
    final raw = widget.data?.value ?? widget.initialValue;
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
          OptionalFieldHeader(
            title: widget.title,
            isOptional: _isOptional,
            isEnabled: _isEnabled,
            onToggle: _handleToggle,
          ),
          const SizedBox(height: 8),
          OptionalFieldWrapper(
            isEnabled: !_isOptional || _isEnabled,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.border),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text('No options available', style: theme.textTheme.muted),
            ),
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
        OptionalFieldHeader(
          title: widget.title,
          isOptional: _isOptional,
          isEnabled: _isEnabled,
          onToggle: _handleToggle,
        ),
        const SizedBox(height: 8),
        OptionalFieldWrapper(
          isEnabled: !_isOptional || _isEnabled,
          child: ShadSelect<T>.withSearch(
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
              if (_isEnabled) {
                _lastValue = value;
                widget.onChanged?.call(value);
              }
            },
          ),
        ),
        if (widget.description != null) ...[
          const SizedBox(height: 4),
          Text(widget.description!, style: theme.textTheme.muted),
        ],
      ],
    );
  }
}
