// packages/dart_desk/integration_test/test_utils/finders.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Finds a ShadButton by its label text.
Finder findShadButton(String label) => find.text(label);

/// Finds a widget by its ValueKey string.
Finder findByKey(String key) => find.byKey(ValueKey(key));

/// Finds the [EditableText] inside a [ShadInput] whose placeholder contains
/// the given text. This is the correct finder for shadcn_ui inputs, which
/// use [EditableText] internally rather than [TextField].
Finder findShadInput(String placeholder) => find.descendant(
  of: find.ancestor(
    of: find.text(placeholder),
    matching: find.byType(ShadInput),
  ),
  matching: find.byType(EditableText),
);
