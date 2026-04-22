import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'store_hours_entry.desk.dart';
part 'store_hours_entry.mapper.dart';

@MappableClass()
@DeskModel(title: 'Store hours entry', description: 'Open/close times for a single day')
class StoreHoursEntry with StoreHoursEntryMappable implements Serializable<StoreHoursEntry> {
  @DeskDropdown<String>(description: 'Day', option: DayOfWeekOption())
  final String day;

  @DeskString(description: 'Open (HH:mm)', option: DeskStringOption())
  final String openTime;

  @DeskString(description: 'Close (HH:mm)', option: DeskStringOption())
  final String closeTime;

  const StoreHoursEntry({required this.day, required this.openTime, required this.closeTime});

  static StoreHoursEntry defaultValue = const StoreHoursEntry(day: 'Mon', openTime: '17:00', closeTime: '23:00');

  static StoreHoursEntry $fromMap(Map<String, dynamic> map) => StoreHoursEntryMapper.fromMap(map);
}

class DayOfWeekOption extends DeskDropdownOption<String> {
  const DayOfWeekOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'Mon';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final d in daysOfWeek) DropdownOption(value: d, label: d),
      ];
  @override
  String? get placeholder => 'Day';
}
