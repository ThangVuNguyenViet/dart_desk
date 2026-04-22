// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'cta_action.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for CtaAction
final ctaActionFields = [
  DeskStringField(name: 'label', title: 'Label', option: DeskStringOption()),
  DeskDropdownField<String>(
    name: 'style',
    title: 'Style',

    option: CtaStyleDropdownOption(),
  ),
];

/// Generated document type spec for CtaAction.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final ctaActionTypeSpec = DocumentTypeSpec<CtaAction>(
  name: 'ctaAction',
  title: 'Call-to-action',
  description: 'Button label + style',
  fields: ctaActionFields,
  defaultValue: CtaAction.defaultValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class CtaActionDeskModel {
  CtaActionDeskModel({required this.label, required this.style});

  final DeskData<String> label;

  final DeskData<String> style;
}
