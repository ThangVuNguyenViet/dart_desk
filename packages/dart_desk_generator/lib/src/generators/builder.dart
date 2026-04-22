import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';

import 'desk_data_generator.dart';
import 'desk_field_generator.dart';

/// Creates a builder for generating CMS data and field configurations
Builder deskBuilder(BuilderOptions options) =>
    PartBuilder([DeskFieldGenerator(), DeskConfigGenerator()], '.desk.dart');
