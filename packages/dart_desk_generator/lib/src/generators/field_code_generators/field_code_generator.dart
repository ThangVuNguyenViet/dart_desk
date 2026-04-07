import 'package:analyzer/dart/constant/value.dart';
import 'package:analyzer/dart/element/element.dart';

abstract class FieldCodeGenerator {
  String get fieldConfigName;

  List<Type> get supportedTypes;

  String generate(
    FieldElement field,
    DartObject? config, {
    String? optionSource,
    String? innerSource,
    List<ClassElement>? discoveryQueue,
  });
}
