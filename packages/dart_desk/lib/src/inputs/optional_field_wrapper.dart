import 'package:flutter/material.dart';

/// Dims and blocks interaction on its child when [isEnabled] is false.
/// Used by DateTime and File inputs for the optional disabled state.
class OptionalFieldWrapper extends StatelessWidget {
  final bool isEnabled;
  final Widget child;

  const OptionalFieldWrapper({
    super.key,
    required this.isEnabled,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      ignoring: !isEnabled,
      child: AnimatedOpacity(
        opacity: isEnabled ? 1.0 : 0.4,
        duration: const Duration(milliseconds: 200),
        child: child,
      ),
    );
  }
}
