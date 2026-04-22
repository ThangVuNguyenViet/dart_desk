import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'store_callout.desk.dart';
part 'store_callout.mapper.dart';

@MappableClass()
@DeskModel(title: 'Store callout', description: 'Venue card on the home screen')
class StoreCallout with StoreCalloutMappable implements Serializable<StoreCallout> {
  @DeskString(description: 'Venue name', option: DeskStringOption())
  final String venueName;

  @DeskString(description: 'Hours label', option: DeskStringOption())
  final String hoursLabel;

  @DeskString(description: 'Distance label', option: DeskStringOption())
  final String distanceLabel;

  @DeskString(description: 'Directions button label', option: DeskStringOption())
  final String directionsLabel;

  const StoreCallout({
    required this.venueName,
    required this.hoursLabel,
    required this.distanceLabel,
    required this.directionsLabel,
  });

  static StoreCallout defaultValue = const StoreCallout(
    venueName: 'Aura Tribeca',
    hoursLabel: 'Open till 11:30pm',
    distanceLabel: '0.4 mi away',
    directionsLabel: 'Directions',
  );

  static StoreCallout $fromMap(Map<String, dynamic> map) => StoreCalloutMapper.fromMap(map);
}
