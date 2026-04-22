// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'store_callout.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for StoreCallout
final storeCalloutFields = [
  CmsStringField(
    name: 'venueName',
    title: 'Venue Name',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'hoursLabel',
    title: 'Hours Label',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'distanceLabel',
    title: 'Distance Label',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'directionsLabel',
    title: 'Directions Label',
    option: CmsStringOption(),
  ),
];

/// Generated document type spec for StoreCallout.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final storeCalloutTypeSpec = DocumentTypeSpec<StoreCallout>(
  name: 'storeCallout',
  title: 'Store callout',
  description: 'Venue card on the home screen',
  fields: storeCalloutFields,
  defaultValue: StoreCallout.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class StoreCalloutCmsConfig {
  StoreCalloutCmsConfig({
    required this.venueName,
    required this.hoursLabel,
    required this.distanceLabel,
    required this.directionsLabel,
  });

  final CmsData<String> venueName;

  final CmsData<String> hoursLabel;

  final CmsData<String> distanceLabel;

  final CmsData<String> directionsLabel;
}
