// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'store_callout.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for StoreCallout
final storeCalloutFields = [
  DeskStringField(
    name: 'venueName',
    title: 'Venue Name',
    option: DeskStringOption(),
  ),
  DeskStringField(
    name: 'hoursLabel',
    title: 'Hours Label',
    option: DeskStringOption(),
  ),
  DeskStringField(
    name: 'distanceLabel',
    title: 'Distance Label',
    option: DeskStringOption(),
  ),
  DeskStringField(
    name: 'directionsLabel',
    title: 'Directions Label',
    option: DeskStringOption(),
  ),
];

/// Generated document type spec for StoreCallout.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final storeCalloutTypeSpec = DocumentTypeSpec<StoreCallout>(
  name: 'storeCallout',
  title: 'Store callout',
  description: 'Venue card on the home screen',
  fields: storeCalloutFields,
  initialValue: StoreCallout.initialValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class StoreCalloutDeskModel {
  StoreCalloutDeskModel({
    required this.venueName,
    required this.hoursLabel,
    required this.distanceLabel,
    required this.directionsLabel,
  });

  final DeskData<String> venueName;

  final DeskData<String> hoursLabel;

  final DeskData<String> distanceLabel;

  final DeskData<String> directionsLabel;
}
