import 'package:flutter/widgets.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class CmsValidator<T> {
  final FormFieldValidator<T> Function(String label) labeledValidator;
  final String Function(String label)? labelTransformer;

  const CmsValidator(this.labeledValidator, {this.labelTransformer});

  String? call(String label, T? value) {
    return labeledValidator(label)(value);
  }
}

class RequiredValidator<T> extends CmsValidator<T> {
  RequiredValidator({
    /// Optional error text to display when validation fails.
    String? errorText,
  }) : super(
         (label) => FormBuilderValidators.required(
           errorText: errorText ?? '$label is required',
         ),
         labelTransformer: _trailingAteriskTransformer,
       );
}

String _trailingAteriskTransformer(String label) => '$label *';
