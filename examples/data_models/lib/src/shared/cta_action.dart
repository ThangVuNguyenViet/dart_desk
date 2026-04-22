import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../seed/aura_enums.dart';

part 'cta_action.cms.g.dart';
part 'cta_action.mapper.dart';

@MappableClass()
@CmsConfig(title: 'Call-to-action', description: 'Button label + style')
class CtaAction with CtaActionMappable implements Serializable<CtaAction> {
  @CmsStringFieldConfig(description: 'Button label', option: CmsStringOption())
  final String label;

  @CmsDropdownFieldConfig<String>(
    description: 'Visual style',
    option: CtaStyleDropdownOption(),
  )
  final String style;

  const CtaAction({required this.label, required this.style});

  static CtaAction defaultValue = const CtaAction(label: 'Order now', style: 'solid');

  static CtaAction $fromMap(Map<String, dynamic> map) => CtaActionMapper.fromMap(map);
}

class CtaStyleDropdownOption extends CmsDropdownOption<String> {
  const CtaStyleDropdownOption({super.hidden});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get defaultValue => 'solid';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final s in ctaStyles) DropdownOption(value: s, label: s),
      ];
  @override
  String? get placeholder => 'Style';
}
