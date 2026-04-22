import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';

part 'store_callout.cms.g.dart';
part 'store_callout.mapper.dart';

@MappableClass()
@CmsConfig(title: 'Store callout', description: 'Venue card on the home screen')
class StoreCallout with StoreCalloutMappable implements Serializable<StoreCallout> {
  @CmsStringFieldConfig(description: 'Venue name', option: CmsStringOption())
  final String venueName;

  @CmsStringFieldConfig(description: 'Hours label', option: CmsStringOption())
  final String hoursLabel;

  @CmsStringFieldConfig(description: 'Distance label', option: CmsStringOption())
  final String distanceLabel;

  @CmsStringFieldConfig(description: 'Directions button label', option: CmsStringOption())
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
