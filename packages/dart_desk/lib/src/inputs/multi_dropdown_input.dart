import 'package:collection/collection.dart';
import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CmsMultiDropdownInput<T> extends StatelessWidget {
  const CmsMultiDropdownInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  final CmsMultiDropdownField<T> field;
  final CmsData? data;
  final ValueChanged<List<T>>? onChanged;

  @override
  Widget build(BuildContext context) {
    final fieldOption = field.option;
    if (fieldOption == null) {
      return _CmsMultiDropdownInput<T>(
        title: field.title,
        description: field.description,
        data: data,
        onChanged: onChanged,
      );
    }

    final options = fieldOption.options(context);

    // Handle async options (same pattern as CmsDropdownInput)
    if (options is Future<List<DropdownOption<T>>>) {
      return FutureBuilder(
        future: options,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final loadedOptions = snapshot.data ?? [];
          return _CmsMultiDropdownInput<T>(
            title: field.title,
            description: field.description,
            placeholder: fieldOption.placeholder,
            options: loadedOptions,
            defaultValues: fieldOption.defaultValues,
            minSelected: fieldOption.minSelected,
            maxSelected: fieldOption.maxSelected,
            data: data,
            onChanged: onChanged,
            fromMap: field.fromMap,
          );
        },
      );
    }

    return _CmsMultiDropdownInput<T>(
      title: field.title,
      description: field.description,
      placeholder: fieldOption.placeholder,
      options: options,
      defaultValues: fieldOption.defaultValues,
      minSelected: fieldOption.minSelected,
      maxSelected: fieldOption.maxSelected,
      data: data,
      onChanged: onChanged,
      fromMap: field.fromMap,
    );
  }
}

class _CmsMultiDropdownInput<T> extends StatefulWidget {
  final List<DropdownOption<T>> options;
  final List<T>? defaultValues;
  final CmsData? data;
  final String title;
  final String? description;
  final String? placeholder;
  final int? minSelected;
  final int? maxSelected;
  final T Function(Map<String, dynamic>)? fromMap;
  final ValueChanged<List<T>>? onChanged;

  const _CmsMultiDropdownInput({
    super.key,
    this.onChanged,
    this.defaultValues,
    this.data,
    this.options = const [],
    required this.title,
    this.description,
    this.placeholder,
    this.minSelected,
    this.maxSelected,
    this.fromMap,
  });

  @override
  State<_CmsMultiDropdownInput<T>> createState() =>
      _CmsMultiDropdownInputState<T>();
}

class _CmsMultiDropdownInputState<T> extends State<_CmsMultiDropdownInput<T>> {
  late ShadSelectController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = ShadSelectController<T>(initialValue: _resolveInitialSet());
  }

  @override
  void didUpdateWidget(_CmsMultiDropdownInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _controller.value = _resolveInitialSet();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Set<T> _resolveInitialSet() {
    final value = widget.data?.value ?? widget.defaultValues;
    if (value == null) return {};
    if (value is List) {
      return value.map<T>((e) {
        if (e is T) return e;
        if (widget.fromMap != null && e is Map) {
          return widget.fromMap!(Map<String, dynamic>.from(e));
        }
        return e as T;
      }).toSet();
    }
    return {};
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

    final selectOptions = options
        .map((option) =>
            ShadOption<T>(value: option.value, child: Text(option.label)))
        .toList();

    final currentCount = _controller.value.length;
    final atMin =
        widget.minSelected != null && currentCount <= widget.minSelected!;

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
        ShadSelect<T>.multiple(
          controller: _controller,
          placeholder: Text(
            widget.placeholder ?? 'Select options...',
            style: theme.textTheme.muted,
          ),
          allowDeselection: !atMin,
          closeOnSelect: false,
          options: selectOptions,
          selectedOptionsBuilder: (context, values) {
            final labels = values
                .map((v) =>
                    options.firstWhereOrNull((o) => o.value == v)?.label ??
                    v.toString())
                .join(', ');
            return Text(labels);
          },
          onChanged: (Set<T> values) {
            // Enforce maxSelected
            if (widget.maxSelected != null &&
                values.length > widget.maxSelected!) {
              return;
            }
            setState(() {}); // Rebuild for allowDeselection check
            widget.onChanged?.call(values.toList());
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
