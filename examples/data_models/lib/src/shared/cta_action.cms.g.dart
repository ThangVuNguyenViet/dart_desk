// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'cta_action.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for CtaAction
final ctaActionFields = [
  CmsStringField(name: 'label', title: 'Label', option: CmsStringOption()),
  CmsDropdownField<String>(
    name: 'style',
    title: 'Style',

    option: CtaStyleDropdownOption(),
  ),
];

/// Generated document type spec for CtaAction.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final ctaActionTypeSpec = DocumentTypeSpec<CtaAction>(
  name: 'ctaAction',
  title: 'Call-to-action',
  description: 'Button label + style',
  fields: ctaActionFields,
  defaultValue: CtaAction.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class CtaActionCmsConfig {
  CtaActionCmsConfig({required this.label, required this.style});

  final CmsData<String> label;

  final CmsData<String> style;
}
