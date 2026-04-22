// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
// ignore_for_file: type=lint
// ignore_for_file: invalid_use_of_protected_member
// ignore_for_file: unused_element, unnecessary_cast, override_on_non_overriding_member
// ignore_for_file: strict_raw_type, inference_failure_on_untyped_parameter

part of 'cta_action.dart';

class CtaActionMapper extends ClassMapperBase<CtaAction> {
  CtaActionMapper._();

  static CtaActionMapper? _instance;
  static CtaActionMapper ensureInitialized() {
    if (_instance == null) {
      MapperContainer.globals.use(_instance = CtaActionMapper._());
    }
    return _instance!;
  }

  @override
  final String id = 'CtaAction';

  static String _$label(CtaAction v) => v.label;
  static const Field<CtaAction, String> _f$label = Field('label', _$label);
  static String _$style(CtaAction v) => v.style;
  static const Field<CtaAction, String> _f$style = Field('style', _$style);

  @override
  final MappableFields<CtaAction> fields = const {
    #label: _f$label,
    #style: _f$style,
  };

  static CtaAction _instantiate(DecodingData data) {
    return CtaAction(label: data.dec(_f$label), style: data.dec(_f$style));
  }

  @override
  final Function instantiate = _instantiate;

  static CtaAction fromMap(Map<String, dynamic> map) {
    return ensureInitialized().decodeMap<CtaAction>(map);
  }

  static CtaAction fromJson(String json) {
    return ensureInitialized().decodeJson<CtaAction>(json);
  }
}

mixin CtaActionMappable {
  String toJson() {
    return CtaActionMapper.ensureInitialized().encodeJson<CtaAction>(
      this as CtaAction,
    );
  }

  Map<String, dynamic> toMap() {
    return CtaActionMapper.ensureInitialized().encodeMap<CtaAction>(
      this as CtaAction,
    );
  }

  CtaActionCopyWith<CtaAction, CtaAction, CtaAction> get copyWith =>
      _CtaActionCopyWithImpl<CtaAction, CtaAction>(
        this as CtaAction,
        $identity,
        $identity,
      );
  @override
  String toString() {
    return CtaActionMapper.ensureInitialized().stringifyValue(
      this as CtaAction,
    );
  }

  @override
  bool operator ==(Object other) {
    return CtaActionMapper.ensureInitialized().equalsValue(
      this as CtaAction,
      other,
    );
  }

  @override
  int get hashCode {
    return CtaActionMapper.ensureInitialized().hashValue(this as CtaAction);
  }
}

extension CtaActionValueCopy<$R, $Out> on ObjectCopyWith<$R, CtaAction, $Out> {
  CtaActionCopyWith<$R, CtaAction, $Out> get $asCtaAction =>
      $base.as((v, t, t2) => _CtaActionCopyWithImpl<$R, $Out>(v, t, t2));
}

abstract class CtaActionCopyWith<$R, $In extends CtaAction, $Out>
    implements ClassCopyWith<$R, $In, $Out> {
  $R call({String? label, String? style});
  CtaActionCopyWith<$R2, $In, $Out2> $chain<$R2, $Out2>(Then<$Out2, $R2> t);
}

class _CtaActionCopyWithImpl<$R, $Out>
    extends ClassCopyWithBase<$R, CtaAction, $Out>
    implements CtaActionCopyWith<$R, CtaAction, $Out> {
  _CtaActionCopyWithImpl(super.value, super.then, super.then2);

  @override
  late final ClassMapperBase<CtaAction> $mapper =
      CtaActionMapper.ensureInitialized();
  @override
  $R call({String? label, String? style}) => $apply(
    FieldCopyWithData({
      if (label != null) #label: label,
      if (style != null) #style: style,
    }),
  );
  @override
  CtaAction $make(CopyWithData data) => CtaAction(
    label: data.get(#label, or: $value.label),
    style: data.get(#style, or: $value.style),
  );

  @override
  CtaActionCopyWith<$R2, CtaAction, $Out2> $chain<$R2, $Out2>(
    Then<$Out2, $R2> t,
  ) => _CtaActionCopyWithImpl<$R2, $Out2>($value, $cast, t);
}

