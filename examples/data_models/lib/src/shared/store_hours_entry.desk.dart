// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'store_hours_entry.dart';

// **************************************************************************
// DeskFieldGenerator
// **************************************************************************

/// Generated DeskField list for StoreHoursEntry
final storeHoursEntryFields = [
  DeskDropdownField<String>(
    name: 'day',
    title: 'Day',

    option: DayOfWeekOption(),
  ),
  DeskStringField(
    name: 'openTime',
    title: 'Open Time',
    option: DeskStringOption(),
  ),
  DeskStringField(
    name: 'closeTime',
    title: 'Close Time',
    option: DeskStringOption(),
  ),
];

/// Generated document type spec for StoreHoursEntry.
/// Call .build(builder: ...) in your desk_app to produce a DocumentType.
final storeHoursEntryTypeSpec = DocumentTypeSpec<StoreHoursEntry>(
  name: 'storeHoursEntry',
  title: 'Store hours entry',
  description: 'Open/close times for a single day',
  fields: storeHoursEntryFields,
  initialValue: StoreHoursEntry.initialValue,
);

// **************************************************************************
// DeskConfigGenerator
// **************************************************************************

class StoreHoursEntryDeskModel {
  StoreHoursEntryDeskModel({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  final DeskData<String> day;

  final DeskData<String> openTime;

  final DeskData<String> closeTime;
}
