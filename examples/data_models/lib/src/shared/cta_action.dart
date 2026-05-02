import 'dart:async';
import 'package:dart_desk/dart_desk.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:flutter/widgets.dart';

import '../primitives/aura_enums.dart';

part 'cta_action.desk.dart';
part 'cta_action.mapper.dart';

@MappableClass()
@DeskModel(title: 'Call-to-action', description: 'Button label + style')
class CtaAction with CtaActionMappable implements Serializable<CtaAction> {
  @DeskString(description: 'Button label', option: DeskStringOption())
  final String label;

  @DeskDropdown<String>(
    description: 'Visual style',
    option: CtaStyleDropdownOption(),
  )
  final String style;

  const CtaAction({required this.label, required this.style});

  static CtaAction initialValue = const CtaAction(label: 'Order now', style: 'solid');

  static CtaAction $fromMap(Map<String, dynamic> map) => CtaActionMapper.fromMap(map);
}

class CtaStyleDropdownOption extends DeskDropdownOption<String> {
  const CtaStyleDropdownOption({super.visibleWhen});
  @override
  bool get allowNull => false;
  @override
  FutureOr<String?>? get initialValue => 'solid';
  @override
  FutureOr<List<DropdownOption<String>>> options(BuildContext context) => [
        for (final s in ctaStyles) DropdownOption(value: s, label: s),
      ];
  @override
  String? get placeholder => 'Style';
}
