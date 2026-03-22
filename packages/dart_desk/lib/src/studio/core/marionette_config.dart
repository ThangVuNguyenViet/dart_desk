import 'package:flutter/widgets.dart';
import 'package:marionette_flutter/marionette_flutter.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

/// Static Marionette configuration for the CMS Studio.
///
/// Registers Shadcn UI components as interactive widgets so that
/// Marionette can discover and interact with them.
abstract final class CmsMarionetteConfig {
  static const configuration = MarionetteConfiguration(
    isInteractiveWidget: _isInteractiveWidget,
    extractText: _extractText,
    extractProperties: _extractProperties,
    shouldStopTraversal: _shouldStopTraversal,
  );

  static bool _isInteractiveWidget(Type type) {
    if (type == ShadButton ||
        type == ShadIconButton ||
        type == ShadInput ||
        type == ShadInputFormField ||
        type == ShadCheckboxFormField ||
        type == ShadSwitchFormField) {
      return true;
    }
    // Generic types: runtime type includes type params (e.g. ShadSelect<String>)
    final name = type.toString();
    return name.startsWith('ShadSelect') ||
        name.startsWith('ShadRadioGroupFormField');
  }

  static String? _extractText(Element element) {
    final widget = element.widget;

    if (widget is ShadButton) {
      return _findTextInElement(element);
    }
    if (widget is ShadInputFormField) {
      return _extractInputFormFieldText(element);
    }
    if (widget is ShadInput) {
      return _extractInputText(element, widget);
    }
    if (widget is ShadFormBuilderField) {
      return _extractFormFieldLabel(element);
    }
    if (widget is ShadToast) {
      return _findTextInElement(element);
    }
    return null;
  }

  static bool _shouldStopTraversal(Type type) {
    return type == ShadInput || type == ShadInputFormField;
  }

  static Map<String, Object>? _extractProperties(Element element) {
    final widget = element.widget;

    if (widget is ShadButton) {
      return {
        'enabled': widget.enabled,
        'variant': widget.variant.name,
        if (widget.size != null) 'size': widget.size!.name,
      };
    }
    if (widget is ShadIconButton) {
      return {
        'enabled': widget.enabled,
        'variant': widget.variant.name,
        if (widget.iconSize != null) 'iconSize': widget.iconSize!,
      };
    }
    if (widget is ShadInput) {
      return {
        'enabled': widget.enabled,
        'readOnly': widget.readOnly,
        'obscureText': widget.obscureText,
      };
    }
    if (widget is ShadFormBuilderField) {
      if (element is StatefulElement) {
        final state = element.state;
        if (state is ShadFormBuilderFieldState) {
          final props = <String, Object>{
            'enabled': state.enabled,
            'readOnly': widget.readOnly,
          };
          final value = state.value;
          if (value != null) props['value'] = value;
          return props;
        }
      }
    }
    if (widget is ShadSelect) {
      final props = <String, Object>{'enabled': widget.enabled};
      if (element is StatefulElement) {
        final state = element.state;
        if (state is ShadSelectState) {
          final selected = state.controller.value;
          if (selected.isNotEmpty) {
            props['value'] = selected.length == 1
                ? selected.first.toString()
                : selected.map((v) => v.toString()).toList();
          }
        }
      }
      return props;
    }
    return null;
  }

  /// Extracts text for [ShadInputFormField] by finding the
  /// [ShadInputDecorator] child and reading its label, then falling back
  /// to the nested [ShadInput] placeholder.
  static String? _extractInputFormFieldText(Element element) {
    final parts = <String>[];

    // Find the ShadInputDecorator in the subtree.
    final decorator = _findElementOfType<ShadInputDecorator>(element);
    if (decorator != null) {
      final decoratorWidget = decorator.widget as ShadInputDecorator;

      // Extract label text by traversing the label's element subtree.
      if (decoratorWidget.label != null) {
        final labelText = _findTextUnderSlot(decorator, decoratorWidget.label!);
        if (labelText != null) parts.add(labelText);
      }
    }

    // Find the nested ShadInput for placeholder / current value.
    final inputElement = _findElementOfType<ShadInput>(element);
    if (inputElement != null) {
      final inputWidget = inputElement.widget as ShadInput;
      final value = inputWidget.controller?.text;
      if (value != null && value.isNotEmpty) {
        parts.add(value);
      } else if (inputWidget.placeholder != null) {
        final placeholder = _findTextUnderSlot(
          inputElement,
          inputWidget.placeholder!,
        );
        if (placeholder != null) parts.add(placeholder);
      }
    }

    return parts.isEmpty ? null : parts.join(': ');
  }

  /// Extracts text for a standalone [ShadInput].
  static String? _extractInputText(Element element, ShadInput widget) {
    final value = widget.controller?.text ?? widget.initialValue;
    if (value != null && value.isNotEmpty) return value;
    if (widget.placeholder != null) {
      return _findTextUnderSlot(element, widget.placeholder!);
    }
    return null;
  }

  /// Extracts the label text from a generic [ShadFormBuilderField] by finding
  /// [ShadInputDecorator] and traversing its label subtree.
  static String? _extractFormFieldLabel(Element element) {
    final decorator = _findElementOfType<ShadInputDecorator>(element);
    if (decorator != null) {
      final decoratorWidget = decorator.widget as ShadInputDecorator;
      if (decoratorWidget.label != null) {
        return _findTextUnderSlot(decorator, decoratorWidget.label!);
      }
    }
    return null;
  }

  /// Finds the first [Element] whose widget is of type [T] in the subtree.
  static Element? _findElementOfType<T extends Widget>(Element root) {
    Element? found;
    root.visitChildren((child) {
      if (found != null) return;
      if (child.widget is T) {
        found = child;
      } else {
        found = _findElementOfType<T>(child);
      }
    });
    return found;
  }

  /// Given a parent element and a target widget reference (e.g. the label
  /// widget), finds the corresponding element in the subtree and extracts
  /// all [Text] content from it.
  static String? _findTextUnderSlot(Element parent, Widget targetWidget) {
    // Find the element whose widget matches the target reference.
    final slotElement = _findElementForWidget(parent, targetWidget);
    if (slotElement != null) {
      return _findTextInElement(slotElement);
    }
    return null;
  }

  /// Finds the element whose widget is identical to [target].
  static Element? _findElementForWidget(Element root, Widget target) {
    Element? found;
    root.visitChildren((child) {
      if (found != null) return;
      if (identical(child.widget, target)) {
        found = child;
      } else {
        found = _findElementForWidget(child, target);
      }
    });
    return found;
  }

  /// Collects all [Text] data from the element subtree.
  static String? _findTextInElement(Element root) {
    final buffer = StringBuffer();
    _collectText(root, buffer);
    final result = buffer.toString().trim();
    return result.isEmpty ? null : result;
  }

  static void _collectText(Element element, StringBuffer buffer) {
    final widget = element.widget;
    if (widget is Text && widget.data != null) {
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(widget.data);
      return;
    }
    if (widget is RichText) {
      final plain = widget.text.toPlainText();
      if (plain.isNotEmpty) {
        if (buffer.isNotEmpty) buffer.write(' ');
        buffer.write(plain);
      }
      return;
    }
    element.visitChildren((child) {
      _collectText(child, buffer);
    });
  }
}
