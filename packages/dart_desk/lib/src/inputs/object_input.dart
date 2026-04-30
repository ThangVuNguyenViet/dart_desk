import 'package:dart_desk_annotation/dart_desk_annotation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widget_previews.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../studio/components/forms/desk_form.dart';
import 'optional_field_header.dart';
import 'optional_field_wrapper.dart';

@Preview(name: 'DeskObjectInput')
Widget preview() => ShadApp(
  home: DeskObjectInput(
    field: const DeskObjectField(
      name: 'address',
      title: 'Address',
      option: DeskObjectOption(
        children: [
          ColumnFields(
            children: [
              DeskStringField(
                name: 'street',
                title: 'Street',
                option: DeskStringOption(),
              ),
            ],
          ),
          RowFields(
            children: [
              DeskStringField(
                name: 'city',
                title: 'City',
                option: DeskStringOption(),
              ),
              DeskStringField(
                name: 'zipCode',
                title: 'Zip Code',
                option: DeskStringOption(),
              ),
            ],
          ),
          GroupFields(
            title: 'Coordinates',
            collapsible: true,
            collapsed: true,
            children: [
              RowFields(
                children: [
                  DeskNumberField(
                    name: 'lat',
                    title: 'Latitude',
                    option: DeskNumberOption(),
                  ),
                  DeskNumberField(
                    name: 'lng',
                    title: 'Longitude',
                    option: DeskNumberOption(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);

class DeskObjectInput extends StatefulWidget {
  final DeskObjectField field;
  final DeskData? data;
  final ValueChanged<Map<String, dynamic>?>? onChanged;

  const DeskObjectInput({
    super.key,
    required this.field,
    this.data,
    this.onChanged,
  });

  @override
  State<DeskObjectInput> createState() => _DeskObjectInputState();
}

class _DeskObjectInputState extends State<DeskObjectInput> {
  late Map<String, dynamic> _value;
  late bool _isEnabled;
  Map<String, dynamic>? _lastValue;

  bool get _isOptional => widget.field.option.optional;

  static Map<String, dynamic> _toMap(Object? value) {
    if (value is Map<String, dynamic>) return Map<String, dynamic>.from(value);
    if (value is Serializable) return value.toMap();
    return {};
  }

  @override
  void initState() {
    super.initState();
    _value = _toMap(widget.data?.value);
    _isEnabled = _isOptional ? widget.data?.value != null : true;
    _lastValue = _isEnabled ? Map<String, dynamic>.from(_value) : null;
  }

  @override
  void didUpdateWidget(covariant DeskObjectInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data?.value != widget.data?.value) {
      _value = _toMap(widget.data?.value);
      if (_isOptional) {
        setState(() => _isEnabled = widget.data?.value != null);
      }
    }
  }

  void _handleToggle(bool enabled) {
    setState(() {
      if (!enabled) {
        _lastValue = Map<String, dynamic>.from(_value);
        _isEnabled = false;
        _value = {};
      } else {
        _isEnabled = true;
        _value = _lastValue != null
            ? Map<String, dynamic>.from(_lastValue!)
            : <String, dynamic>{};
      }
    });
    widget.onChanged?.call(
      enabled ? Map<String, dynamic>.from(_value) : null,
    );
  }

  void _onChildChanged(String fieldName, dynamic childValue) {
    setState(() {
      _value[fieldName] = childValue;
    });
    _lastValue = Map<String, dynamic>.from(_value);
    widget.onChanged?.call(Map<String, dynamic>.from(_value));
  }

  Widget _buildField(DeskField field) {
    final path = widget.data?.path ?? widget.field.name;
    final data = _value[field.name] != null
        ? DeskData(value: _value[field.name], path: '$path.${field.name}')
        : null;

    final builder = DeskFieldInputRegistry.getBuilder(field);
    if (builder != null) {
      return builder(field, data, _onChildChanged);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLayout(DeskFieldLayout layout) {
    return switch (layout) {
      RowFields() => _buildRow(layout),
      ColumnFields() => _buildColumn(layout),
      GroupFields() => _GroupSection(
        group: layout,
        buildLayout: _buildLayout,
        buildField: _buildField,
      ),
    };
  }

  Widget _buildRow(RowFields row) {
    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: row.children
          .map(
            (f) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: _buildField(f),
              ),
            ),
          )
          .toList(),
    );

    if (row.collapsible) {
      return _CollapsibleWrapper(
        initiallyCollapsed: row.collapsed,
        child: content,
      );
    }
    return content;
  }

  Widget _buildColumn(ColumnFields col) {
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: col.children
          .map(
            (f) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildField(f),
            ),
          )
          .toList(),
    );

    if (col.collapsible) {
      return _CollapsibleWrapper(
        initiallyCollapsed: col.collapsed,
        child: content,
      );
    }
    return content;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.field.option.hidden) {
      return const SizedBox.shrink();
    }

    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        OptionalFieldHeader(
          title: widget.field.title,
          isOptional: _isOptional,
          isEnabled: _isEnabled,
          onToggle: _handleToggle,
        ),
        const SizedBox(height: 8),
        OptionalFieldWrapper(
          isEnabled: !_isOptional || _isEnabled,
          child: ShadCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.field.description != null) ...[
                  Text(widget.field.description!, style: theme.textTheme.muted),
                  const SizedBox(height: 16),
                ],
                ...widget.field.option.children.map(
                  (layout) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildLayout(layout),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// A stateful wrapper that manages collapse state for [RowFields]/[ColumnFields].
class _CollapsibleWrapper extends StatefulWidget {
  final bool initiallyCollapsed;
  final Widget child;

  const _CollapsibleWrapper({
    required this.initiallyCollapsed,
    required this.child,
  });

  @override
  State<_CollapsibleWrapper> createState() => _CollapsibleWrapperState();
}

class _CollapsibleWrapperState extends State<_CollapsibleWrapper> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.initiallyCollapsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: () => setState(() => _isCollapsed = !_isCollapsed),
          child: Row(
            children: [
              FaIcon(
                _isCollapsed
                    ? FontAwesomeIcons.chevronRight
                    : FontAwesomeIcons.chevronDown,
                size: 12,
                color: theme.colorScheme.mutedForeground,
              ),
              const SizedBox(width: 6),
              Text(
                _isCollapsed ? 'Show fields' : 'Hide fields',
                style: theme.textTheme.small.copyWith(
                  color: theme.colorScheme.mutedForeground,
                ),
              ),
            ],
          ),
        ),
        if (!_isCollapsed) ...[const SizedBox(height: 8), widget.child],
      ],
    );
  }
}

/// Renders a [GroupFields] with a titled, optionally collapsible section.
class _GroupSection extends StatefulWidget {
  final GroupFields group;
  final Widget Function(DeskFieldLayout) buildLayout;
  final Widget Function(DeskField) buildField;

  const _GroupSection({
    required this.group,
    required this.buildLayout,
    required this.buildField,
  });

  @override
  State<_GroupSection> createState() => _GroupSectionState();
}

class _GroupSectionState extends State<_GroupSection> {
  late bool _isCollapsed;

  @override
  void initState() {
    super.initState();
    _isCollapsed = widget.group.collapsed;
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context);
    final group = widget.group;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: group.collapsible
              ? () => setState(() => _isCollapsed = !_isCollapsed)
              : null,
          child: Row(
            children: [
              if (group.collapsible) ...[
                FaIcon(
                  _isCollapsed
                      ? FontAwesomeIcons.chevronRight
                      : FontAwesomeIcons.chevronDown,
                  size: 12,
                  color: theme.colorScheme.mutedForeground,
                ),
                const SizedBox(width: 6),
              ],
              Text(
                group.title,
                style: theme.textTheme.p.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        if (group.description != null && !_isCollapsed) ...[
          const SizedBox(height: 2),
          Text(group.description!, style: theme.textTheme.muted),
        ],
        if (!_isCollapsed) ...[
          const SizedBox(height: 12),
          ...group.children.map(
            (layout) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: widget.buildLayout(layout),
            ),
          ),
        ],
      ],
    );
  }
}
