// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

part of 'store_hours_entry.dart';

// **************************************************************************
// CmsFieldGenerator
// **************************************************************************

/// Generated CmsField list for StoreHoursEntry
final storeHoursEntryFields = [
  CmsDropdownField<String>(
    name: 'day',
    title: 'Day',

    option: DayOfWeekOption(),
  ),
  CmsStringField(
    name: 'openTime',
    title: 'Open Time',
    option: CmsStringOption(),
  ),
  CmsStringField(
    name: 'closeTime',
    title: 'Close Time',
    option: CmsStringOption(),
  ),
];

/// Generated document type spec for StoreHoursEntry.
/// Call .build(builder: ...) in your cms_app to produce a DocumentType.
final storeHoursEntryTypeSpec = DocumentTypeSpec<StoreHoursEntry>(
  name: 'storeHoursEntry',
  title: 'Store hours entry',
  description: 'Open/close times for a single day',
  fields: storeHoursEntryFields,
  defaultValue: StoreHoursEntry.defaultValue,
);

// **************************************************************************
// CmsConfigGenerator
// **************************************************************************

class StoreHoursEntryCmsConfig {
  StoreHoursEntryCmsConfig({
    required this.day,
    required this.openTime,
    required this.closeTime,
  });

  final CmsData<String> day;

  final CmsData<String> openTime;

  final CmsData<String> closeTime;
}
